//
//  PostVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import MBProgressHUD
import FirebaseStorage
import Firebase
import FirebaseFirestore

class PostVC: BaseViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageCollectionView: DynamicHeightCollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var coverButton: UIButton!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var changeButton: UIButton!
    
    var imageData = [PostItemImageModel]()
    let picker: UIImagePickerController = UIImagePickerController()
    
    var hud : MBProgressHUD!
    
    var name                = ""
    var price               = ""
    var product_description = ""
    var imageUrls = [String]()
    var addImageStatus = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageCollectionView.dataSource = self
        postImageCollectionView.delegate = self
        //ImagePicker delegate and modal Style
        self.picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
        //Control the height of postImage Collection View. If users added the images, the ehight is 120, and if not, it's 0
        if imageData.count == 0 {
            collectionViewHeight.constant = 0
        } else {
            collectionViewHeight.constant = 120
        }
        changeButton.isHidden = true
        imageLabel.isHidden = true
        addImageButton.isHidden = true
    }
    
    @IBAction func addImages(_ sender: UIButton) {
        
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
    
    @IBAction func onClickClose(_ sender: UIButton) {
        let clickPosition = sender.tag
        imageData.remove(at: clickPosition)
        postImageCollectionView.reloadData()
    }
    @IBAction func onClickPost(_ sender: Any) {
        name = nameTextField.text!
        price = priceTextField.text!
        product_description = descriptionTextView.text!
        
        if isValidate() {
            
            self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
            self.hud.show(animated: true)
            
            uploadIamges(forIndex: 0)
        }
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
        FirebaseAPI.postProduct(name, price, product_description, imageUrls) { (isSuccess, result) in
            
            if isSuccess {
                let product_id = result
                self.hud.hide(animated: true)
                self.sendPostNotification(product_id)
                self.showToast("Your product uploaded successfully.".localized)
            } else {
                self.hud.hide(animated: true)
            }
        }
    }
    
    func sendPostNotification(_ product_id: String) {
        FirebaseAPI.getUsersTokenInfo() { [self] (isSuccess, result) in
            if isSuccess {
                let tokens : [String] = result as! [String]
                let sender = PushNotificationSender()
                sender.sendAllPushNotification(to: tokens, title: "New Product Post".localized, body: "The seller posted \(name) for SR\(price)".localized, notiType: NotificationType.new_product.rawValue, id: product_id, image_url: imageUrls[0], orderIds: [""])
                
            } else {
                self.hud.hide(animated: true)
            }
        }
    }
    
    func isValidate() -> Bool {
        if name.isEmpty {
            showToast("Please enter product name".localized)
            return false
        }
        if price.isEmpty {
            showToast("Please enter price.".localized)
            return false
        }
        if product_description.isEmpty {
            showToast("Please enter description".localized)
            return false
        }
        if imageData.count == 0 {
            showToast("You must add one more image".localized)
            return false
        }
        return true
    }
    
}
//MARK: - CollectionView Extension
extension PostVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        
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
extension PostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            if addImageStatus == 2 {
                imageData.append(PostItemImageModel(imgFile: image))
                postImageCollectionView.reloadData()
            } else {
                self.postImageView.image = image
                if addImageStatus == 1 {
                    imageData[0].imgFile = image
                    postImageCollectionView.reloadData()
                } else {
                    imageData.append(PostItemImageModel(imgFile: image))
                    postImageCollectionView.reloadData()
                }
            }
            changeButton.isHidden = false
            imageLabel.isHidden = false
            addImageButton.isHidden = false
            collectionViewHeight.constant = 120
            coverButton.isHidden = true
            placeImageView.isHidden = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}
