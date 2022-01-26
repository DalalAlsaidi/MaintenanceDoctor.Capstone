//
//  RepairOrderVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/28.
//

import UIKit
import MBProgressHUD
import GoogleMaps

class RepairOrderVC: BaseViewController {

    @IBOutlet weak var orderImagesSlide: ImageSlideshow!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationMapView: GMSMapView!
    
    var order_id = ""
    var sender  = ""
    var hud : MBProgressHUD!
    var orderData = RepairOrderModel()
    var imageData = [String]()
    var alamofireSources = [AlamofireSource]()
    var order_status = ""
    var notificationId = ""
    var order_lat = 0.0
    var order_long = 0.0
    
    private let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repair Order"
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationMapView.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationMapView.isMyLocationEnabled = true
            locationMapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        loadData()
    }
    
    func loadData() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        FirebaseAPI.getRepairOrder(sender, order_id) { [self] (isSucess, result) in
            self.hud.hide(animated: true)
            if isSucess {
                orderData = result as! RepairOrderModel
                nameLabel.text = orderData.name
                descriptionLabel.text = orderData.description
                imageData = orderData.images
                order_lat = orderData.my_lat
                order_long = orderData.my_long
                setMapMarker(order_lat, order_long)
                setSlideShow()
            } else {
                let msg = result as! String
                self.showToast(msg)
            }
        }
    }
    
    func setMapMarker(_ lat: Double, _ long: Double) {
       
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        //print("location: \(location)")
        let marker = GMSMarker()
        marker.position = location
        marker.map = locationMapView
        
        let orderLocation = GMSCameraPosition.camera(withLatitude: order_lat
                                                     , longitude: order_long, zoom: 12, bearing: 0, viewingAngle: 0)
        locationMapView.camera = orderLocation
        locationMapView.animate(to: locationMapView.camera)
        locationManager.stopUpdatingLocation()
    }
    
    func setSlideShow() {
        
        orderImagesSlide.slideshowInterval = 5.0
        orderImagesSlide.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = .clear
        pageControl.cornerRadius = 15
        
        orderImagesSlide.pageIndicator = pageControl
        orderImagesSlide.activityIndicator = DefaultActivityIndicator(style: UIActivityIndicatorView.Style.large, color: nil)
        orderImagesSlide.delegate = self
        
        alamofireSources.removeAll()
        
        for i in 0..<imageData.count {
            let tmp = AlamofireSource(urlString: imageData[i], placeholder: Constant.PLACEHOLDER_IMAGE)!
            alamofireSources.append(tmp)
        }
        
        orderImagesSlide.setImageInputs(alamofireSources)
    }
    
    @IBAction func onClickReject(_ sender: Any) {
        order_status = "reject".localized
        deleteNotification()
    }
    
    @IBAction func onClickAccept(_ sender: Any) {
        order_status = "accept".localized
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
                self.updateRepairOrderStatus()
            } else {
                let msg = result
                self.showToast(msg)
            }
        }
    }
    
    func updateRepairOrderStatus() {
        
        FirebaseAPI.updateRepairOrder(sender, order_id, order_status) { (isSucess) in
            if isSucess {
                if self.order_status == "accept" {
                    self.showAlert(title: "", message: "You have accepted this order".localized, positive: "Ok".localized, negative: nil, okClosure: self.onBackNotificationVC)
                } else {
                    self.showAlert(title: "", message: "You have rejected this order".localized, positive: "Ok".localized, negative: nil, okClosure: self.onBackNotificationVC)
                }
            } else {
                print("failed")
            }
        }
    }
    
    func onBackNotificationVC() {
        doDismiss()
    }
}
// MARK: - ImageSlideShowExtension
extension RepairOrderVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
    }
}
//MARK: -- LocaitonManager delegate Extension
extension RepairOrderVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        guard status == .authorizedWhenInUse else {
          return
        }
        locationManager.startUpdatingLocation()
        locationMapView.isMyLocationEnabled = true
        locationMapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let orderLocation = GMSCameraPosition.camera(withLatitude: order_lat
                                                     , longitude: order_long, zoom: 12, bearing: 0, viewingAngle: 0)
        locationMapView.camera = orderLocation
        locationMapView.animate(to: locationMapView.camera)
        locationManager.stopUpdatingLocation()
    }
  
    func locationManager( _ manager: CLLocationManager, didFailWithError error: Error ) {
        print(error)
      }
}
//MARK: --Google Map delegate Extension
extension RepairOrderVC: GMSMapViewDelegate {
    
}

