//
//  SettingVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit

class SettingVC: BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickProfile(_ sender: Any) {
        gotoNavVC("ProfileVC")
    }
    
    @IBAction func onClickPrivacy(_ sender: Any) {
        gotoNavVC("PrivacyVC")
    }
    
    @IBAction func onClickTerms(_ sender: Any) {
        gotoNavVC("TermsVC")
    }
    
    @IBAction func onClickShare(_ sender: Any) {
        if let name = URL(string: "https://itunes.apple.com"), !name.absoluteString.isEmpty {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }else  {
            showToast("Something went wrong.")
        }
    }
    
    @IBAction func onClickLogout(_ sender: Any) {
        showLogoutDialog()

    }
    
    func showLogoutDialog() {
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
}
