//
//  RepairVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/28.
//

import UIKit
import MBProgressHUD

var my_address = ""
var my_lat = 0.0
var my_long = 0.0

class RepairVC: BaseViewController {

    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationTextField: UITextField!
    
    var imageData = [PostItemImageModel]()
    let picker: UIImagePickerController = UIImagePickerController()
    var addImageStatus = 0
    var name = ""
    var location = ""
    var repair_description = ""
    var imageUrls = [String]()
    
    var hud : MBProgressHUD!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if my_address != "" {
            locationTextField.text = my_address
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ImagePicker delegate and modal Style
        self.picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        changeButton.isHidden = true
        imageCollectionViewHeight.constant = 0
        addImageButton.isHidden = true
        imageLabel.isHidden = true
        
        my_address = ""
        my_long = 0.0
        my_lat = 0.0
    }
    
    @IBAction func onClickUploadImage(_ sender: UIButton) {
        addImageStatus = sender.tag
        let actionSheet = UIAlertController(title: "Please select the place".localized, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "From Camera".localized, style: .default, handler: { (action) -> Void in
                
                self.picker.sourceType = .camera
                self.picker.modalPresentationStyle = .fullScreen
                self.present(self.picker, animated: true, completion: nil)
            }))
        } else {
            showAlertDialog(title: "The camera is not available.".localized, message: "", positive: "", negative: "Cancel".localized)
            print("Camera not available")
        }
        
        actionSheet.addAction(UIAlertAction(title: "From Gallery".localized, style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onClickRequest(_ sender: Any) {
        name = nameTextField.text!
        repair_description = descriptionTextView.text!
        location = locationTextField.text!
        
        if isValidate() {
            
            self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
            self.hud.show(animated: true)
            
            uploadIamges(forIndex: 0)
        }
    }
    
    func isValidate() -> Bool {
        if name.isEmpty {
            showToast("Please enter repair subject".localized)
            return false
        }
        if location.isEmpty {
            showToast("Please enter location".localized)
            return false
        }
        if repair_description.isEmpty {
            showToast("Please enter description".localized)
            return false
        }
        if imageData.count == 0 {
            showToast("You must add one more image".localized)
            return false
        }
        return true
    }
    
    func uploadIamges(forIndex index: Int) {
        let timeStamp = NSDate().timeIntervalSince1970
        
        if index < imageData.count {
            let localURLOfImage = saveFileToLocal(image: imageData[index].imgFile!)
            FirebaseAPI().uploadFile(localFile: URL(fileURLWithPath: localURLOfImage!),dir: Constant.kSTORAGE_PRODUCT + "/\(g_user.id)/\(timeStamp)/\(index).jpg", serverFileName: g_user.id) { (isSuccess, downloadUrl) in
                
                if isSuccess == true {
                    self.imageUrls.append(downloadUrl!)
                    self.uploadIamges(forIndex: index + 1)
                } else {
                    self.hud.hide(animated: true)
                    self.showToast("Upload failed.".localized)
                }
            }
            return
        }
        FirebaseAPI.orderRepair(g_user.id, name, my_lat, my_long, repair_description, imageUrls) { (isSuccess, result) in
            
            if isSuccess {
                let order_id = result
                self.hud.hide(animated: true)
                var temp = [String]()
                temp.append(order_id)
                self.sendOrderNotification(temp)
                self.showToast("Your order sent successfully.".localized)
            } else {
                self.hud.hide(animated: true)
            }
        }
    }
    
    func sendOrderNotification(_ order_id: [String]) {
        FirebaseAPI.getAdminTokenInfo() { (isSuccess, result) in
            if isSuccess {
                let tokens : [String] = result as! [String]
                let sender = PushNotificationSender()
                sender.sendAllPushNotification(to: tokens, title: "New Maintenance Order".localized, body: "\(g_user.userName) requested to repair \(self.name)".localized, notiType: NotificationType.new_order.rawValue, id: g_user.id, image_url: g_user.photoUrl, orderIds: order_id)
                self.setInitialStatus()
            } else {
                print("Getting tokens failed")
            }
        }
    }
    
    func setInitialStatus() {
        my_address = ""
        nameTextField.text = ""
        descriptionTextView.text = ""
        imageData.removeAll()
        imageCollectionView.reloadData()
        coverImageView.image = nil
        changeButton.isHidden = true
        uploadButton.isHidden = false
        imageLabel.isHidden = true
        addImageButton.isHidden = true
        imageCollectionViewHeight.constant = 0
        locationTextField.text = ""
    }
    
    @IBAction func onClickLocation(_ sender: Any) {
        gotoNavVC("MapVC")
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        let clickPosition = sender.tag
        imageData.remove(at: clickPosition)
        imageCollectionView.reloadData()
    }    
}
//MARK: - CollectionView Extension
extension RepairVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
        cell.entity = imageData[indexPath.row]
        cell.closeButton.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let h = collectionView.height
        let w = h
        return CGSize(width: w,height: h)
    }
}
//MARK: - ImagePickerDelegate
extension RepairVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            if addImageStatus == 2 {
                imageData.append(PostItemImageModel(imgFile: image))
                imageCollectionView.reloadData()
            } else {
                self.coverImageView.image = image
                if addImageStatus == 1 {
                    imageData[0].imgFile = image
                    imageCollectionView.reloadData()
                } else {
                    uploadButton.isHidden = true
                    imageData.append(PostItemImageModel(imgFile: image))
                    imageCollectionView.reloadData()
                }
            }
            changeButton.isHidden = false
            imageLabel.isHidden = false
            addImageButton.isHidden = false
            imageCollectionViewHeight.constant = 120
        }
        
        dismiss(animated: true, completion: nil)
    }
}

