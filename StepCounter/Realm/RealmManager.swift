//
//  RealmManager.swift
//  StepCounter
//
//  Created by VN Grand M on 14/07/2022.
//

import Foundation
import RealmSwift
class RealmManager {
    static var shared = RealmManager()
    var realm: Realm? {
        do {
            return try Realm()
        } catch {
            print(error)
        }
        return nil
    }
    func saveNewRecord(newRecord: PedometerDetail) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(newRecord)
            }
        } catch {
            print(error)
        }
    }
    func getAllPedometerDetail() -> [PedometerDetail] {
        do {
            let realm = try Realm()
            let results = realm.objects(PedometerDetail.self).sorted(byKeyPath: "startDay", ascending: true)
            var pedometerDetails = [PedometerDetail]()
            // code ngu 
            for pedometerDetail in results {
                pedometerDetails.append(pedometerDetail)
            }

            return pedometerDetails
        } catch {
            print(error)
        }
        return [PedometerDetail]()
      
    }
    func deleteAll() {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    func filterWherein(dateArr: [TimeInterval]) -> [PedometerDetail]? {
        do {
            let realm = try Realm()
            let pedometerDetails = realm.objects(PedometerDetail.self).filter(" (startDay IN %@) ", dateArr).sorted(byKeyPath: "startDay", ascending: true)
            var result = [PedometerDetail]()
            for pedometerDetail in pedometerDetails {
                result.append(pedometerDetail)
            }
            return result
        } catch {
            print(error)
        }
        return nil
    }
}
