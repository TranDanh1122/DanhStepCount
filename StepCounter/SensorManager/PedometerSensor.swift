//
//  PedometerSensor.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import Foundation
import CoreMotion
class PedometerSensor {
    static var pedometerStaticObject: PedometerSensor = PedometerSensor()
    private var sensor: CMPedometer = CMPedometer()
    final func startUpdate(from startDate: Date, with handle: @escaping CMPedometerHandler) {
        if isStepCountingAvailable() {
            sensor.startUpdates(from: startDate, withHandler: handle)
        } else {
            print("step counting not available")
        }
    }
    final func getStep(from startDate: Date, to endDate: Date, with hanle: @escaping CMPedometerHandler) {
        if isStepCountingAvailable() {
        sensor.queryPedometerData(from: startDate, to: endDate, withHandler: hanle)
        } else {
            print("step counting not available")
        }
    }
    private func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
}
