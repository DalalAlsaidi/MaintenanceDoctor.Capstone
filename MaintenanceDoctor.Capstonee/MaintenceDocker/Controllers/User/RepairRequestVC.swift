//
//  RepairRequestVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2022/1/4.
//

import UIKit
import MBProgressHUD

class RepairRequestVC: BaseViewController {

    @IBOutlet weak var repairRequestTableView: UITableView!
    var repairRequestData = [RepairOrderModel]()
    
    var hud : MBProgressHUD!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        getMyRepairRequests()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        repairRequestTableView.dataSource = self
        repairRequestTableView.delegate = self        
    }
    
    func getMyRepairRequests() {
        repairRequestData.removeAll()
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getMyRepairOrders(g_user.id) { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                self.repairRequestData = result as! [RepairOrderModel]
                self.repairRequestTableView.reloadData()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }

}
//MARK: - TableView DataSource, Delegate
extension RepairRequestVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repairRequestData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repairRequestTableView.dequeueReusableCell(withIdentifier: "RepairOrderCell", for: indexPath) as! RepairOrderCell
        cell.entity = repairRequestData[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
