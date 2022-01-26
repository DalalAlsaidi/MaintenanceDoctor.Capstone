//
//  ProductVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class ProductVC: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var productImageView: ImageSlideshow!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var hud : MBProgressHUD!
    
    var productData = ProductModel()
    var imageData = [String]()
    var alamofireSources = [AlamofireSource]()
    var product_id = ""
    
    var quantity = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadProductData()
        self.title = productData.name
    }
    
    func loadProductData() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getProductInfo(product_id) { [self] (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                productData = result as! ProductModel
                self.title = productData.name
                nameLabel.text = productData.name
                priceLabel.text = "SR".localized + productData.price
                descriptionLabel.text = productData.description
                imageData = productData.images
                setSlideShow()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    func setSlideShow() {
        
        productImageView.slideshowInterval = 5.0
        productImageView.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = .clear
        pageControl.cornerRadius = 15
        
        productImageView.pageIndicator = pageControl
        productImageView.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.large, color: nil)
        productImageView.delegate = self
        
        alamofireSources.removeAll()
        
        for i in 0..<imageData.count {
            let tmp = AlamofireSource(urlString: imageData[i], placeholder: Constant.PLACEHOLDER_IMAGE)!
            alamofireSources.append(tmp)
        }
        
        productImageView.setImageInputs(alamofireSources)
    }
    
    @IBAction func onClickPlus(_ sender: Any) {
        quantity += 1
        quantityLabel.text = "\(quantity)"
    }
    
    @IBAction func onClickMinus(_ sender: Any) {
        quantity -= 1
        if quantity <= 0 {
            quantity = 0
            showToast("You must add more than 1 product".localized)
        } else {
            quantityLabel.text = "\(quantity)"
        }
    }
    
    @IBAction func onClickPhone(_ sender: Any) {
        
        let urlWhats = "whatsapp://send?phone=+966598992448"
        
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (Bool) in
                    })
                } else {
                    showAlertDialog(title: "", message: "Please install WhatsApp".localized, positive: "Ok".localized, negative: nil)
                }
            }
        }
    }
    
    @IBAction func onClickEmail(_ sender: Any) {
        if let url = URL(string: "mailto:Maintenance.d.hail@gmail.com") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onClickOrder(_ sender: Any) {
        
        if quantity == 0 {
            showToast("You must add more than 1 product".localized)
            return
        }
        
        let user_id = Auth.auth().currentUser!.uid
        let quantity = quantityLabel.text!
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.addCart(user_id, product_id, productData.name, productData.price, quantity, imageData[0]) { (isSuccess, result) in
            self.hud.hide(animated: true)
            if isSuccess {
                self.showToast("This product added your cart successfully.".localized)
            } else {
                self.hud.hide(animated: true)
            }
        }
        doDismiss()
    }
    
}
// MARK: - ImageSlideShowExtension
extension ProductVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
    }
}

