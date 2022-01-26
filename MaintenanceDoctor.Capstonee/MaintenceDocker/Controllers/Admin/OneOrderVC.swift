//
//  OneOrderVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/20.
//

import UIKit
import MBProgressHUD

class OneOrderVC: BaseViewController {
    
    @IBOutlet weak var orderCollectionView: DynamicSizeTableView!
    
    var hud: MBProgressHUD!
    var orderData = [OrderModel]()
    var orderIDs = [String]()
    var notificationId = ""
    var sender_id = ""
    var order_status = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Order".localized
        orderCollectionView.dataSource = self
        orderCollectionView.delegate = self
        loadData()
    }
    
    func loadData() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getOneOrder(sender_id, orderIDs) { [self] (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                orderData = result as! [OrderModel]
                orderCollectionView.reloadData()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    @IBAction func onClickAccept(_ sender: Any) {
        order_status = "accept".localized
        deleteNotification()
    }
    
    @IBAction func onClickReject(_ sender: Any) {
        order_status = "reject".localized
        deleteNotification()
    }
    
    func deleteNotification() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        
        FirebaseAPI.deleteNotification(notificationId, "order") { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    UIApplication.shared.applicationIconBadgeNumber -= 1
                }
                self.deleteOrder()
            } else {
                let msg = result
                self.showToast(msg)
            }
        }
    }
    
    func deleteOrder() {
        FirebaseAPI.deleteOrder(sender_id, orderIDs) { (isSuccess, result) in
            if isSuccess == true {
                if self.order_status == "accept" {
                    self.showAlert(title: "", message: "You have accepted this order".localized, positive: "Ok".localized, negative: nil, okClosure: self.onBackNotificationVC)
                } else {
                    self.showAlert(title: "", message: "You have rejected this order".localized, positive: "Ok".localized, negative: nil, okClosure: self.onBackNotificationVC)
                }
            } else {
                self.showToast("Delete order failed.".localized)
            }
        }
    }
    
    func onBackNotificationVC() {
        doDismiss()
    }
}
//MARK: - TableView DataSource, Delegate
extension OneOrderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orderCollectionView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        cell.entity = orderData[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "AdminProductVC") as! AdminProductVC
        toVC.product_id = orderData[indexPath.row].product_id
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
