//
//  ProfileVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class ProfileVC: BaseViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var hud : MBProgressHUD!
    
    var profilePhotoUrl             = ""
    var userName                    = ""
    var phoneNumber                 = ""
    var gender                      = ""
    var birthday                    = ""
    var currentPassword     = ""
    var newPassword         = ""
    var confirmPassword     = ""
    var email               = ""
    
    var profileImage : (Data, String)? = nil
    let picker: UIImagePickerController = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        self.picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
        loadUserData()
    }
    
    func loadUserData() {
        
        profileImageView.kf.setImage(
            with: URL(string: g_user.photoUrl),
            placeholder: UIImage(named: "no_profile"))
        nameLabel.text = g_user.userName
        nameTextField.text = g_user.userName
        phoneTextField.text = g_user.phoneNumber
        genderTextField.text = g_user.gender
        birthdayTextField.text = g_user.birthday
    }
    
    @IBAction func onClickAvatar(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Please select the place", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "From Camera", style: .default, handler: { (action) -> Void in
                
                self.picker.sourceType = .camera
                self.picker.modalPresentationStyle = .fullScreen
                self.present(self.picker, animated: true, completion: nil)
            }))
        } else {
            showAlertDialog(title: "The camera is not available.", message: "", positive: "", negative: "Cancel")
            print("Camera not available")
        }
        
        actionSheet.addAction(UIAlertAction(title: "From Gallery", style: .default, handler: { (action) -> Void in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onClickBirthday(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.preferredDatePickerStyle = .wheels
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(timePickerValueChanged(_:)), for: .valueChanged)
    }
    @objc func timePickerValueChanged(_ sender:UIDatePicker){
      
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdayTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func onClickChangePassword(_ sender: Any) {
        let changePasswordAlert = UIAlertController(title: "Change Password", message: "Please check the inbox or junk of your email to receive the link to reset your password", preferredStyle: .alert)

        changePasswordAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter Your Email"
        }

        let changePasswordAction = UIAlertAction(title: "Change", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let emaiTextField         = changePasswordAlert.textFields![0]

            self.email                = emaiTextField.text!
            
            if self.isValidateEmail() {
                Auth.auth().sendPasswordReset(withEmail: self.email, completion: { (error) in
                    if error != nil {
                        self.showError((error?.localizedDescription)!)
                    } else {
                        
                        self.showError("Password reset email sent.")
                    }
                })
                changePasswordAlert.dismiss(animated: false, completion: nil)
            }
        })
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in
            print("Cancelled")
            changePasswordAlert.dismiss(animated: false, completion: nil)
        })
        // Add actions
        changePasswordAlert.addAction(changePasswordAction)
        changePasswordAlert.addAction(cancel)
        present(changePasswordAlert, animated: true, completion: nil)
    }
    
    func isValidateEmail() -> Bool {

        if email.isEmpty {
            showToast(Constant.CHECK_EMAIL_EMPTY)
            return false
        }
        if !isValidEmail(email: email) {
            showToast(Constant.CHECK_VAILD_EMAIL)
            return false
        }
        return true
    }
        
    @IBAction func onClickUpdate(_ sender: Any) {
        userName = nameTextField.text!
        phoneNumber = phoneTextField.text!
        gender = genderTextField.text!
        birthday = birthdayTextField.text!
        
        if isValidateUpdate() {
            updateUserProfile()
        }
    }
    
    func isValidateUpdate() -> Bool {
        
        if userName.isEmpty {
            showToast(Constant.CHECK_USER_NAME_EMPTY)
            return false
        }
        if phoneNumber.isEmpty {
            showToast(Constant.CHECK_PHONE_NUMBER_EMPTY)
            return false
        }
        
        return true
    }
    
    func updateUserProfile() {
        
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        let uID = Auth.auth().currentUser!.uid
        
        let localURLOfImage = saveFileToLocal(image: self.profileImageView.image!)
        
        FirebaseAPI().uploadFile(localFile: URL(fileURLWithPath: localURLOfImage!),dir: Constant.kSTORAGE_PROFILE + "/\(uID).jpg", serverFileName: uID) { (isSuccess, downloadUrl) in
            
            if isSuccess == true {
                let data = [
                    Constant.kUSER_NAME      : self.userName,
                    Constant.kPHONENUMBER    : self.phoneNumber,
                    Constant.kEMAIL          : g_user.email,
                    Constant.kPHOTO_URL      : downloadUrl!,
                    Constant.kFCM_TOKEN      : deviceTokenString,
                    Constant.kUSER_TYPE      : "admin",
                    Constant.kUSER_GENDER    : self.gender,
                    Constant.kUSER_BIRTHDAY  : self.birthday
                ] as [String : Any]
                
                self.updateUserInfo(uID, downloadUrl!, data)
            } else {
                self.hud.hide(animated: true)
                self.showToast("Profile Update failed")
            }
        }
    }
    
    func updateUserInfo(_ user_id: String, _ photo_url: String, _ data: [String: Any]) {
        FirebaseAPI.updateProfile(user_id, data) { (isSuccess) in
            if isSuccess {
                g_user = UserModel(
                    id: user_id,
                    userName: self.userName,
                    email: g_user.email,
                    phoneNumber: self.phoneNumber,
                    photoUrl: photo_url,
                    token: deviceTokenString,
                    userType: "admin",
                    gender: self.gender,
                    birthday: self.birthday)
                self.showToast("Profile updated successfully")
            } else {
                self.showToast("Profile update failed")
            }
            self.hud.hide(animated: true)
        }
    }
}
//MARK: -  ImagePickerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.profileImageView.image = image
            profileImage = (image.jpegData(compressionQuality: 0.75)!, "picture")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
