//
//  CHOperation.swift
//  Alfred
//
//  Created by Waqar Malik on 1/15/21.
//

import Foundation

class CHOperation: Operation {
	@objc enum State: Int {
		case isReady
		case isExecuting
		case isFinsihed
	}

	var callbackQueue: DispatchQueue = .main

	private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
	private var _state: State = .isReady

	@objc private dynamic var state: State {
		get {
			stateQueue.sync {
				_state
			}
		}
		set {
			stateQueue.sync(flags: .barrier) {
				_state = newValue
			}
		}
	}

	override open class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		if ["isReady", "isFinished", "isExecuting"].contains(key) {
			return [#keyPath(state)]
		}
		return super.keyPathsForValuesAffectingValue(forKey: key)
	}

	override open var isExecuting: Bool {
		state == .isExecuting
	}

	override open var isFinished: Bool {
		state == .isFinsihed
	}

	override open func start() {
		if isCancelled {
			finish()
			return
		}
		state = .isExecuting
		main()
	}

	override open func main() {
		fatalError("Implement in sublcass to perform task")
	}

	public final func finish() {
		callbackQueue.async { [weak self] in
			if let running = self?.isExecuting, running {
				self?.state = .isFinsihed
			}
		}
	}
}

class AsynchronousOperation: CHOperation {
	override open var isAsynchronous: Bool {
		true
	}
}

class SynchronousOperation: CHOperation {
	override open var isAsynchronous: Bool {
		false
	}
}
