//
//  SignupVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/7.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import SwiftyUserDefaults
import Firebase
import FirebaseAuth

class SignupVC: BaseViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var profileImage : (Data, String)? = nil
    let picker: UIImagePickerController = UIImagePickerController()
    
    var userName                = ""
    var userEmail               = ""
    var phoneNumber             = ""
    var userPassword            = ""
    var confirmPassword         = ""
    
    var hud : MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
    }
    
    @IBAction func onClickSignup(_ sender: Any) {
        userName        = userNameTextField.text!
        userEmail       = emailTextField.text!
        phoneNumber     = phoneTextField.text!
        userPassword    = passwordTextField.text!
        confirmPassword = confirmPasswordTextField.text!
        
        if isValidate() {
            userSignUp()
        }
    }
    
    func isValidate() -> Bool {
        if userName.isEmpty {
            showToast(Constant.CHECK_USER_NAME_EMPTY)
            return false
        }
        
        if userEmail.isEmpty {
            showToast(Constant.CHECK_EMAIL_EMPTY)
            return false
        }
        
        if !isValidEmail(email: userEmail) {
            showToast(Constant.CHECK_VAILD_EMAIL)
            return false
        }
        
        if phoneNumber.isEmpty {
            showToast(Constant.CHECK_PHONE_NUMBER_EMPTY)
            return false
        }
        
        if userPassword.isEmpty {
            showToast(Constant.CHECK_PASSWORD_EMPTY)
            return false
        }
        
        if confirmPassword.isEmpty {
            showToast(Constant.CONFIRM_PASSWORD_EMPTY)
            return false
        }
        
        if userPassword != confirmPassword {
            showToast(Constant.WRONG_PASSWORD)
            return false
        }
        return true
    }
    
    func userSignUp() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        
        let localURLOfImage = saveFileToLocal(image: self.profileImageView.image!)
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword, completion: {(authResult, error) in
            
            if error != nil {

                self.hud.hide(animated: true)
                self.showError(error!.localizedDescription)
                print(error!.localizedDescription)
            } else {
                let userID = Auth.auth().currentUser!.uid

                guard let authResult = authResult else {
                    self.hud.hide(animated: true)
                    self.showError("Something's wrong")
                    return
                }
                let user = authResult.user
                
                FirebaseAPI().uploadFile(localFile: URL(fileURLWithPath: localURLOfImage!),dir: Constant.kSTORAGE_PROFILE + "/\(userID).jpg", serverFileName: userID) { (isSuccess, downloadUrl) in
                    
                    if isSuccess == true {
                        let data = [
                            Constant.kUSER_NAME      : self.userName,
                            Constant.kPHONENUMBER    : self.phoneNumber,
                            Constant.kEMAIL          : self.userEmail,
                            Constant.kPHOTO_URL      : downloadUrl!,
                            Constant.kFCM_TOKEN      : deviceTokenString,
                            Constant.kUSER_TYPE      : "user",
                            Constant.kUSER_GENDER    : "",
                            Constant.kUSER_BIRTHDAY  : ""
                        ] as [String : Any]
                        
                        self.saveUserInfo(user, userID, data)
                    } else {
                        self.hud.hide(animated: true)
                        self.showToast("Authentication failed.")
                    }
                }
            }
        })
    }
    
    func saveUserInfo(_ user: User, _ userID: String, _ data: [String : Any]) {

        FirebaseAPI.saveMyUserInfo(userID, data) { (isSuccess, result) in
            
            let photoURL = data[Constant.kPHOTO_URL] as! String
            
            let fileURL = URL(string: photoURL)!
            if FileManager().fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                }
            }
            
            if isSuccess == true {
                if user.isEmailVerified {

                    self.hud.hide(animated: true)

                    UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                    UserDefaults.standard.set(self.userPassword, forKey: "userPwd")
                    self.progressLogin(data)
                } else {
                    UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                    user.sendEmailVerification { (err) in
                        self.hud.hide(animated: true)
                        
                        if err != nil {
                            self.showError("Sothing's wrong")
                            
                        } else {
                            self.showError("Please verify with your email")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            } else {
                self.hud.hide(animated: true)
            }
        }
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
    
    @IBAction func onClickLogin(_ sender: Any) {
        doDismiss()
    }
}
//MARK:--  ImagePickerDelegate
extension SignupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.profileImageView.image = image
            profileImage = (image.jpegData(compressionQuality: 0.75)!, "picture")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
