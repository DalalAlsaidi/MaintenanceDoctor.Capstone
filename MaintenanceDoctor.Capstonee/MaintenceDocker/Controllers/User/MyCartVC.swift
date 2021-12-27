//
//  MyCartVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class MyCartVC: BaseViewController {

    @IBOutlet weak var cartTableView: DynamicSizeTableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var priceFixedLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    var cartData = [CartModel]()
    var hud : MBProgressHUD!
    var orderIds = [String]()
    
    var totalPrice: Float = 0.0
    let user_id = Auth.auth().currentUser!.uid
    var selectedProduct = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        totalPriceLabel.isHidden = true
        priceFixedLabel.isHidden = true
        orderButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Cart"
        cartTableView.delegate = self
        cartTableView.dataSource = self
    }
    
    func loadData() {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getMyCarts(user_id) { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                self.cartData = result as! [CartModel]
                self.calculateTotalPrice()
                self.cartTableView.reloadData()
                if self.cartData.count != 0 {
                    self.totalPriceLabel.isHidden = false
                    self.priceFixedLabel.isHidden = false
                    self.orderButton.isHidden = false
                }
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    @IBAction func onClickPlacerOrder(_ sender: Any) {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        orderIds.removeAll()
        addOrder(forIndex: 0)
    }
    
    func addOrder(forIndex index: Int) {

        if index < cartData.count {
            FirebaseAPI.createOrder(user_id, cartData[index]) { (isSuccess, result) in
                if isSuccess == true {
                    self.orderIds.append(result)
                    self.addOrder(forIndex: index + 1)
                } else {
                    self.hud.hide(animated: true)
                    self.showToast("Your order failed.")
                }
            }
            return
        }
        deleteMyCart()
    }
    
    func deleteMyCart() {
        FirebaseAPI.deleteMyCarts(user_id) { (isSuccess, result) in
            self.hud.hide(animated: true)
            if isSuccess == true {
                self.tabBarController?.tabBar.items![1].badgeValue = nil
                self.totalPriceLabel.isHidden = true
                self.priceFixedLabel.isHidden = true
                self.orderButton.isHidden = true
                self.cartData.removeAll()
                self.cartTableView.reloadData()
                self.showAlertDialog(title: "", message: "Your Order is completed", positive: "Ok", negative: nil)
                self.sendOrderNotification()
                
            } else {                
                self.showToast("Delete cart failed.")
            }
        }
    }
    
    func sendOrderNotification() {
        FirebaseAPI.getAdminTokenInfo() { (isSuccess, result) in
            if isSuccess {
                let tokens : [String] = result as! [String]
                let sender = PushNotificationSender()
                sender.sendAllPushNotification(to: tokens, title: "New Order", body: "\(g_user.userName) ordered the products", notiType: NotificationType.new_order.rawValue, id: self.user_id, image_url: g_user.photoUrl, orderIds: self.orderIds)
                
            } else {
                print("Getting tokens failed")
            }
        }
    }
    
    @objc func onClickPlus(_ sender: UIButton) {
        
        selectedProduct = sender.tag
        cartData[sender.tag].quantity = String(Int(cartData[sender.tag].quantity)! + 1)
        updateCart(cartData[sender.tag], "add")
    }
    
    @objc func onClickMinus(_ sender: UIButton) {
        
        selectedProduct = sender.tag
        if (Int(cartData[sender.tag].quantity)! - 1) == 0 {
            showAlert(title: "Warning", message: "Do you want to remove this product from your order list?", positive: "Yes", negative: "Cancel", okClosure: removeProductFromOrder)
        } else {
            cartData[sender.tag].quantity = String(Int(cartData[sender.tag].quantity)! - 1)
            updateCart(cartData[sender.tag], "reduce")
        }
    }
    
    func removeProductFromOrder() {
        FirebaseAPI.deleteOrderFromList(user_id, cartData[selectedProduct].id) { [self](isSucess, result) in
            if isSucess {
                cartData.remove(at: selectedProduct)
                if cartData.count == 0 {
                    self.totalPriceLabel.isHidden = true
                    self.priceFixedLabel.isHidden = true
                    self.orderButton.isHidden = true
                }
                calculateTotalPrice()
                cartTableView.reloadData()
            } else {
                let msg = result
                showError(msg)
            }
        }
        
    }
    
    func updateCart(_ cart: CartModel, _ updateType: String) {
        FirebaseAPI.updateCart(user_id, cart.id, cart.quantity) { [self] (isSucess, result) in
            if isSucess {
                if updateType == "reduce" {
                    calculateTotalPrice()
                    cartTableView.reloadData()
                } else {
                    calculateTotalPrice()
                    cartTableView.reloadData()
                }
            } else {
                let msg = result
                self.showToast(msg)
            }
        }
    }
    
    func calculateTotalPrice() {
        totalPrice = 0
        for item in cartData {
            totalPrice += Float(item.quantity)! * Float(item.price)!
        }
        totalPriceLabel.text = "SR" + String(format: "%.2f", totalPrice)
    }
    
}



//MARK: - TableViewDelegate, TableViewDataSource
extension MyCartVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        cell.entity = cartData[indexPath.row]
        cell.plusButton.tag = indexPath.row
        cell.plusButton.addTarget(self, action: #selector(onClickPlus), for: .touchUpInside)
        cell.minusButton.tag = indexPath.row
        cell.minusButton.addTarget(self, action: #selector(onClickMinus), for: .touchUpInside)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

//MARK: - DynamicSizeTableView
public class DynamicSizeTableView: UITableView
{
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        return contentSize
    }
}
