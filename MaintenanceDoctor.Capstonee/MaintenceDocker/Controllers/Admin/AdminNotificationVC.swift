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
                if self.notificationData.count <= 0 {
                    self.tabBarController?.tabBar.items![3].badgeValue = nil
                } else {
                    self.tabBarController?.tabBar.items![3].badgeValue = "\(self.notificationData.count)"
                }
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
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
        
        if notificationData[indexPath.row].description.contains("requested to repair") {
            let toVC = self.storyboard?.instantiateViewController( withIdentifier: "RepairOrderVC") as! RepairOrderVC
            toVC.order_id = notificationData[indexPath.row].order_ids[0]
            toVC.sender = notificationData[indexPath.row].sender
            toVC.notificationId = notificationData[indexPath.row].id
            self.navigationController?.pushViewController(toVC, animated: true)
        } else {
            let toVC = self.storyboard?.instantiateViewController( withIdentifier: "OneOrderVC") as! OneOrderVC
            toVC.sender_id = notificationData[indexPath.row].sender
            toVC.orderIDs = notificationData[indexPath.row].order_ids
            toVC.notificationId = notificationData[indexPath.row].id
            self.navigationController?.pushViewController(toVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
