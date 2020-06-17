//
//  Charts.swift
//  alfred-ios


import Foundation
import UIKit
import Charts
import CoreGraphics
import QuartzCore

class Charts : BaseVC, UIGestureRecognizerDelegate {
    
    var closeAction: (()->())?
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var scatterChartView: ScatterChartView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    
    var shouldScrollToBottom = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //shouldScrollToBottom = false
        
        //prepareScrollView()

        self.scrollView.addSubview(contentView)
        self.scrollView.contentSize = self.contentView.frame.size
        //scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollsToTop = true
        
        scrollView.isPagingEnabled = true
        
        //view.isUserInteractionEnabled = false
        
        let closeBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeTapped(_:)))
        navigationItem.leftBarButtonItem = closeBtn
//
//        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(Charts.panGesture))
//        view.addGestureRecognizer(gesture)
//
//        gesture.delegate = self
        
        let line1 : [Double] = [180, 270, 150, 190, 220, 170, 220, 230, 240, 260, 250, 230, 280, 290]
        let line2 : [Double] = [150, 230, 150, 250, 220, 290, 220, 240, 260, 180, 230, 300, 170, 290]
        let line3 : [Double] = [210, 170, 300, 160, 190, 240, 150, 280, 230, 220, 180, 290, 250, 260]
        
        setBarChart(xValues: ["12/1", "12/2", "12/3", "12/4", "12/5", "12/6", "12/7", "12/8", "12/9" ,"12/10", "12/11", "12/12"], yValues: [[1,2,3,4,5,6,7,8,9,10,11,12], [2,2,2,2,2,2,2,2,2,2,2,2], [4,2,2,2,2,2,2,1,1,1,1,1]]) // Example
        setScatterChart(xValues: ["12/1", "12/2", "12/3", "12/4", "12/5", "12/6", "12/7", "12/8", "12/9" ,"12/10", "12/11", "12/12"], yValues: [[1,2,3,4,5,6,7,8,9,10,11,12], [2,-1,-1,4,6,-1,8,10,14,-1,16,18]]) // Set values you don't want to display as -1?
        
        setLineChart(xValues: ["Mon", "Tue", "Wen", "Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wen", "Thu", "Fri", "Sat", "Sun"], yValues: [line1, line2, line3])
        
        
    }
    
  override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)

    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)


    }
    
    
    func setBarChart(xValues: [String], yValues: [[Double]]) {
        let dataEntries = (0..<xValues.count).map { (i) -> BarChartDataEntry in
            var yVals: [Double] = []
            for j in 0..<yValues.count {
                yVals.append(yValues[j][i])
            }

            return BarChartDataEntry(x: Double(i), yValues: yVals)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Target : 30m")
        
        chartDataSet.drawValuesEnabled = false
        
        let colors = [UIColor.green, UIColor.systemGreen, UIColor.systemPink]
        chartDataSet.colors = colors
        
        let barChartData = BarChartData(dataSet: chartDataSet)
        

        
        barChartView.noDataText = "No Data"
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.labelPosition = .bottom
        barChartView.legend.enabled = false
        
        
        
        let ll = ChartLimitLine(limit: 10.0, label: "")
        barChartView.leftAxis.addLimitLine(ll)
        
        barChartView.data = barChartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        barChartView.xAxis.granularity = 1
        barChartView.animate(yAxisDuration: 1)
    }
    
    func setScatterChart(xValues: [String], yValues: [[Double]]) {
        
        var chartDataSets: [ScatterChartDataSet] = []
        
        for yValue in yValues {
          
            let dataEntries = (0..<xValues.count).map { (i) -> ChartDataEntry in
                
                return ChartDataEntry(x: Double(i), y: yValue[i])
            }
            
            let chartDataSet = ScatterChartDataSet(entries: dataEntries, label: "80-120")
            
            let colors = [UIColor.red]
            chartDataSet.colors = colors
            chartDataSet.setScatterShape(.circle)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.scatterShapeSize = 8
            
            chartDataSets.append(chartDataSet)
        }
        
        let chartData = ScatterChartData(dataSets: chartDataSets)
        
        scatterChartView.noDataText = "No Data"
        scatterChartView.leftAxis.axisMinimum = 0
        scatterChartView.rightAxis.enabled = false
        scatterChartView.xAxis.labelPosition = .bottom
        //scatterChartView.legend.enabled = true

        scatterChartView.gridBackgroundColor = UIColor.red // Placeholder, will be removed.
        scatterChartView.drawGridBackgroundEnabled = false
        
        scatterChartView.data = chartData
    
        scatterChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        scatterChartView.xAxis.granularity = 1
        scatterChartView.animate(yAxisDuration: 1)
        //scatterChartView.legend.textColor = NSUIColor.orange
        //scatterChartView.legend.
        
        
        let first:ChartLimitLine = ChartLimitLine(limit: Double(15), label: "")
        first.lineWidth = 1
        first.lineColor = UIColor.white.withAlphaComponent(0)
        first.lineDashLengths = []
        first.lineDashPhase = 0.0
        
        
        let second:ChartLimitLine = ChartLimitLine(limit: Double(6), label: "")
        second.lineWidth = 1
        second.lineColor = UIColor.white.withAlphaComponent(0)
        second.lineDashLengths = []
        second.lineDashPhase = 0.0
        
        
        scatterChartView.leftAxis.addLimitLine(first)
        scatterChartView.leftAxis.addLimitLine(second)
        scatterChartView.leftAxis.drawGridLinesEnabled = true
        
        scatterChartView.leftYAxisRenderer = CustomYAxisRenderer(viewPortHandler: scatterChartView.viewPortHandler!, yAxis: scatterChartView.leftAxis, transformer: scatterChartView.getTransformer(forAxis: .left))
      
        
    }
    
    
    func setLineChart(xValues : [String], yValues : [[Double]]) {
        let data = LineChartData()
        var lineChartEntry1 = [ChartDataEntry]()
        var lineChartEntry2 = [ChartDataEntry]()
        var lineChartEntry3 = [ChartDataEntry()]
        
        for i in 0..<xValues.count {
            let value1 = ChartDataEntry( x : Double(i), y : Double(yValues[0][i]) )
            lineChartEntry1.append(value1)
            lineChartEntry2.append(ChartDataEntry(x : Double(i), y: Double(yValues[1][i])))
            lineChartEntry3.append(ChartDataEntry(x :Double(i), y : Double(yValues[2][i])))
            
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntry1, label : "Weight")
        data.addDataSet(line1)
       

        let line2 = LineChartDataSet(entries: lineChartEntry2, label : "Heart Rate")
        data.addDataSet(line2)
        
        let line3 = LineChartDataSet(entries : lineChartEntry3, label : "Activity")
        data.addDataSet(line3)
        
        let lineMatrix = [line1, line2, line3]
        
        lineChartView.data = data
        
        
        for line in lineMatrix {
            
            line.drawFilledEnabled = false
            line.setDrawHighlightIndicators(true)
            line.setColor(NSUIColor.black)
            line.circleColors = [NSUIColor.black]
            line.circleHoleColor = NSUIColor.black
            line.circleRadius = 0.1
            line.valueTextColor =  NSUIColor.clear
            line.lineWidth = 1.0
            
            if line == line1 {
                
                line.colors = [NSUIColor.systemPurple]
                
            }else if line == line2 {
                
                line.colors = [NSUIColor.systemOrange]
            }
                else {
                
                line.colors = [NSUIColor.systemBlue]
                
                }
            }
            

    lineChartView.noDataText = "No Data"
    lineChartView.leftAxis.axisMinimum = 120
    lineChartView.rightAxis.enabled = false
    lineChartView.xAxis.labelPosition = .bottom
    lineChartView.legend.enabled = false
    lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
    lineChartView.xAxis.labelTextColor = .clear
    lineChartView.xAxis.granularity = 1
    lineChartView.highlightPerTapEnabled = true
        //lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.legend.enabled = true
        
        lineChartView.legend.drawInside = false


        lineChartView.legend.direction = .leftToRight
        lineChartView.legend.horizontalAlignment = .center

        lineChartView.legend.verticalAlignment = .bottom
        lineChartView.legend.orientation = .vertical
        lineChartView.legend.yEntrySpace = 0.56

        
        let first:ChartLimitLine = ChartLimitLine(limit: Double(200), label: "")
        first.lineWidth = 1
        first.lineColor = UIColor.white.withAlphaComponent(0)
        first.lineDashLengths = []
        first.lineDashPhase = 0.0
        
        
        let second:ChartLimitLine = ChartLimitLine(limit: Double(175), label: "")
        second.lineWidth = 1
        second.lineColor = UIColor.white.withAlphaComponent(0)
        second.lineDashLengths = []
        second.lineDashPhase = 0.0
        
        
        
        lineChartView.leftAxis.addLimitLine(first)
        lineChartView.leftAxis.addLimitLine(second)
        lineChartView.leftAxis.drawGridLinesEnabled = false
        
        
        lineChartView.leftYAxisRenderer = CustomYAxisRenderer(viewPortHandler: lineChartView.viewPortHandler!, yAxis: lineChartView.leftAxis, transformer: lineChartView.getTransformer(forAxis: .left))
        
    }
    
    


//CustomYAxisRenderer(viewPortHandler: ViewPortHandler, yAxis: YAxis, transformer: Transformer)

     // The whole way this screen is presented is a WIP. Will likely change entirely.
//    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: self.view)
//
//        UIView.animate(withDuration: 0.20){
//
//        let y = self.view.frame.midY //.minY
//            self.view.frame = CGRect(x: 0, y: y + translation.y, width: self.view.frame.width, height: self.view.frame.height)
//
//
//        recognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
//    }
//
    
    @objc private func closeTapped(_ sender: UIBarButtonItem) {
        closeAction?()
    }

}

