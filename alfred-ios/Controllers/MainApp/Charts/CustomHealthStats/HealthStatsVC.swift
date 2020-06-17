//
//  HealthStatsVCViewController.swift
//  alfred-ios

import UIKit
import Foundation
import Charts
//import CoreGraphics

class HealthStatsVC : BaseVC, UIGestureRecognizerDelegate {
    
    //let kCONTENT_XIB_NAME = "ChartSection"
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
   
   
    @IBOutlet weak var stackView: UIStackView!
    
    
    //@IBOutlet weak var chartSection: ChartSection!
    

  func commonInit() {
      Bundle.main.loadNibNamed("HealthStatsVC", owner: self, options: nil)
    
  }
  
  
    
    var closeAction : (()->())?
    
    //Add ChartSection as Subview in stack
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.addSubview(contentView)
        self.scrollView.contentSize = self.contentView.frame.size
        //scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollsToTop = true
        
        scrollView.isPagingEnabled = true
        
        self.contentView.backgroundColor = .red
        
//        let section1 = ChartSection.instanceFromNib() as! ChartSection
//        let section2 = ChartSection.instanceFromNib() as! ChartSection
//        let section3 = ChartSection.instanceFromNib() as! ChartSection
        
//        
//        self.stackView.addArrangedSubview(section1)
//        self.stackView.addArrangedSubview(section2)
//        self.stackView.addArrangedSubview(section3)
        
        //This is where it crashes!!!!
        
//        let section = ChartSection.instanceFromNib()
//        
//        contentView.addSubview(section)
//        
        
       
        
        //stackView.addArrangedSubview(section)
        //scrollView.addSubview(section)
        //stackView.addArrangedSubview(section)
    
        //stackView.backgroundColor = UIColor.redColor();
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//       
        
    
        
       
        //view.isUserInteractionEnabled = false
//
//          let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(CustomChartVC.panGesture))
          //view.addGestureRecognizer(gesture)
       
        let closeBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeTapped(_:)))
        navigationItem.leftBarButtonItem = closeBtn
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
      }
      
      override func viewDidLayoutSubviews() {
          scrollView.isScrollEnabled = true
          scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 2000)
//         let section = ChartSection.instanceFromNib()
    


      }
    

   
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
            let translation = recognizer.translation(in: self.view)
    
            //UIView.animate(withDuration: 0.2)
    
            let y = self.view.frame.minY //.minY
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
    
    
            recognizer.setTranslation(CGPoint.zero, in: self.view)
                
               
            
        }
    
    
    @objc private func closeTapped(_ sender: UIBarButtonItem) {
        closeAction?()
    }

    
    
}
