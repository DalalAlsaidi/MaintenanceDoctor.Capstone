//
//  EditProductVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import Kingfisher

class EditProductVC: BaseViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    
    var imageData = [PostItemImageModel]()
    var name = ""
    var price = ""
    var product_description = ""
    var productData = ProductModel()
    var product_id = ""
    
    var toImageView = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Product"
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        loadData()
    }
    
    func loadData() {
        
        for oneImage in productData.images {
            imageData.append(PostItemImageModel(imgUrl: oneImage))
        }
        
        name = productData.name
        price = productData.price
        product_description = productData.description
        product_id = productData.id
        
        coverImageView.kf.setImage(
            with: URL(string: imageData[0].imgUrl!),
            placeholder: UIImage(named: "placeholder"))
        coverImageView.kf.indicatorType = .activity
        nameTextField.text = name
        priceTextField.text = price
        descriptionTextView.text = product_description
    }
    
    @IBAction func onClickChange(_ sender: Any) {
        toImageView = "cover"
    }
    
    @IBAction func onClickAdd(_ sender: Any) {
        toImageView = "add"
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickUpdate(_ sender: Any) {
    }
}
//MARK: - CollectionView Extension
extension EditProductVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        
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
extension EditProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            if toImageView == "add" {
                imageData.append(PostItemImageModel(imgFile: image))
                imageCollectionView.reloadData()
            } else {
                self.coverImageView.image = image
                imageData[0].imgFile = image
                imageCollectionView.reloadData()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
