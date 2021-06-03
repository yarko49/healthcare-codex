//
//  PDFViewController.swift
//  Allie
//
//  Created by Waqar Malik on 5/30/21.
//

import PDFKit
import UIKit

class PDFViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
	}

	let pdfView: PDFView = {
		let view = PDFView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	var pdfContentURL: URL? {
		didSet {
			renderPDF(at: pdfContentURL)
		}
	}

	private func renderPDF(at url: URL?) {
		guard let url = url, let pdfDocument = PDFDocument(url: url) else {
			return
		}

		pdfView.document = pdfDocument
	}

	private func configureView() {
		view.addSubview(pdfView)
		NSLayoutConstraint.activate([pdfView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             pdfView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: pdfView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: pdfView.bottomAnchor, multiplier: 0.0)])

		let closeBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(close(_:)))
		navigationItem.rightBarButtonItem = closeBarButton
	}

	@objc func close(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}
