//
//  RealmDB.swift
//  StepCounter
//
//  Created by VN Grand M on 14/07/2022.
//

import Foundation
import RealmSwift
import CoreMotion
class PedometerDetail: Object {
    @Persisted(primaryKey: true) private var identifier: String?
    @Persisted  var distance: String? = "0 mil"
    @Persisted  var steps: String? = "0"
    @Persisted  var time: String? = "0 m"
    @Persisted  var calories: String? = "0 Kcal"
    @Persisted  var startDay: TimeInterval? = 0.0
    @Persisted  var completePercentage: Double?
    func setDetail(from data: CMPedometerData?) -> PedometerDetail {
        guard let data = data else { return PedometerDetail()}
        self.identifier = UUID().uuidString
        self.steps = data.sumStep
        self.distance = data.mile
        self.time = data.time
        self.calories = data.calories
        self.startDay = data.endDate.endOfDay.timeIntervalSince1970
        self.completePercentage = data.stokeEnd
        return self
    }
    func getStarDay() -> TimeInterval {
        guard let startDay = self.startDay else { return 0.0 }
        return startDay
    }
    func getTimeline() -> String {
        guard let startDay = self.startDay else { return "Today"}
        if startDay != 0 {
          return Date(timeIntervalSince1970: startDay).formatDate()
        } else {
           return Date().formatDate()
        }
    }
}
