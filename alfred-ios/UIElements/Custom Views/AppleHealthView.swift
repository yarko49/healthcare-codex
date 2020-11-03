
import Foundation
import UIKit

class AppleHealthView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    let kCONTENT_XIB_NAME = "AppleHealthView"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var ovalImg: UIImageView!
    
    var title : String = ""
    var descr : String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(title: String, descr: String) { //used to be : String
        self.init(frame: CGRect.zero)
        self.title = title
        self.descr = descr
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        setup()
        
    }
    
    func setup() { //used to be private
        titleLbl.attributedText = title.with(style: .bold20, andColor: .black, andLetterSpacing: 0.36)
        descLbl.attributedText = descr.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.32)
    }
}
