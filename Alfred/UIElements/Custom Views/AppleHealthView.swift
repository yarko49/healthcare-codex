import Foundation
import UIKit

class AppleHealthView: UIView {
	@IBOutlet var contentView: UIView!

	let contentXIBName = "AppleHealthView"

	// MARK: - IBOutlets

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descLbl: UILabel!

	@IBOutlet var ovalImg: UIImageView!

	var title: String = ""
	var descr: String = ""
	var image: String = ""

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(title: String, descr: String, image: String) {
		self.init(frame: CGRect.zero)
		self.title = title
		self.descr = descr
		self.image = image
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(contentXIBName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	func setup() { // used to be private
		titleLbl.attributedText = title.with(style: .bold20, andColor: .black, andLetterSpacing: 0.36)
		descLbl.attributedText = descr.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.32)
		if image != "" {
			ovalImg.image = UIImage(named: image)
		}
	}
}
