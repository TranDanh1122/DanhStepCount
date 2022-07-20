//
//  OneDateStepDetailCell.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import UIKit
import CoreMotion
class SumStepCustomLabel: UILabel {
    let displayLinks = CADisplayLink()
    var counterStep = 0.0
    var limit: Double = 0.0
    func displayLinkSetupWith(counterStep: Double, maxStep: Double) {
        self.limit = maxStep
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkHandleUpdate))
        displayLink.add(to: .current, forMode: .common)
    }
    
    @objc func displayLinkHandleUpdate(displayLink: CADisplayLink) {
        counterStep += Double((limit / 120))
        if counterStep >= limit {
            displayLink.invalidate()
            updateLabelWith(number: limit)
        } else {
            updateLabelWith(number: counterStep)
        }
    }
    
    private func updateLabelWith(number: Double) {
        let sumStep = NSNumber(value: number).numberFormatToDecimal(with: .decimal)
        let sumStepArr = sumStep.components(separatedBy: ".")
        self.text = sumStepArr[0]
    }
    
}
class InfomationWithCirleEdgeView: UIView {
    var circleShape: CAShapeLayer = CAShapeLayer()
    var completePercentage: Double = 0
    func setupProgessRingWithAnimation(duration: Int, completePercentage: Double) {
        circleShape.removeAllAnimations()
        drawProgressRing(completePercentage: self.completePercentage)
        self.completePercentage = completePercentage
        addAnimationToShape(value: completePercentage, animation: drawingAnimation(inTime: duration, with: completePercentage))
    }
    private func drawProgressRing(completePercentage: Double) {
        //UIBezierPath
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                                      radius: (self.bounds.width) / 2 ,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        // circle shape
        circleShape.path = circlePath.cgPath
        circleShape.strokeColor = UIColor.cyan.cgColor
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.lineWidth = 8
        // set start and end values
        circleShape.strokeStart = 0.0
        circleShape.strokeEnd = completePercentage
      
        // add sublayer
        self.layer.addSublayer(circleShape)
    }
    private func drawingAnimation(inTime time: Int, with value: Double ) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = self.circleShape.strokeEnd
        animation.toValue = value
        animation.duration = CFTimeInterval(time)
        return animation
    }
    private func addAnimationToShape(value: Double, animation: CAAnimation) {
        self.circleShape.add(animation, forKey: "animation")
        self.circleShape.strokeEnd = CGFloat(value)
    }
}
class OneDateStepDetailCell: UICollectionViewCell {
    @IBOutlet private weak var infomationCirleEdgeView: InfomationWithCirleEdgeView!
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
        if isToday(indexNeedReload: indexNeedReload, lastIndex: lastIndex) {
            sumStep.displayLinkSetupWith(counterStep: 0, maxStep: limit)
            // drawing progess ring
            self.infomationCirleEdgeView.setupProgessRingWithAnimation(duration: 2, completePercentage: completePercentage)
        } else {
            sumStep.text = limit.toString()
            self.infomationCirleEdgeView.setupProgessRingWithAnimation(duration: 0, completePercentage: completePercentage)
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
