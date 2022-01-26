//
//  ViewController.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/7.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import SwiftyUserDefaults
import FirebaseAuth

class LoginVC: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var adminSwitchBtn: UISwitch!
    
    var mAuth = Auth.auth()
    
    var userEmail        = ""
    var userPassword     = ""
    
    var hud : MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        emailTextField.text = "dalal2alsaidi@gmail.com"
//        passwordTextField.text = "As998877"
    }

    @IBAction func onClickLogin(_ sender: Any) {
        userEmail       = emailTextField.text!
        userPassword    = passwordTextField.text!
         
        if isValidate() {
            userLogin()
        }
    }
    
    func isValidate() -> Bool {
        
        if userEmail.isEmpty {
            showToast(Constant.CHECK_EMAIL_EMPTY)
            return false
        }
        
        if !isValidEmail(email: userEmail) {
            showToast(Constant.CHECK_VAILD_EMAIL)
            return false
        }
        
        if userPassword.isEmpty {
            showToast(Constant.CHECK_PASSWORD_EMPTY)
            return false
        }
        return true
    }
    
    func userLogin() {
        self.hud = self.progressHUD(view: self.view, mode: .indeterminate)
        self.hud.show(animated: true)
        mAuth.signIn(withEmail: userEmail, password: userPassword) {(authResult, error) in
            
            if let authResult = authResult {
                self.gotoNextVC(authResult.user)
            }
            
            if let error = error {
                self.hud.hide(animated: true)
                self.showError(error.localizedDescription)
            }
        }
    }
    
    func gotoNextVC(_ user: User, userName: String? = nil, email: String? = nil) {

        if !user.isEmailVerified {
            
            // do whatever you want to do when user isn't verified
            user.sendEmailVerification { (err) in
                self.hud.hide(animated: true)
                
                if err != nil {
                    self.showError("Something's wrong".localized)
                } else {
                    self.showError("Please verify with your email".localized)
                }
            }
        } else {
            
            let uID = Auth.auth().currentUser!.uid
            
            if adminSwitchBtn.isOn {
                FirebaseAPI.getMyAdminInfo(uID) { (isSucess, result) in
                    self.hud.hide(animated: true)
                    if isSucess {
                        let userData = result as! UserModel
                        g_user = userData
                        
                        UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                        UserDefaults.standard.set(self.userPassword, forKey: "userPwd")
                        
                        self.gotoVC("AdminTabVC")
                        
                    } else {
                        let msg = result as! String
                        if msg == Constant.NO_DATA {
                            self.showToast("You are not an admin".localized)
                        } else {
                            self.showToast(msg)
                        }
                    }
                }
            } else {
                FirebaseAPI.getUserInfo(uID) { (isSucess, result) in
                    self.hud.hide(animated: true)
                    if isSucess {
                        let userData = result as! UserModel
                        g_user = userData
                        
                        UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                        UserDefaults.standard.set(self.userPassword, forKey: "userPwd")
                        
                        self.gotoVC("UserTabVC")
                        
                    } else {
                        let msg = result as! String
                        if msg == Constant.NO_DATA {
                            self.showToast("You are not an user".localized)
                        } else {
                            self.showToast(msg)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onClickForgotPassword(_ sender: Any) {
        
        let changePasswordAlert = UIAlertController(title: "Forgot Password".localized, message: "Please check the inbox or junk of your email to receive the link to reset your password".localized, preferredStyle: .alert)

        changePasswordAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter Your Email".localized
        }

        let changePasswordAction = UIAlertAction(title: "Send".localized, style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let emaiTextField         = changePasswordAlert.textFields![0]

            self.userEmail                = emaiTextField.text!
            
            if self.isValidateEmail() {
                Auth.auth().sendPasswordReset(withEmail: self.userEmail, completion: { (error) in
                    if error != nil {
                        self.showError((error?.localizedDescription)!)
                    } else {
                        
                        self.showError("Password reset email sent.".localized)
                    }
                })
                changePasswordAlert.dismiss(animated: false, completion: nil)
            }
        })
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(action) -> Void in
            print("Cancelled")
            changePasswordAlert.dismiss(animated: false, completion: nil)
        })
        // Add actions
        changePasswordAlert.addAction(changePasswordAction)
        changePasswordAlert.addAction(cancel)
        present(changePasswordAlert, animated: true, completion: nil)
    }
    
    func isValidateEmail() -> Bool {

        if userEmail.isEmpty {
            showToast(Constant.CHECK_EMAIL_EMPTY)
            return false
        }
        if !isValidEmail(email: userEmail) {
            showToast(Constant.CHECK_VAILD_EMAIL)
            return false
        }
        return true
    }
    
    @IBAction func onClickSignup(_ sender: Any) {
        gotoNavVC("SignupVC")
    }
}

