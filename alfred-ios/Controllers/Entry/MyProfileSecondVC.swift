
//  EditPickersVCViewController.swift
//  alfred-ios


import UIKit
import Foundation
import IQKeyboardManagerSwift

class MyProfileSecondVC :BaseVC , UITextFieldDelegate , UIGestureRecognizerDelegate {
    
    var backBtnAction : (()->())?
    var nextBtnAction : (()->())?
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var pickerSV: UIStackView!
    
    var dobDate : Date?
    
    let feetData = [["0 ft", "1 ft", "2 ft", "3 ft", "4 ft", "5 ft", "6 ft", "7 ft", "8 ft"],["0 in ", "1 in", "2 in", "3 in", "4 in", "5 in", "6 in", "7 in", "8 in","9 in","10 in","11 in","12 in"]]
    let lbData = ["0 lbs", "20 lbs", "30 lbs", "40 lbs", "50 lbs"]
    
    var weightPicker = UIPickerView()
    var heightPicker = UIPickerView()
    
    var dateHidden : Bool = true
    var heightHidden : Bool = true
    var weightHidden : Bool = true
    
    var dateTextView = PickerTF()
    var weightTextView = PickerTF()
    var heightTextView = PickerTF()
    
    var nextBtn = BottomButton()
    
    private let datePicker: UIDatePicker = {
        let calendar = Calendar(identifier: .gregorian)
        let components: NSDateComponents = NSDateComponents()
        components.year = 1980
        components.month = 1
        components.day = 1
        let defaultDate: NSDate = calendar.date(from: components as DateComponents)! as NSDate
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.backgroundColor = UIColor.white
        picker.maximumDate = Date()
        
        let minimumComponents: NSDateComponents = NSDateComponents()
        minimumComponents.year = 1900
        minimumComponents.month = 1
        minimumComponents.day = 1
        let minimumDate: Date = (calendar.date(from: minimumComponents as DateComponents)!  as NSDate) as Date
        picker.minimumDate = minimumDate
        
        picker.setDate(defaultDate as Date, animated: false)
        return picker
    }()
    
    override func setupView() {
        super.setupView()
        
        title = Str.profile
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.view.isUserInteractionEnabled = true
        pickerSV.addArrangedSubview(dateTextView)
        pickerSV.addArrangedSubview(datePicker)
        pickerSV.addArrangedSubview(heightTextView)
        pickerSV.addArrangedSubview(heightPicker)
        pickerSV.addArrangedSubview(weightTextView)
        pickerSV.addArrangedSubview(weightPicker)
        datePicker.isHidden = !dateHidden
        heightPicker.isHidden = heightHidden
        weightPicker.isHidden = weightHidden
        dateTextView.setupValues(labelTitle: Str.dob, text: "")
        weightTextView.setupValues(labelTitle: Str.weight, text: "")
        heightTextView.setupValues(labelTitle: Str.height, text: "")
        dateTextView.isEnabled = false
        weightTextView.isEnabled = false
        heightTextView.isEnabled = false
        
        datePicker.addTarget(self, action: #selector(datePickerDateChanged(_:)), for: .valueChanged)
        
        let tapDate = UITapGestureRecognizer(target: self, action: #selector(self.hideDatePicker(_:)))
        dateTextView.addGestureRecognizer(tapDate)
        
        let tapWeight = UITapGestureRecognizer(target: self, action: #selector(self.hideWeightPicker(_:)))
        weightTextView.addGestureRecognizer(tapWeight)
        
        let tapHeight = UITapGestureRecognizer(target: self, action: #selector(self.hideHeightPicker(_:)))
        heightTextView.addGestureRecognizer(tapHeight)
        
        infoLbl.attributedText = Str.information.with(style: .regular17, andColor: UIColor.lightGray, andLetterSpacing: -0.32)
        infoLbl.numberOfLines = 0
        view.layoutIfNeeded()
        
        setupDelegates()
    }
    
    func setupDelegates() {
        weightPicker.delegate = self
        weightPicker.dataSource = self
        heightPicker.delegate = self
        heightPicker.dataSource = self
        weightTextView.textfield.delegate = self
        heightTextView.textfield.delegate = self
    }
    
    @objc func hideDatePicker(_ sender : Any) {
        UIPickerView.transition(with: datePicker, duration: 0.1,
                                options: .curveEaseOut,
                                animations: {
                                    self.datePicker.isHidden = !self.dateHidden
                                    self.dateHidden = !self.dateHidden
                                    
        })
        dateTextView.textfield.textColor = dateHidden == false ? .lightGray : .black
    }
    
    
    @objc func hideWeightPicker(_ sender : Any){
        
        if weightHidden == true {
            weightTextView.titleLbl.attributedText = Str.weight.with(style: .regular17, andColor: UIColor.weightLblColor ?? UIColor.orange, andLetterSpacing: -0.078)
            weightTextView.lineView.backgroundColor = UIColor.orange
        } else {
            weightTextView.titleLbl.attributedText = Str.weight.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.078)
            weightTextView.lineView.backgroundColor = .lightGray
        }
        UIPickerView.transition(with: weightPicker, duration: 0.1,
                                options: .curveEaseOut,
                                animations: {
                                    self.weightPicker.isHidden = !self.weightHidden
                                    self.weightHidden = !self.weightHidden
        })
        weightTextView.textfield.textColor = weightHidden == false ? .lightGray : .black
    }
    
    @objc func hideHeightPicker(_ sender : Any) {
        UIPickerView.transition(with: heightPicker, duration: 0.1,
                                options: .curveEaseOut,
                                animations: {
                                    self.heightPicker.isHidden = !self.heightHidden
                                    self.heightHidden = !self.heightHidden
        })
        heightTextView.textfield.textColor = heightHidden == false ? .lightGray : .black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func backBtnTapped(){
        backBtnAction?()
    }
    
    @objc private func datePickerDateChanged(_ sender: UIDatePicker) {
        if weightHidden == true {
            weightTextView.titleLbl.attributedText = Str.weight.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.078)
            weightTextView.lineView.backgroundColor = .lightGray
        }
        
        dateTextView.textfield.text = DateFormatter.ddMMyyyy.string(from: sender.date)
        dobDate = sender.date
    }
    
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
}

extension MyProfileSecondVC : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == datePicker {
            return 3
        } else if pickerView == heightPicker {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var data = 0
        
        if pickerView == heightPicker {
            
            data = feetData[component].count
            
        } else if pickerView == weightPicker {
            data = lbData.count
        }
        return data
    }
}

extension MyProfileSecondVC : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var rowData : String = ""
        
        if pickerView == heightPicker{
            rowData = feetData[component][row]
        } else if pickerView == weightPicker{
            rowData = lbData[row]
        }
        return rowData
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePicker {
            hideDatePicker(datePicker)
        } else if pickerView == weightPicker {
            weightTextView.textfield.text = lbData[row]
        } else if pickerView == heightPicker {
            let feet =  feetData[0][pickerView.selectedRow(inComponent: 0)]
            let inches = feetData[1][pickerView.selectedRow(inComponent: 1)]
            heightTextView.textfield.text = feet + " " + inches
        }
    }
}
