//
//  OneDateStepDetailCell.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import UIKit
import CoreMotion
class SumStepCustomLabel: UILabel {
    var displayLinks = CADisplayLink()
    var counterStep = 0.0
    var limit: Double = 0.0
    var indexNeedReload: IndexPath = IndexPath()
    func displayLinkSetupWith(counterStep: Double, maxStep: Double) {
        self.limit = maxStep
         displayLinks = CADisplayLink(target: self, selector: #selector(displayLinkHandleUpdate))
        displayLinks.add(to: .current, forMode: .common)
    }
    @objc func displayLinkHandleUpdate(displayLink: CADisplayLink) {
        if indexNeedReload == IndexPath(row: 6, section: 0) {
            counterStep += Double((limit / 120))
            if counterStep >= limit {
                displayLinks.invalidate()
                updateLabelWith(number: limit)
            } else {
                updateLabelWith(number: counterStep)
            }
        }
    }
    private func updateLabelWith(number: Double) {
        let sumStep = NSNumber(value: number).numberFormatToDecimal(with: .decimal)
        let sumStepArr = sumStep.components(separatedBy: ".")
        self.text = sumStepArr[0]
    }
}
class InfomationWithCirleEdgeView: UIView {
    var progressShape: CAShapeLayer = CAShapeLayer()
    var backgroundShape: CAShapeLayer = CAShapeLayer()
    var completePercentage: Double = 0
    func setupProgessRingWithAnimation(duration: Int, completePercentage: Double) {
        progressShape.removeAllAnimations()
        drawProgressRing(shapeLayer: backgroundShape, completePercentage: 1, strokeColor: UIColor.systemFill.cgColor)
        drawProgressRing(shapeLayer: progressShape, completePercentage: self.completePercentage, strokeColor: UIColor.cyan.cgColor)
        var duration = duration
        if completePercentage > self.completePercentage {
           duration = 0
        }
        self.completePercentage = completePercentage
        let drawingAnimation = drawingAnimation(shapeLayer: progressShape, inTime: duration, with: completePercentage)
        addAnimationToShape(shapeLayer: progressShape, value: completePercentage, animation: drawingAnimation)
    }
    private func drawProgressRing(shapeLayer: CAShapeLayer, completePercentage: Double, strokeColor: CGColor) {
        //UIBezierPath
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                                      radius: (self.bounds.width) / 2 ,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        // circle shape
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 8
        // set start and end values
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = completePercentage
        // add sublayer
        self.layer.addSublayer(shapeLayer)
    }
    private func drawingAnimation(shapeLayer: CAShapeLayer, inTime time: Int, with value: Double ) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = value
        animation.duration = CFTimeInterval(time)
        return animation
    }
    private func addAnimationToShape(shapeLayer: CAShapeLayer, value: Double, animation: CAAnimation) {
        shapeLayer.add(animation, forKey: "animation")
        shapeLayer.strokeEnd = CGFloat(value)
    }
}
class OneDateStepDetailCell: UICollectionViewCell {
    @IBOutlet private weak var infomationCirleEdgeView: UIView!
    @IBOutlet private weak var inforEdgeView: InfomationWithCirleEdgeView!
    @IBOutlet private weak var humanImage: UIImageView!
    @IBOutlet private weak var sumStep: SumStepCustomLabel!
    @IBOutlet private weak var timeline: UILabel!
    @IBOutlet private weak var goal: UILabel!
    @IBOutlet private weak var goalImageL: UIImageView!
    @IBOutlet private weak var bottonInfomationEdgeView: UIView!
    @IBOutlet private weak var caloEdgeView: UIView!
    @IBOutlet private weak var caloImage: UIImageView!
    @IBOutlet private weak var caloBurned: UILabel!
    @IBOutlet private weak var mileEdgeView: UIView!
    @IBOutlet private weak var mileImage: UIImageView!
    @IBOutlet private weak var mile: UILabel!
    @IBOutlet private weak var timeEdgeView: UIView!
    @IBOutlet private weak var timeImage: UIImageView!
    @IBOutlet private weak var time: UILabel!
    var dataOfCell: PedometerDetail?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    // MARK: REUSEABLE UPDATE CELL
    func reuseCellWith(data: PedometerDetail?, indexNeedReload: IndexPath, lastIndex: Int) {
        layoutIfNeeded()
        guard let data = data else { return }
        dataOfCell = data
        loadAnimationForTodayCell(data: data, indexNeedReload: indexNeedReload, lastIndex: lastIndex)
        // circle infor text
        self.timeline.text = data.getTimeline()
        // bottom text
        setupBottomInforText(data: data)
    }
    private func loadAnimationForTodayCell(data: PedometerDetail, indexNeedReload: IndexPath, lastIndex: Int) {
        guard let numberOfStep = data.steps?.currencyConvertToNumber(), let completePercentage = data.completePercentage else { return }
        let limit = NSDecimalNumber(decimal: numberOfStep).doubleValue
        sumStep.indexNeedReload = indexNeedReload
        if isToday(indexNeedReload: indexNeedReload, lastIndex: lastIndex) {
            sumStep.displayLinkSetupWith(counterStep: 0, maxStep: limit)
            // drawing progess ring
            self.inforEdgeView.setupProgessRingWithAnimation(duration: 2, completePercentage: completePercentage)
        } else {
            sumStep.text = limit.toString()
            self.inforEdgeView.setupProgessRingWithAnimation(duration: 0, completePercentage: completePercentage)
        }
    }
    private func isToday(indexNeedReload: IndexPath, lastIndex: Int) -> Bool {
        if indexNeedReload.row == lastIndex {
            return true
        } else {
            return false
        }
    }
    // MARK: FORMAT INFORMATION TEXT PART
    private func setupBottomInforText(data: PedometerDetail) {
        self.mile.text = data.distance
        self.time.text = data.time
        self.caloBurned.text = data.calories
        let labelGroup = [self.time, self.mile, self.caloBurned]
        formatBottomInfoText(labels: labelGroup)
    }
    private func formatBottomInfoText(labels: [UILabel?]) {
        for label in labels {
            guard let label = label, let text = label.text else { return }
            setupLabel(label: label)
            let formattedText = formatMultiAttributeText(textNeedFormat: text)
            label.attributedText = formattedText
        }
    }
    private func setupLabel(label: UILabel) {
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UIColor(named: "labelColor")
    }
    private func formatMultiAttributeText(textNeedFormat: String) -> NSMutableAttributedString {
        let textArr = textNeedFormat.components(separatedBy: " ")
        let newUnit = textArr[1].formatString(size: 15, weight: .medium)
        let newNumber = textArr[0].formatString(size: 20, weight: .medium)
        let separate = NSMutableAttributedString(string: " ")
        newNumber.append(separate)
        newNumber.append(newUnit)
        return newNumber
    }
}
