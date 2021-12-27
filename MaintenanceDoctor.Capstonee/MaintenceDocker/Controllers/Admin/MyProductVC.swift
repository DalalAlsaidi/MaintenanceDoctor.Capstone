//
//  MyProductVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//



import UIKit
import MBProgressHUD

     
class MyProductVC: BaseViewController {

    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var productsData = [ProductModel]()
    var searchedData = [ProductModel]()
    var hud : MBProgressHUD!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(setBadgeCount), name: .newProduct, object: nil)
        setBadgeCount()
        onCallProducts()
        searchTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(onClickLogout))
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
    }
    
    @objc func setBadgeCount() {
        if UIApplication.shared.applicationIconBadgeNumber <= 0 {
            self.tabBarController?.tabBar.items![3].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items![3].badgeValue = "\(UIApplication.shared.applicationIconBadgeNumber)"
        }
    }
    
    @objc func onClickLogout() {
        
        showAlert(title: Constant.CONFIRM_LOGOUT, message: "", positive: Constant.YES, negative: Constant.NO, okClosure: logout)
    }
    
    func logout() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        let loginNavVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthNav") as! UINavigationController
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first?.rootViewController = loginNavVC
    }
    
    func onCallProducts() {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getAllProducts() { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                self.productsData = result as! [ProductModel]
                self.productCollectionView.reloadData()
                self.searchedData = self.productsData
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
        productCollectionView.reloadData()        
    }
    
}
//MARK: - UICollectionViewDelegate, DataSource
extension MyProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "AdminProductVC") as! AdminProductVC
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

