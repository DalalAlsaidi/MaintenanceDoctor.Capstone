//
//  AdminNotificationVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import MBProgressHUD
import FirebaseAuth

class AdminNotificationVC: BaseViewController {
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    var hud : MBProgressHUD!
    var notificationData = [NotificationModel]()
    let user_id = Auth.auth().currentUser!.uid
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .newOrder, object: nil)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        notificationTableView.delegate = self
        notificationTableView.dataSource = self
    }
    
    @objc func loadData() {
        FirebaseAPI.getAdminNotification(user_id) { (isSucess, result) in
            if isSucess {
                self.notificationData = result as! [NotificationModel]
                self.notificationTableView.reloadData()
                self.setBadgeCount()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    func setBadgeCount() {
        if UIApplication.shared.applicationIconBadgeNumber <= 0 {
            self.tabBarController?.tabBar.items![3].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items![3].badgeValue = "\(UIApplication.shared.applicationIconBadgeNumber)"
        }
    }
}
//MARK: - TableView DataSource, Delegate
extension AdminNotificationVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.entity = notificationData[indexPath.row]
        cell.titleLabel.text = "New Order"
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OneOrderVC") as! OneOrderVC
        toVC.sender_id = notificationData[indexPath.row].sender
        toVC.orderIDs = notificationData[indexPath.row].order_ids
        toVC.notificationId = notificationData[indexPath.row].id
        self.navigationController?.pushViewController(toVC, animated: true)
        
        
//        FirebaseAPI.deleteNotification(notificationData[indexPath.row].id, "order") { (isSucess, result) in
//            self.hud.hide(animated: true)
//            if isSucess {
//                if UIApplication.shared.applicationIconBadgeNumber > 0 {
//                    UIApplication.shared.applicationIconBadgeNumber -= 1
//                }
//                self.notificationData.remove(at: indexPath.row)
//                self.notificationTableView.reloadData()
//                self.setBadgeCount()
//            } else {
//                let msg = result
//                self.showToast(msg)
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
