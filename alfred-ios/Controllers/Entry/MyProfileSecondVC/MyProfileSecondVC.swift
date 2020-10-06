
import UIKit
import Foundation
import IQKeyboardManagerSwift

enum Input : String, Codable {
    case height
    case weight
}

class MyProfileSecondVC : BaseVC, UIGestureRecognizerDelegate{
    
    var backBtnAction : (()->())?
    var alertAction: ((_ tv: PickerTF)->())?
    var patientRequestAction : ((_ resourceType: String, _ birthdate: String, _ weight : Int , _ height: Int, _ date : String)->())?

    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var pickerSV: UIStackView!
    @IBOutlet weak var nextBtn: BottomButton!
    @IBOutlet weak var bottomView: UIView!
    
    var inputType: Input = .weight
    var date: String?
    var identifier: String?
    var heightInt: Int = 0
    var weightInt: Int = 0
    var effectiveDate: String?
    
    
    //let feetData = [["0 ft", "1 ft", "2 ft", "3 ft", "4 ft", "5 ft", "6 ft", "7 ft", "8 ft"],["0 in ", "1 in", "2 in", "3 in", "4 in", "5 in", "6 in", "7 in", "8 in","9 in","10 in","11 in","12 in"]]
    
    let feetData = [Array(0...300), Array(0...9)]
    
    //var lbData = (0...300).map { "\($0) lbs" }
    
    var lbData = Array(0...300)
    
    var weightPicker = UIPickerView()
    var heightPicker = UIPickerView()
    var dateHidden : Bool = true
    var heightHidden : Bool = true
    var weightHidden : Bool = true
    var dateTextView = PickerTF()
    var weightTextView = PickerTF()
    var heightTextView = PickerTF()
    
    private let datePicker: UIDatePicker = {
        let calendar = Calendar(identifier: .gregorian)
        let components: NSDateComponents = NSDateComponents()
        components.year = 1980
        components.month = 1
        components.day = 1
        var startDate : Date = Date()
        
        let defaultDate: NSDate? = calendar.date(from: components as DateComponents) as NSDate?
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.backgroundColor = UIColor.white
        picker.maximumDate = Date()
        picker.setDate((defaultDate as Date?) ?? Date(), animated: false)
        return picker
    }()
    
