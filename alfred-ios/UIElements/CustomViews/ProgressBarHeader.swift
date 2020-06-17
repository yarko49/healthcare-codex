//
//  ProgressBarHeader.swift
//  alfred-ios
//

import UIKit

class ProgressBarHeader: UIView {
    
    var backBtnAction: (()->())?
    
    let kCONTENT_XIB_NAME = "ProgressBarHeader"
    
    var contentView: UIView?
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var headerTitle: String = ""

    //MARK:- Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    init(headerTitle: String) {
        super.init(frame: CGRect.zero)
        self.headerTitle = headerTitle
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        setupView()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kCONTENT_XIB_NAME, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    private func setupView() {
        setupProgressBar()
    }
    
    private func setupProgressBar() {
        progressBar.progressTintColor = .blue
        progressBar.trackTintColor = .gray
        progressBar.layer.cornerRadius = 5
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers?[1].cornerRadius = 4
        progressBar.subviews[1].clipsToBounds = true
    }
    
    
    func changeProgress(step: Int) {
        let progress = step != 6 ? Float(Double( step * 14) / 100.0) : 100.0
        progressBar.setProgress(progress, animated: true)
    }
}


