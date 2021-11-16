//
//  WebAuthenticationViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/31/21.
//

import UIKit
import WebKit

protocol WebAuthenticationViewControllerDelegate: AnyObject {
	func webAuthenticationViewControllerDidCancel(_ controller: WebAuthenticationViewController)
	func webAuthenticationViewController(_ controller: WebAuthenticationViewController, didFinsihWith token: String?, state: String?)
}

class WebAuthenticationViewController: UIViewController {
	weak var delegate: WebAuthenticationViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("AUTHENTICATION", comment: "Authentication")
		let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
		navigationItem.leftBarButtonItem = button
		webView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(webView)
		NSLayoutConstraint.activate([webView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             webView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: webView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: webView.bottomAnchor, multiplier: 0.0)])
		webView.navigationDelegate = self
		webView.uiDelegate = self

		let activityButton = UIBarButtonItem(customView: activityIndicatorView)
		navigationItem.rightBarButtonItem = activityButton
		activityIndicatorView.startAnimating()
	}

	var authURL: URL? {
		didSet {
			redirectURI = authURL?.extractRedirectURI
		}
	}

	var redirectURI: String?
	var cloudEntity: CloudEntityType?

	let webView: WKWebView = {
		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = true
		preferences.isFraudulentWebsiteWarningEnabled = true
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences
		let view = WKWebView(frame: .zero, configuration: configuration)
		view.allowsBackForwardNavigationGestures = true
		view.allowsLinkPreview = false
		return view
	}()

	let activityIndicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .medium)
		view.tintColor = .allieBlack
		view.hidesWhenStopped = true
		return view
	}()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureView()
	}

	@IBAction func cancel(_ sender: Any?) {
		delegate?.webAuthenticationViewControllerDidCancel(self)
	}

	private func configureView() {
		guard let url = authURL else {
			return
		}

		let urlRuquest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
		webView.load(urlRuquest)
	}

	var popupWebView: WKWebView?
}

extension WebAuthenticationViewController: WKUIDelegate {
	func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
		popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
		popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		// Hack to fool Google Login
		popupWebView?.customUserAgent = "Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko)"
		popupWebView?.navigationDelegate = self
		popupWebView?.uiDelegate = self
		view.addSubview(popupWebView!)
		return popupWebView!
	}

	func webViewDidClose(_ webView: WKWebView) {
		if webView == popupWebView {
			popupWebView?.removeFromSuperview()
			popupWebView = nil
		}
	}
}

extension WebAuthenticationViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		guard let url = navigationAction.request.url else {
			decisionHandler(.allow)
			return
		}
		// https://patient-ehr.codexhealth.com/?code=<String>&state=2021-09-01T05%3a42%3a27Z
		if let redirectURI = redirectURI, url.absoluteString.hasPrefix(redirectURI) {
			let authURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
			let authQueryItems = authURLComponents?.queryItems
			let tokenKey = authQueryItems?.first(where: { item in
				item.name == "code"
			})?.value
			let state = authQueryItems?.first(where: { item in
				item.name == "state"
			})?.value

			if let token = tokenKey, !token.isEmpty {
				decisionHandler(.cancel)
				delegate?.webAuthenticationViewController(self, didFinsihWith: token, state: state)
			} else {
				decisionHandler(.allow)
			}
		} else {
			decisionHandler(.allow)
		}
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		activityIndicatorView.stopAnimating()
	}
}
