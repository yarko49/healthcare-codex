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

	var url: URL? {
		didSet {
			extractRedirectURL(url: url)
		}
	}

	var organization: CHOrganization?
	var redirectURI: String?

	let webView: WKWebView = {
		let preferences = WKPreferences()
		preferences.javaScriptCanOpenWindowsAutomatically = false
		preferences.isFraudulentWebsiteWarningEnabled = true
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences
		let view = WKWebView(frame: .zero, configuration: configuration)
		view.allowsBackForwardNavigationGestures = false
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
		guard let url = self.url else {
			return
		}

		let urlRuquest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
		webView.load(urlRuquest)
	}

	private func extractRedirectURL(url: URL?) {
		guard let url = url else {
			return
		}
		let authURLComponents = URLComponents(string: url.absoluteString)
		let authQueryItems = authURLComponents?.queryItems
		let redirectURI = authQueryItems?.first(where: { item in
			item.name == "redirect_uri"
		})?.value
		self.redirectURI = redirectURI
	}
}

extension WebAuthenticationViewController: WKUIDelegate {}

extension WebAuthenticationViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		guard let url = navigationAction.request.url else {
			decisionHandler(.allow)
			return
		}
		// https://patient-ehr.codexhealth.com/?code=<String>&state=2021-09-01T05%3a42%3a27Z
		if let redirectURI = self.redirectURI, url.absoluteString.hasPrefix(redirectURI) {
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
