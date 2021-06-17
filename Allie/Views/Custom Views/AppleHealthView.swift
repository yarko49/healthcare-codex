import Foundation
import UIKit

class AppleHealthView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descLabel: UILabel!

	@IBOutlet var ovalImageView: UIImageView!

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
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	func setup() { // used to be private
		titleLabel.attributedText = title.attributedString(style: .bold20, foregroundColor: .black, letterSpacing: 0.36)
		descLabel.attributedText = descr.attributedString(style: .regular17, foregroundColor: .grey, letterSpacing: -0.32)
		if image != "" {
			ovalImageView.image = UIImage(named: image)
		}
	}
}
