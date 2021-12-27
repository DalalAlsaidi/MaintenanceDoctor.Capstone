//
//  AdminProductVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import MBProgressHUD
import AlamofireImage

class AdminProductVC: BaseViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
   
    @IBOutlet weak var productImageView: ImageSlideshow!
    
    var hud : MBProgressHUD!
    var product_id = ""
    var productData = ProductModel()
    var imageData = [String]()
    var alamofireSources = [AlamofireSource]()
    
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
                priceLabel.text = "$" + productData.price
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
    
    @IBAction func onClickEdit(_ sender: Any) {
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: "EditProductVC") as! EditProductVC
        toVC.productData = productData
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func onClickDelete(_ sender: Any) {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)

        FirebaseAPI.deleteProduct(product_id) { (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                self.showToast("You deleted your product successfully")
                self.doDismiss()
            } else {
                let msg = result
                self.showToast(msg)
            }
        }
    }
}
// MARK: - ImageSlideShowExtension
extension AdminProductVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
    }
}
