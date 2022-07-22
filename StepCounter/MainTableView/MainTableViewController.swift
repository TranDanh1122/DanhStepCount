//
//  MainTableViewController.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import UIKit
import CoreMotion
class MainTableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
//    private var viewModel: MainTableViewModel = MainTableViewModel()
//    private var dataSource: [PedometerDetail]? {
//        didSet {
//            guard let dataSource = dataSource else { return }
//            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "reloadTableCellDataWhenShake"), object: nil, userInfo: ["dataSource": dataSource])
////            DispatchQueue.main.async { [unowned self] in
////                tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
////            }
//        }
//    }
    deinit {
//        viewModel.notificationCenter.removeObserver(self, name: viewModel.notificationName, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setupSubcribeObserveble()
        
        // model.setup()
        viewModel.setup()
        viewModel.updateBlock = { data in
            // update view
            // cell.reload()

        }
    }

    
    // MARK: config view
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        register(nibName: "OneWeekStepDetailCell", cellID: "OneWeekStepDetailCell")
        register(nibName: "ChartStepDataCell", cellID: "ChartStepDataCell")
    }
    
    private func register(nibName: String, cellID: String) {
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    // MARK: subcribe data from view model
//    private func setupSubcribeObserveble() {
////        dataSource = viewModel.stepDataSource
//        NotificationCenter.default.addObserver(self, selector: #selector(observebleOnNextHanle(_:)), name: viewModel.notificationName, object: nil)
//    }
//
//    @objc func observebleOnNextHanle(_ noti: Notification) {
//        if let data = noti.userInfo?[viewModel.notificationDataKey] as? [PedometerDetail] {
//            dataSource = data
//        } else {
//            print("cant get data from userInfo, it's nil")
//        }
//    }
    
}
extension MainTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OneWeekStepDetailCell") as? OneWeekStepDetailCell
            guard let cell = cell else { return OneWeekStepDetailCell() }
            cell.layoutIfNeeded()
            cell.reloadData(data: dataSource)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartStepDataCell") as? ChartStepDataCell
            guard let cell = cell, let dataSource = dataSource  else { return ChartStepDataCell() }
            cell.layoutIfNeeded()
            cell.delegate = self
            cell.reloadDataForReuseWith(data: dataSource)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 490
        } else {
            return 150
        }
    }
}
extension MainTableViewController: ChartStepDataDelegate {
    func changeSegmentValueIn(_ chartStepDataCell: ChartStepDataCell, segmentValue: Int) {
        // get cell need update
        let stepDataCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OneWeekStepDetailCell
        guard let stepDataCell = stepDataCell else { return }
        stepDataCell.layout.currentPage = 6 - segmentValue
        // scroll collection to item have index = segment value
        stepDataCell.collectionView.scrollToItem(at: IndexPath(row: segmentValue, section: 0), at: .centeredHorizontally, animated: true)
    }
}
extension MainTableViewController: OneWeekStepDetailCellDelegate {
    func collectionViewDidScrollIn(_ oneWeekStepDetailCell: OneWeekStepDetailCell, currentPage: Int) {
        let chartStepDataCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ChartStepDataCell
        guard let chartStepDataCell = chartStepDataCell, let daySegment =  chartStepDataCell.daySegment else { return }
        daySegment.selectedSegmentIndex = currentPage
        chartStepDataCell.highlightChartPointAt(day: currentPage)
    }
}
