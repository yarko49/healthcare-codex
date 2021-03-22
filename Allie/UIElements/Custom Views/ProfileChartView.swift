//
//  Profileswift
//  Allie
//

import Charts
import Foundation
import UIKit

class ProfileChartView: LineChartView {
	private var numberFormatter: NumberFormatter = {
		let nf = NumberFormatter()
		nf.numberStyle = .decimal
		return nf
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupChartView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupChartView()
	}

	var chartMin, chartMax: Double?
	let baseLine = ChartLimitLine(limit: 0.0)

	private func setupChartView() {
		legend.enabled = false
		xAxis.labelPosition = .top
		xAxis.labelTextColor = .weightBackground
		xAxis.yOffset = 5
		highlightPerTapEnabled = true
		xAxis.drawAxisLineEnabled = false
		xAxis.gridLineDashLengths = [4, 3]
		xAxis.gridColor = .weightBackground
		xAxis.gridLineDashPhase = 0
		leftAxis.drawAxisLineEnabled = false
		leftAxis.gridColor = .white
		leftAxis.gridLineWidth = 1.0
		leftAxis.gridLineDashPhase = 0
		leftAxis.labelFont = .systemFont(ofSize: 13.0)
		leftAxis.labelTextColor = .dark60
		extraRightOffset = 18
		leftAxis.xOffset = 18
		drawMarkers = true
		xAxis.labelFont = .boldSystemFont(ofSize: 13.0)
	}

	func setup(with healthData: [StatModel], quantityType: HealthKitQuantityType, intervalType: HealthStatsDateIntervalType, goal: Int) {
		guard let statModel = healthData.first, let firstDate = statModel.dataPoints.first?.date, let lastDate = statModel.dataPoints.last?.date else { data = nil; return }

		rightAxis.enabled = false

		switch intervalType {
		case .yearly:
			xAxis.axisMinimum = 1
			xAxis.axisMaximum = 12
			xAxis.valueFormatter = YearXaxisValueFormatter()
		case .monthly:
			xAxis.axisMinimum = 1
			xAxis.axisMaximum = Double(Calendar.current.range(of: .day, in: .month, for: firstDate)?.count ?? 30)
			let month = Calendar.current.component(.month, from: firstDate)
			xAxis.valueFormatter = MonthXaxisValueFormatter(month: month)
		default:
			xAxis.axisMinimum = firstDate.timeIntervalSinceReferenceDate
			xAxis.axisMaximum = lastDate.timeIntervalSinceReferenceDate
			xAxis.valueFormatter = XaxisValueFormatter(dateFormat: getDateFormat(for: intervalType))
		}

		xAxis.granularityEnabled = true
		xAxis.granularity = 1

		let numberOfLabels = getNumberOfLabels(for: intervalType, entries: statModel.dataPoints.filter { $0.value != nil }.count)
		xAxis.setLabelCount(numberOfLabels.0, force: numberOfLabels.1)
		leftAxis.valueFormatter = YaxisValueFormatter(formatter: numberFormatter)
		leftAxis.granularityEnabled = false
		doubleTapToZoomEnabled = false

		var chartDataSets: [LineChartDataSet] = []
		var chartIntervalType: ChartIntervalType = .week

		healthData.enumerated().forEach { offset, model in
			let entries = model.dataPoints.enumerated().compactMap { (_, dataPoint) -> ChartDataEntry? in
				if let doubleValue = dataPoint.value?.doubleValue(for: quantityType.hkUnit) {
					var xValue: Double {
						switch intervalType {
						case .weekly:
							return dataPoint.date.timeIntervalSinceReferenceDate
						case .monthly:
							let components = Calendar.current.dateComponents([.month, .day, .year], from: dataPoint.date)
							var intervalComponents = DateComponents()
							intervalComponents.month = components.month
							intervalComponents.year = components.year
							chartIntervalType = .month(components: intervalComponents)
							return Double(components.day ?? 1)
						case .yearly:
							let components = Calendar.current.dateComponents([.month, .year], from: dataPoint.date)
							var intervalComponents = DateComponents()
							intervalComponents.year = components.year
							chartIntervalType = .year(components: intervalComponents)
							return Double(components.month ?? 1)
						default: return dataPoint.date.timeIntervalSinceReferenceDate
						}
					}
					return ChartDataEntry(x: xValue, y: doubleValue)
				}
				return nil
			}

			let chartDataSet = LineChartDataSet(entries: entries)
			chartMin = chartDataSet.yMin
			chartMax = chartDataSet.yMax
			chartDataSet.highlightColor = .clear
			chartDataSet.setDrawHighlightIndicators(true)
			chartDataSet.circleRadius = 4.0
			chartDataSet.circleHoleColor = .white
			chartDataSet.circleHoleRadius = 2.5
			chartDataSet.valueTextColor = NSUIColor.clear
			chartDataSet.lineWidth = 2.0
			chartDataSet.drawCircleHoleEnabled = true

			if quantityType == .bloodPressure, offset == 1 {
				chartDataSet.setCircleColor(.systemGreen)
				chartDataSet.colors = [.systemGreen]
			} else {
				chartDataSet.setCircleColor(.systemBlue)
				chartDataSet.colors = [UIColor.weightBackground]
			}
			chartDataSets.append(chartDataSet)
		}

		setUpBaseline(min: chartMin ?? 0.0, max: chartMax ?? 0.0, dataSets: chartDataSets, goal: goal)
		let balloonMarker = BalloonMarker(color: UIColor.black,
		                                  font: .boldSystemFont(ofSize: 11),
		                                  textColor: .white,
		                                  insets: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4),
		                                  unit: quantityType.unit,
		                                  numberFormatter: numberFormatter, intervalType: chartIntervalType)
		balloonMarker.chartView = self
		marker = balloonMarker
	}

	func getNumberOfLabels(for intervalType: HealthStatsDateIntervalType, entries: Int) -> (Int, Bool) {
		switch intervalType {
		case .daily: return (0, false)
		case .weekly: return (7, true)
		case .monthly:
			return (min(entries, 6), false)
		case .yearly: return (12, true)
		}
	}

	func setUpBaseline(min: Double, max: Double, dataSets: [LineChartDataSet], goal: Int) {
		baseLine.limit = Double(goal)
		leftAxis.axisMinimum = baseLine.limit < min ? baseLine.limit - 10.0 : min
		leftAxis.axisMaximum = baseLine.limit > max ? baseLine.limit + 10.0 : max
		baseLine.lineWidth = 1
		baseLine.valueTextColor = .weightBackground
		baseLine.valueFont = .boldSystemFont(ofSize: 13.0)
		baseLine.lineColor = .weightBackground
		baseLine.drawLabelEnabled = false
		leftAxis.addLimitLine(baseLine)
		data = LineChartData(dataSets: dataSets)
	}

	func getDateFormat(for intervalType: HealthStatsDateIntervalType) -> String {
		switch intervalType {
		case .weekly: return "EEEEEE"
		case .monthly: return "M/dd"
		case .yearly: return "MMMMM"
		default:
			return "EEEEEE"
		}
	}
}