    override func setupView() {
        super.setupView()
        
        setupSubviews()
        
        title = Str.profile
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.view.isUserInteractionEnabled = true
        nextBtn.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
        nextBtn.refreshCorners(value: 0)
        nextBtn.setupButton()
        bottomView.backgroundColor = UIColor.grey
        datePicker.addTarget(self, action: #selector(datePickerDateChanged(_:)), for: .valueChanged)
        
        let tapDate = UITapGestureRecognizer(target: self, action: #selector(self.manageDatePicker))
        dateTextView.addGestureRecognizer(tapDate)
        
        let tapWeight = UITapGestureRecognizer(target: self, action: #selector(self.manageWeightPicker))
        weightTextView.addGestureRecognizer(tapWeight)
        
        let tapHeight = UITapGestureRecognizer(target: self, action: #selector(self.manageHeightPicker))
        heightTextView.addGestureRecognizer(tapHeight)
    
        self.view.isUserInteractionEnabled = true
        self.view.layoutIfNeeded()
        view.layoutIfNeeded()
        setupDelegates()
       setupObservation()
    }
    
    func setupSubviews(){
        
        arrangePickers()
        populatePickers()
        infoLbl.attributedText = Str.information.with(style: .regular17, andColor: UIColor.lightGray, andLetterSpacing: -0.32)
        infoLbl.numberOfLines = 0
    }
    
    func populatePickers(){
        
        dateTextView.setupValues(labelTitle: Str.dob, text: "")
        weightTextView.setupValues(labelTitle: Str.weight, text: "" )
        heightTextView.setupValues(labelTitle: Str.height, text: "")
      
    }
    
    private func setupObservation() {
        effectiveDate = ""
        if let date = self.getDate() {
            effectiveDate = DateFormatter.wholeDateRequest.string(from: date)
        } else {
            return
        }
    }
    
    func getDate() -> Date? {
        let date = datePicker.date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
    
        var newComponents = DateComponents()
        newComponents.timeZone = .current
        newComponents.day = dateComponents.day
        newComponents.month = dateComponents.month
        newComponents.year = dateComponents.year
        return calendar.date(from: newComponents)
    }

    
    func arrangePickers(){
        
        let subviews = [dateTextView,datePicker,heightTextView,heightPicker,weightTextView,weightPicker]
        for subview in subviews {
            pickerSV.addArrangedSubview(subview)
        }
        
        datePicker.isHidden = dateHidden
        heightPicker.isHidden = heightHidden
        weightPicker.isHidden = weightHidden
    }
    
    
    func setupDelegates() {
        weightPicker.delegate = self
        weightPicker.dataSource = self
        heightPicker.delegate = self
        heightPicker.dataSource = self
    }
    
    @objc func manageDatePicker() {
        setupCollapsedPickers(picker: weightPicker, textfield: weightTextView.textfield)
        setupCollapsedPickers(picker: heightPicker, textfield: heightTextView.textfield)
        weightHidden = true
        heightHidden = true
        
        if dateHidden, dateTextView.tfText?.isEmpty == true {
            datePickerDateChanged(datePicker)
        }
        
        UIPickerView.transition(with: datePicker, duration: 0.1,
                                options: .curveEaseOut,
                                animations: {
                                    self.datePicker.isHidden = !self.dateHidden
                                    self.dateHidden = !self.dateHidden
        })
        dateTextView.textfield.textColor = dateHidden == false ? .lightGray : .black
    }
    
    @objc func manageWeightPicker(){
        
        setupCollapsedPickers(picker: heightPicker, textfield: heightTextView.textfield)
        setupCollapsedDate(picker: datePicker)
        dateHidden = true
        heightHidden = true
        
        if weightHidden, weightTextView.tfText?.isEmpty == true {
            weightTextView.tfText = Str.lbs(lbData[0])
        }

        UIPickerView.transition(with: weightPicker, duration: 0.1,
                                options: .curveEaseOut,
                                animations: {
                                    self.weightPicker.isHidden = !self.weightHidden
                                    self.weightHidden = !self.weightHidden
        })
        weightTextView.textfield.textColor = dateHidden == false ? .lightGray : .black
    }
    
    @objc func manageHeightPicker() {
        
        setupCollapsedPickers(picker: weightPicker, textfield: weightTextView.textfield)
        setupCollapsedDate(picker: datePicker)
        weightHidden = true
        dateHidden = true
        
        if heightHidden, heightTextView.tfText?.isEmpty == true {
            heightTextView.tfText = "\(feetData[0][0]) ft \(feetData[1][0])"
        }
        
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
    
    @objc private func datePickerDateChanged(_ sender: UIDatePicker) {
        dateTextView.textfield.text = DateFormatter.ddMMyyyy.string(from: sender.date)
        date = DateFormatter.yyyyMMdd.string(from: sender.date)
    }
    
    
    func setupCollapsedDate(picker : UIDatePicker){
        datePicker.isHidden = true
        dateHidden = true
        dateTextView.textfield.textColor = .black
    }
    
    func setupCollapsedPickers(picker : UIPickerView, textfield : UITextField){
        picker.isHidden = true
        textfield.textColor = .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        guard let dateTF = dateTextView.tfText, !dateTF.isEmpty else {
            dateTextView.state = .error
            self.alertAction?(dateTextView)
            return
        }
        dateTextView.state = .normal
        
        guard let weight = weightTextView.tfText, !weight.isEmpty else {
            weightTextView.state = .error
            self.alertAction?(weightTextView)
            return
        }
        weightTextView.state = .normal
        
        guard let height = heightTextView.tfText, !height.isEmpty else{
            heightTextView.state = .error
            self.alertAction?(heightTextView)
            return
        }
        heightTextView.state = .normal
        
        patientRequestAction?("Patient", date ?? "", weightInt , heightInt , effectiveDate ?? "")
        
    }
    
    @objc func backBtnTapped(){
        backBtnAction?()
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
            rowData = "\(feetData[component][row])"
            heightInt = feetData[component][row]
        } else if pickerView == weightPicker{
            rowData = "\(lbData[row])"
            weightInt = lbData[row]
            
        }
        return rowData
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePicker {
        } else if pickerView == weightPicker {
            weightTextView.tfText = Str.lbs(lbData[row])
        } else if pickerView == heightPicker {
            let feet =  feetData[0][pickerView.selectedRow(inComponent: 0)]
            let inches = feetData[1][pickerView.selectedRow(inComponent: 1)]
            
            heightTextView.tfText = "\(feet) ft \(inches)"
        }
    }
}
