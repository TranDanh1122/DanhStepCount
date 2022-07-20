//
//  ChartStepDataCell.swift
//  StepCounter
//
//  Created by VN Grand M on 19/07/2022.
//

import UIKit
import Charts
class CustomChartView: UIView {
    var contentChartView: LineChartView = {
        let view = LineChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    func configuraChartViewWith(data: [PedometerDetail]) {
        layoutContentChartView()
        setupChartData(data: data)
        let data = initChartData(data)
        contentChartView.data = data
    }
    private func layoutContentChartView() {
        self.addSubview(contentChartView)
        let topContraint = self.contentChartView.topAnchor.constraint(equalTo: self.topAnchor)
        let bottomContraint = self.contentChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leadContraint = self.contentChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trainContraint = self.contentChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([topContraint, bottomContraint, leadContraint, trainContraint])
    }
    private func initChartData(_ stepsData: [PedometerDetail]) -> LineChartData {
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
        dataSet.circleHoleColor = UIColor.label
        dataSet.lineWidth = 5
        dataSet.circleRadius = 5
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightEnabled = true
        dataSet.highlightColor = .green
        let lineChartData = LineChartData(dataSet: dataSet)
        return lineChartData
    }
    private func setupChartData(data: [PedometerDetail]) {
        contentChartView.rightAxis.enabled = false
        contentChartView.leftAxis.enabled = false
        contentChartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        contentChartView.leftAxis.axisMaximum = 10000
        contentChartView.legend.enabled = false
        let xAxis = contentChartView.xAxis
        xAxis.drawLabelsEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.drawAxisLineEnabled = false
        xAxis.yOffset = -10
        //        let xAxisLabel = data.map { Date(timeIntervalSince1970: $0.startDay ?? 0).getOnlyDate() }
        //        xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabel)
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
        self.selectedSegmentIndex = numberOfData
    }
}
protocol ChartStepDataDelegate: AnyObject {
    func changeSegmentValueIn(_ chartStepDataCell: ChartStepDataCell, segmentValue: Int)
}
class ChartStepDataCell: UITableViewCell {
    @IBOutlet private var chartView: CustomChartView!
    @IBOutlet var daySegment: CustomSegmentView!
    weak var delegate: ChartStepDataDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func reloadDataForReuseWith(data: [PedometerDetail]) {
        chartView.configuraChartViewWith(data: data)
        daySegment.setupSegment(with: data)
    }
    @IBAction func changeValueSegment(_ sender: UISegmentedControl) {
        delegate?.changeSegmentValueIn(self, segmentValue: sender.selectedSegmentIndex)
    }
}