private class XaxisValueFormatter: NSObject, IAxisValueFormatter {
	private let dateFormatter = DateFormatter()

	init(dateFormat: String) {
		dateFormatter.dateFormat = dateFormat
		super.init()
	}

	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value)).uppercased()
	}
}

private class MonthXaxisValueFormatter: NSObject, IAxisValueFormatter {
	private let dateFormatter = DateFormatter()
	let month: Int

	init(month: Int) {
		self.month = month
		super.init()
	}

	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		var components = DateComponents()
		components.month = month
		components.day = Int(value)
		dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM", options: 0, locale: Locale.current)
		let date = Calendar.current.date(from: components) ?? Date()
		return dateFormatter.string(from: date)
	}
}

private class YearXaxisValueFormatter: NSObject, IAxisValueFormatter {
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let monthNames = Calendar.current.veryShortStandaloneMonthSymbols
		let monthIndex = Int(value) - 1
		guard monthNames.count > monthIndex else { return "" }
		return monthNames[monthIndex]
	}
}

private class YaxisValueFormatter: NSObject, IAxisValueFormatter {
	private var numberFormatter: NumberFormatter

	init(formatter: NumberFormatter) {
		self.numberFormatter = formatter
		super.init()
	}

	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let number = NSNumber(value: Int(value))
		return numberFormatter.string(from: number) ?? ""
	}
}

enum ChartIntervalType {
	case day
	case week
	case month(components: DateComponents)
	case year(components: DateComponents)
}
