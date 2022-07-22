//
//  ChartStepDataCell.swift
//  StepCounter
//
//  Created by VN Grand M on 19/07/2022.
//

import UIKit
import Charts
protocol CustomChartViewDelegate: AnyObject {
    func selectedPointInChartView(_ chartView: CustomChartView, with day: Double )
}
class CustomChartView: UIView, ChartViewDelegate {
    var contentChartView: LineChartView = {
        let view = LineChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    weak var delegate: CustomChartViewDelegate?
    func configuraChartViewWith(data: [PedometerDetail]) {
        layoutContentChartView()
        setupChart(data: data)
    }
    private func layoutContentChartView() {
        self.addSubview(contentChartView)
        let topContraint = self.contentChartView.topAnchor.constraint(equalTo: self.topAnchor)
        let bottomContraint = self.contentChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leadContraint = self.contentChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trainContraint = self.contentChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([topContraint, bottomContraint, leadContraint, trainContraint])
    }
    private func initChartData(with stepsData: [PedometerDetail]) -> LineChartData {
        let steps = stepsData.map { $0.steps?.currencyConvertToNumber() ?? 0 }
        var dataEntry = [ChartDataEntry]()
        for day in 0...steps.count - 1 {
            let xvalue = NSDecimalNumber(value: day).doubleValue
            let yvalue = NSDecimalNumber(decimal: steps[day]).doubleValue
            dataEntry.append(ChartDataEntry(x: xvalue, y: yvalue))
        }
        let dataSet = LineChartDataSet(entries: dataEntry)
        let gradientColors = [UIColor.cyan.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        if let gradient = gradient {
            dataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 100)
            dataSet.drawFilledEnabled = true
        }
        dataSet.circleColors = [UIColor.label]
        dataSet.circleHoleColor = UIColor.white
        dataSet.lineWidth = 5
        dataSet.circleRadius = 5
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightEnabled = true
        dataSet.highlightColor = .green
        let lineChartData = LineChartData(dataSet: dataSet)
        return lineChartData
    }
    private func setupChart(data: [PedometerDetail]) {
        let chartData = initChartData(with: data)
        contentChartView.data = chartData
        contentChartView.rightAxis.enabled = false
        contentChartView.leftAxis.enabled = false
        contentChartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        contentChartView.setScaleEnabled(false)
        contentChartView.leftAxis.axisMaximum = 10000
        contentChartView.legend.enabled = false
        contentChartView.delegate = self
        let xAxis = contentChartView.xAxis
        xAxis.drawLabelsEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.yOffset = -10
        //        let xAxisLabel = data.map { Date(timeIntervalSince1970: $0.startDay ?? 0).getOnlyDate() }
        //        xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabel)
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
       
        contentChartView.layer.sublayers = nil
        var realPosition = CGPoint(x: highlight.xPx, y: highlight.yPx)
        // Hack to get the real position of the highlight programaticaly
        // [ -> chưa hiểu lắm, cần làm rõ
        if realPosition.x.isNaN || realPosition.y.isNaN {
            let transformer = contentChartView.getTransformer(forAxis: contentChartView.leftAxis.axisDependency)
            let pixelValueOfEntry = transformer.pixelForValues(x: entry.x, y: entry.y)
            realPosition.x = pixelValueOfEntry.x
            realPosition.y = pixelValueOfEntry.y
        }
        //]
        let ringShape = drawRingAt(positionX: realPosition.x, positionY: realPosition.y)
        contentChartView.layer.addSublayer(ringShape)
        delegate?.selectedPointInChartView(self, with: entry.x)
    }
    private func drawRingAt(positionX: Double, positionY: Double) -> CAShapeLayer {
        let ringShape = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: positionX, y: positionY),
                                      radius: 8,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        // circle shape
        ringShape.path = circlePath.cgPath
        ringShape.strokeColor = UIColor.systemGreen.cgColor
        ringShape.fillColor = UIColor.clear.cgColor
        ringShape.lineWidth = 4
        // set start and end values
        ringShape.strokeStart = 0.0
        ringShape.strokeEnd = 1.0
        return ringShape
    }
}
class CustomSegmentView: UISegmentedControl {
    func setupSegment(with datas: [PedometerDetail]) {
        self.removeAllSegments()
        let numberOfData = datas.count - 1
        for index in 0...numberOfData {
            let day = Date(timeIntervalSince1970: datas[index].startDay ?? 0).getOnlyDate()
            self.insertSegment(withTitle: day, at: index, animated: true)
        }
        self.selectedSegmentTintColor = UIColor.systemGreen
        self.selectedSegmentIndex = numberOfData
    }
}
protocol ChartStepDataDelegate: AnyObject {
    func changeSegmentValueIn(_ chartStepDataCell: ChartStepDataCell, segmentValue: Int)
}
class ChartStepDataCell: UITableViewCell, CustomChartViewDelegate {
    @IBOutlet private var chartView: CustomChartView!
    @IBOutlet var daySegment: CustomSegmentView!
    weak var delegate: ChartStepDataDelegate?
    private var dataChart = [PedometerDetail]()
    override func awakeFromNib() {
        super.awakeFromNib()
        chartView.delegate = self
    }
    func reloadDataForReuseWith(data: [PedometerDetail]) {
        chartView.configuraChartViewWith(data: data)
        dataChart = data
        daySegment.setupSegment(with: data)
    }
    @IBAction func changeValueSegment(_ sender: UISegmentedControl) {
        delegate?.changeSegmentValueIn(self, segmentValue: sender.selectedSegmentIndex)
        print("change segment value")
        let segmentValue = sender.selectedSegmentIndex
        highlightChartPointAt(day: segmentValue)
    }
    func highlightChartPointAt(day segmentValue: Int) {
        if !dataChart.isEmpty, dataChart.count - 1 >= segmentValue {
            guard let steps = dataChart[segmentValue].steps?.currencyConvertToNumber() else { return }
            let stepAtThisPoint = NSDecimalNumber(decimal: steps).doubleValue
            self.chartView.contentChartView.highlightValue(Highlight(x: Double(segmentValue), y: stepAtThisPoint, dataSetIndex: 0), callDelegate: true)
        }
    }
    // conform CustomChartViewDelegate delegate
    func selectedPointInChartView(_ chartView: CustomChartView, with day: Double) {
        delegate?.changeSegmentValueIn(self, segmentValue: Int(day))
        daySegment.selectedSegmentIndex = Int(day)
    }
}
