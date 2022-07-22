//
//  MainTableViewModel.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import Foundation
import CoreMotion
class MainTableViewModel {
    let notificationCenter = NotificationCenter.default
    let notificationName = Notification.Name.init(rawValue: "pushdata")
    let notificationDataKey: String = "stepdetail"
    var stepDataSource: [PedometerDetail]? = [PedometerDetail]() {
        didSet {
            guard let stepDataSource = stepDataSource else { return }
            notifyDataChange(dataSource: stepDataSource)
        }
    }
    
    init() {
        setupStepCounterLogic()
        setupDataSource()
        updateTodayStep()
    }
    
    // MARK: LOGIC PART
    
    func setupStepCounterLogic() {
        //tạo mảng 6 ngày trước kể từ hôm nay
        let sixDatesBefore = getSixDayInHistory()
        // query data từ db
        let listOfPedometerData = RealmManager.shared.filterWherein(dateArr: sixDatesBefore)
        guard let listOfPedometerData = listOfPedometerData else { return }
        if isFirstUse(historyData: listOfPedometerData) {
            saveFirstUseData(sixDatesBefore: sixDatesBefore)
        } else {
            // nếu có data nhưng số lượng < 5 có nghĩa là sử dụng trong vòng 7 ngày
            guard let lastDay = listOfPedometerData.last?.startDay else { return  }
            // khoảng cách từ ngày sử dụng gần nhất
            let distance = Date().endOfDay.timeIntervalSince1970 - lastDay
            // lưu data mấy cái ngày bị thiếu
            saveMissingData(notUsetime: distance)
        }
    }
    
    private func getSixDayInHistory() -> [TimeInterval] {
        var theSixDateBefore = [TimeInterval]()
        for distance in 1...6 {
            theSixDateBefore.append(Date().getDay(distanceFromToday: distance))
        }
        return theSixDateBefore
    }
    
    private func isFirstUse(historyData: [PedometerDetail]) -> Bool {
        if historyData.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    private func saveFirstUseData(sixDatesBefore: [TimeInterval]) {
        for aDay in sixDatesBefore {
            let startDay = Date(timeIntervalSince1970: aDay ).startOfThisDate
            let endDay = Date(timeIntervalSince1970: aDay ).endOfDay
            saveSensorDataOf(startDay: startDay, endDay: endDay)
        }
    }
    
    private func saveMissingData(notUsetime: Double) {
        let numberOfDate = notUsetime / 86400
        // lưu data mấy cái ngày chưa lưu
        for oneDate in 1..<numberOfDate.toInt() {
            let interval = Date(timeIntervalSince1970: Date().getDay(distanceFromToday: oneDate))
            let startDay = interval.startOfThisDate
            let endDay = interval.endOfDay
            saveSensorDataOf(startDay: startDay, endDay: endDay)
        }
    }
    
    private func saveSensorDataOf(startDay: Date, endDay: Date) {
        let handle: CMPedometerHandler = {pedometerData, error in
            DispatchQueue.main.async {
                guard let pedometerData = pedometerData else { return }
                self.saveToDB(pedometerData: pedometerData)
                let datasInDB = RealmManager.shared.getAllPedometerDetail()
                if self.fistUseSaveDataFinished(dataSaved: datasInDB) {
                    self.setupDataSource()
                }
            }
        }
        PedometerSensor.pedometerStaticObject.getStep(from: startDay, to: endDay, with: handle)
    }
    
    private func saveToDB(pedometerData: CMPedometerData) {
        let newPedometerRecord = PedometerDetail().setDetail(from: pedometerData)
        RealmManager.shared.saveNewRecord(newRecord: newPedometerRecord)
    }
    
    private func fistUseSaveDataFinished(dataSaved: [PedometerDetail]) -> Bool {
        if dataSaved.count >= 6 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: SETUP DATA SOURCE PART
    
    func setupDataSource() {
        appendHistoryData()
        appendTodayData()
    }
    
    private func appendHistoryData() {
        let daysInHistory = getSixDayInHistory()
        let result = RealmManager.shared.filterWherein(dateArr: daysInHistory)
        self.stepDataSource = result
    }
    
    private func appendTodayData() {
        let startDay = Date().startOfThisDate
        let endDay = Date().endOfDay
        let handle: CMPedometerHandler = {pedometerData, error in
            let todayUpdateScreen = PedometerDetail().setDetail(from: pedometerData)
            self.stepDataSource?.append(todayUpdateScreen)
        }
        PedometerSensor.pedometerStaticObject.getStep(from: startDay, to: endDay, with: handle)
    }
    
    // MARK: HANLE IF TODAY DATA CHANGE
    
    private func updateTodayStep() {
        let handle: CMPedometerHandler = { [unowned self] _, _ in
            // không biết tại sao run time của hàm start update bị sai nên buộc p gọi hàm queryPedometer mỗi khi có update -> cần chỉnh sửa
            PedometerSensor.pedometerStaticObject.getStep(from: Date().startOfThisDate, to: Date(), with: { [unowned self] pedometerData, error in
                if error == nil {
                    let newTodayData = PedometerDetail().setDetail(from: pedometerData)
                    updateLastItemOfDataSource(newTodayData: newTodayData) // item cuối cùng của datasource là của ngày hôm nay
                }
            })
        }
        PedometerSensor.pedometerStaticObject.startUpdate(from: Date().startOfThisDate, with: handle)
    }
    
    private func updateLastItemOfDataSource(newTodayData: PedometerDetail) {
        if let lastItem = stepDataSource?.last, let lastIndex = stepDataSource?.lastIndex(of: lastItem) {
            stepDataSource?[lastIndex] = newTodayData
        }
    }
    
    // MARK: HANLE DATA SOURCE CHANGING PART
    
    private func notifyDataChange(dataSource: [PedometerDetail]) {
        notificationCenter.post(name: notificationName, object: nil, userInfo: [notificationDataKey: dataSource])
    }
}
