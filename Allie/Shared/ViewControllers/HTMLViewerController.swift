//
//  HTMLViewerController.swift
//  Allie
//
//  Created by Waqar Malik on 3/21/21.
//

import UIKit
import WebKit

class HTMLViewerController: UIViewController, WKUIDelegate {
	var webView: WKWebView = {
		let webConfiguration = WKWebViewConfiguration()
		let webView = WKWebView(frame: .zero, configuration: webConfiguration)
		return webView
	}()

	var url: URL? = URL(string: "https://www.codexhealth.com") {
		didSet {
			reloadURL()
		}
	}

	override func loadView() {
		webView.uiDelegate = self
		view = webView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		reloadURL()
	}

	func reloadURL() {
		guard let url = url else {
			return
		}
		let myRequest = URLRequest(url: url)
		webView.load(myRequest)
	}
}
