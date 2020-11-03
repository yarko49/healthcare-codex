import Foundation
import UIKit
import Charts
import CoreGraphics
import HealthKit

class ChartView : UIView  {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var rightInsetView: UIView!
    @IBOutlet weak var leftInsetView: UIView!
    @IBOutlet weak var insetView: UIView!
    
    var type = DataContext.shared.userAuthorizedQuantities

    let kCONTENT_XIB_NAME = "ChartView"
    var minimum : Double = 0.0
    var maximum : Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        contentView.insertSubview(lineChartView, aboveSubview: contentView)
        self.contentView.isUserInteractionEnabled = true
        insetView.backgroundColor = UIColor.chartColor
        leftInsetView.backgroundColor = UIColor.chartColor
        rightInsetView.backgroundColor = UIColor.chartColor
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let utcDateFromServer = "2017-01-01 22:10:10"
        let date = formatter.date(from: utcDateFromServer)
        
        
    }
    
    func refreshChart(type :HealthStatsDateIntervalType){
        
        if #available(iOS 13.0, *){
            
            var yVals = [Double]()
            switch type {
            case .daily :
                print("nothing")
            case .weekly:
                yVals = [182, 185, 183, 189, 190, 192, 185]
                minimum = yVals.min()!
                maximum = yVals.max()!
                setLineChart(xValues: ["SN", "M", "T", "W", "TH", "F", "S"], yValues: [yVals])
            case  .monthly :
                yVals  = [185, 187, 183, 188, 186]
                minimum = yVals.min()!
                maximum = yVals.max()!
                setLineChart(xValues: ["6/19", "6/26", "7/5", "7/12", "7/919"], yValues: [yVals])
            case  .yearly :
                yVals  = [190, 187, 185, 183, 183, 186, 187, 185, 189, 190, 192, 191]
                minimum = yVals.min()!
                maximum = yVals.max()!
                setLineChart(xValues: ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"], yValues: [yVals])
            }
        } else {
            return
        }
    }
    
    
    @available(iOS 13.0, *)
    
    func setLineChart(xValues : [String], yValues : [[Double]]) {
        let data = LineChartData()
        var lineChartEntry1 = [ChartDataEntry]()
        
        for i in 0..<xValues.count {
            lineChartEntry1.append(ChartDataEntry(x : Double(i), y: Double(yValues[0][i])))
        }
        
        let line = LineChartDataSet(entries: lineChartEntry1)
        data.addDataSet(line)
        lineChartView.data = data
        line.highlightColor = .clear
        line.setDrawHighlightIndicators(true)
        line.setCircleColor(.black)
        line.circleRadius = 4.0
        line.circleHoleColor = .white
        line.circleHoleRadius = 2.5
        line.valueTextColor =  NSUIColor.clear
        line.lineWidth = 2.0
        line.drawCircleHoleEnabled = true
        line.setCircleColor(.systemBlue)
        line.colors = [UIColor.weightBG]
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        
        setupLineChartView()
        let ll1 = ChartLimitLine(limit: 180, label: "")
        ll1.lineWidth = 1
        ll1.lineColor = UIColor.weightBG
        ll1.lineDashLengths = []
        
        if lineChartView.legend.isEqual(ll1.limit) {
            lineChartView.legend.textColor = .red
        }
        
        let marker = BalloonMarker(color: UIColor.black,
                                   font: .boldSystemFont(ofSize: 11),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        )
        marker.lineChartView = lineChartView
        marker.minimumSize = CGSize(width: 70, height: 40)
        lineChartView.marker = marker
        lineChartView.backgroundColor = UIColor.chartColor
        lineChartView.leftAxis.addLimitLine(ll1)
    }
    
    
    func setupLineChartView(){
        lineChartView.noDataText = "No Data"
        lineChartView.leftAxis.axisMinimum = minimum - 20.0
        lineChartView.leftAxis.axisMaximum = maximum  + 20.0
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelPosition = .top
        lineChartView.xAxis.labelTextColor = UIColor.weightBG
        lineChartView.xAxis.granularity = 1
        lineChartView.highlightPerTapEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.gridLineDashLengths = [3,3]
        lineChartView.xAxis.gridColor = UIColor.weightBG
        lineChartView.xAxis.gridLineDashPhase = 0
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.gridLineDashLengths = []
        lineChartView.leftAxis.gridColor = .white
        lineChartView.leftAxis.gridLineWidth = 1.0
        lineChartView.leftAxis.gridLineDashPhase = 0
        lineChartView.leftAxis.labelFont = .systemFont(ofSize: 13.0)
        lineChartView.drawMarkers = true
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 13.0)
    }
    
}

