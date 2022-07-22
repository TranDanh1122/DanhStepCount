//
//  OneWeekStepDetailCell.swift
//  StepCounter
//
//  Created by VN Grand M on 11/07/2022.
//

import UIKit
import CoreMotion
class CollectionViewCustomLayout: UICollectionViewFlowLayout {
    static var shared: CollectionViewCustomLayout = CollectionViewCustomLayout()
    var currentPage: Int = 0
    var oldOffset: CGFloat = 0.0
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collection = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let numberOfItemInSection = collection.numberOfItems(inSection: 0)
        //[ -> dùng cho lần đầu tiên scroll sau khi chuyển ngày bằng segment -> không hiểu lắm
        if collection.contentOffset.x > oldOffset, velocity.x < 0.0 {
            currentPage = max(currentPage - 1, 0)
        } else if collection.contentOffset.x < oldOffset, velocity.x > 0.0 {
            currentPage = min(currentPage + 1, numberOfItemInSection-1)
        }
        //]
        //lướt qua trái
        if collection.contentOffset.x > oldOffset, velocity.x > 0.0 {
            currentPage = min(currentPage + 1, numberOfItemInSection-1)
        } else if collection.contentOffset.x < oldOffset, velocity.x < 0.0 { //lướt qua phải
            /*                contentoffset
                  oldoffset ---------------
             ---------------|-------------|---------
             |              |             |
             |              |             |
             ---------------|-------------|---------
                                --- scroll velocty
                            ---------------
             */
            currentPage = max(currentPage - 1, 0)
        }
        // chiều rôngj của collection
        let collectionWidth = collection.frame.width
        // chiều rộng của 1 cái item
        let itemWidth = itemSize.width
        // khoảng cánh giữa mấy cái item
        let spacing = minimumLineSpacing
        // độ rộng 2 biên ngoài cùng
        let edge = (collectionWidth - itemWidth - spacing * 2)/2
        // vị trí hiện tại  = (độ rộng item + khoảng cách giữa 2 item) * số trang hiện tại - (biên + khoảng cách giữa 2 item)
        let offset = (itemWidth + spacing)  * CGFloat(currentPage) - (edge + spacing)
        oldOffset = offset
        // y không đổi vì sẽ lăn theo chiều ngang
        return CGPoint(x: offset, y: proposedContentOffset.y)
    }
}
protocol OneWeekStepDetailCellDelegate: AnyObject {
    func collectionViewDidScrollIn(_ oneWeekStepDetailCell: OneWeekStepDetailCell, currentPage: Int)
}
class OneWeekStepDetailCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    private var collectionViewDataSource: [PedometerDetail]?
    private var notificationName = Notification.Name.init(rawValue: "reloadTableCellDataWhenShake")
    let layout = CollectionViewCustomLayout.shared
    weak var delegate: OneWeekStepDetailCellDelegate?
    private var oldPage: Int = 0
    //deinit
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubview()
        observableUpdateDataEvent()
    }
    // MARK: REUSEABLE RELOAD CELL
    func reloadData(data: [PedometerDetail]?) {
        guard let data = data else { return }
        collectionViewDataSource = data
        collectionView.reloadData()
    }
    // MARK: COLLECTIONVIEW SETUP
    private func setupSubview() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 490)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        register(cellName: "OneDateStepDetailCell")
    }
    private func register(cellName: String) {
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
    }
    // MARK: OBSERVE DATA SOURCE CHANGE SETUP
    private func observableUpdateDataEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataWhenDataSourceUpdate(_:)), name: notificationName, object: nil)
    }
    @objc func reloadDataWhenDataSourceUpdate(_ noti: Notification) {
        if let data = noti.userInfo?["dataSource"] as? [PedometerDetail] {
            DispatchQueue.main.async {
                self.collectionViewDataSource = data
                self.collectionView.reloadData()
            }
        } else {
            print("data error")
        }
    }
    
}
extension OneWeekStepDetailCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneDateStepDetailCell", for: indexPath) as? OneDateStepDetailCell
        guard let cell = cell else { return OneDateStepDetailCell() }
        let cellData = collectionViewDataSource?[indexPath.row]
        let lastIndex = (collectionViewDataSource?.count ?? 0) - 1
        cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        cell.reuseCellWith(data: cellData, indexNeedReload: indexPath, lastIndex: lastIndex)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if layout.currentPage != oldPage {
            var currentPage =  6 - layout.currentPage
            if currentPage > 6 {
                currentPage = 6
            }
            delegate?.collectionViewDidScrollIn(self, currentPage: currentPage)
            oldPage = layout.currentPage
        }
    }
}
