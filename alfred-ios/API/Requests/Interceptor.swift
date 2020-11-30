//
//  Interceptor.swift
//  alfred-ios
//

import Foundation
import Alamofire
import FirebaseAuth

class Interceptor: RequestRetrier, RequestAdapter {
    typealias RefreshCompletion = (_ succeeded: Bool) -> Void
    
    private let lock = NSLock()
    
    var authToken: String? {
        return DataContext.shared.authToken
    }
    
    var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let statusCode = (request.task?.response as? HTTPURLResponse)?.statusCode, [401, 403].contains(statusCode) {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                initiateRefresh(with: statusCode)
            }
        }
    }
    
    private func initiateRefresh(with statusCode: Int) {
        let completion: RefreshCompletion = {[weak self] (succeeded) in
            self?.lock.lock(); defer { self?.lock.unlock() }
            self?.requestsToRetry.forEach({
                $0(succeeded, 0.0)
            })
            self?.requestsToRetry.removeAll()
        }
        
        if statusCode == 401 {
            refreshTokens(completion: completion)
        }
    }
    
    func refreshTokens(completion: @escaping Interceptor.RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        Auth.auth().currentUser?.getIDToken(completion: { [weak self] (firebaseToken, error) in
            self?.isRefreshing = false
            if let _ = error {
                completion(false)
            } else if let firebaseToken = firebaseToken {
                DataContext.shared.authToken = firebaseToken
                completion(true)
            }
        })
    }
    
    // MARK: RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequestToSend = urlRequest
        if let token = authToken {
            urlRequestToSend.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return urlRequestToSend
    }
}
