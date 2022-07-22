//
//  Extension.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import Foundation
import CoreMotion
import UIKit
extension Double {
    func toString(maximumFractionDigits: Int=0) -> String {
        return String(format: "%.\(maximumFractionDigits)f", self)
    }
    func toInt() -> Int {
        return Int(self)
    }
}
extension Date {
    var yesterday: Date {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: self)
        guard let date = date else { return Date()}
        return date
    }
    var startOfThisDate: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfThisDate)!
    }
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
    func getOnlyDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self)
    }
    func timeBetweenTodayAnd(anotherDay: Date) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let todayString = formatter.string(from: self)
        let anotherDayString = formatter.string(from: anotherDay)
        if let today = formatter.date(from: todayString), let anotherDay = formatter.date(from: anotherDayString) {
            return (today.endOfDay - anotherDay.startOfThisDate) / (60 * 60 * 24)
        }
        return 0
    }
    func getDay(distanceFromToday distance: Int) -> TimeInterval {
        let date = Calendar.current.date(byAdding: .day, value: -distance, to: self)
        guard let date = date else { return Date().timeIntervalSince1970}
        return date.endOfDay.timeIntervalSince1970
    }
}
extension CMPedometerData {
    var distanceUnW: NSNumber {
        guard let distanceUnW = self.distance else { return 0 }
        return distanceUnW
    }
    var mile: String {
        let distance = (distanceUnW.doubleValue / 1000) as NSNumber
        let mile = distance.numberFormatToDecimal(with: .decimal)
        return "\(mile) km"
    }
    var time: String {
        if let avgPace = self.averageActivePace, avgPace.doubleValue != 0 {
            var time: String = ""
            time = (distanceUnW.doubleValue * avgPace.doubleValue / 60).toString()
            print((distanceUnW.doubleValue * avgPace.doubleValue / 60))
            return ("\(time) m")
        } else {
            return "0 m"
        }
    }
    var calories: String {
        let calories = distanceUnW.doubleValue * 70.0 / 1000 * 0.95 
        return ("\(calories.toString()) cal")
    }
    var stokeEnd: Double {
        return self.numberOfSteps.doubleValue / 10000
    }
    var sumStep: String {
        return self.numberOfSteps.numberFormatToDecimal(with: .decimal)
    }

}
extension NSNumber {
    func numberFormatToDecimal(with style: NumberFormatter.Style) -> String {
        let numberNeedFormat = self
        let numberFormatted = NumberFormatter()
        numberFormatted.numberStyle = style
        var result = numberFormatted.string(for: numberNeedFormat)
        guard let result = result else { return "0" }
        return result
    }
}
extension String {
    func currencyConvertToNumber() -> Decimal {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: self) {
            let amount = number.decimalValue
            return amount
        }
        return Decimal()
    }
    func formatString(size: CGFloat, weight: UIFont.Weight) -> NSMutableAttributedString {
        let attrOfUnit = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: weight) ]
        let newUnit = NSMutableAttributedString(string: self, attributes: attrOfUnit)
        return newUnit
    }
}
