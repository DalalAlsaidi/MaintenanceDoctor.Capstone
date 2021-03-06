//
//  HomeVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import MBProgressHUD

var cartBadge = 0

class HomeVC: BaseViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var productionCollectionView: UICollectionView!
    
    var hud : MBProgressHUD!
    
    var productsData = [ProductModel]()
    var searchedData = [ProductModel]()
    
    let badgeSize: CGFloat = 20
    let badgeTag = 9830384
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(setNotificationBadgeCount), name: .newOrder, object: nil)
        setNotificationBadgeCount()
        setMyCartBadgeCount()
        onCallProducts()
        searchTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productionCollectionView.dataSource = self
        productionCollectionView.delegate = self
    }    
    
    @objc func setNotificationBadgeCount() {
        FirebaseAPI.getUserNotification(g_user.id) { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                var notificationData = [NotificationModel]()
                notificationData = result as! [NotificationModel]
                let badgeCount = notificationData.count
                if badgeCount <= 0 {
                    self.tabBarController?.tabBar.items![3].badgeValue = nil
                } else {
                    self.tabBarController?.tabBar.items![3].badgeValue = "\(badgeCount)"
                }
            } else {
                let msg = result as! String
                print(msg)
            }
        }
    }
    
    func setMyCartBadgeCount() {
        FirebaseAPI.getMyCarts(g_user.id) { (isSucess, result) in
            if isSucess {
                var cartData = [CartModel]()
                cartData = result as! [CartModel]
                cartBadge = cartData.count
                if cartBadge <= 0 {
                    self.tabBarController?.tabBar.items![1].badgeValue = nil
                } else {
                    self.tabBarController?.tabBar.items![1].badgeValue = "\(cartBadge)"
                }
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    func onCallProducts() {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getAllProducts() { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                self.productsData = result as! [ProductModel]
                self.searchedData = self.productsData
                self.productionCollectionView.reloadData()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    @IBAction func onSearchProducts(_ sender: UITextField) {
        let searchText = searchTextField.text!
        searchedData.removeAll()
        if  searchText.isEmpty {
            searchedData = productsData
        } else  {
            for product in productsData {
                if (product.name.lowercased().contains(searchText.lowercased())) {
                    searchedData.append(product)
                }
            }
        }
        productionCollectionView.reloadData()
    }
}
//MARK: -UICollectionViewDelegate, DataSource
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "ProductVC") as! ProductVC
        toVC.product_id = searchedData[indexPath.row].id
        toVC.productData = searchedData[indexPath.row]
        toVC.imageData = searchedData[indexPath.row].images
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.entity = searchedData[indexPath.row]
        return cell
            
        
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        let w: CGFloat = collectionView.frame.size.width/2 - 6
        let h: CGFloat = 220
        return CGSize(width: w,height: h)
    }
}
