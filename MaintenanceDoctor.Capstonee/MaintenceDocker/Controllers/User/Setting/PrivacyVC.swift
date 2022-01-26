//
//  PrivacyVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import WebKit

class PrivacyVC: BaseViewController, WKNavigationDelegate {
    @IBOutlet weak var privacyWebView: WKWebView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Privacy Policy".localized
        coverView.isHidden = false
        indicator.startAnimating()
        privacyWebView.navigationDelegate = self
        
        let url = URL(string: "https://1exerdance.com/terms")!
        privacyWebView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        coverView.isHidden = false
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        indicator.stopAnimating()
        coverView.isHidden = true
        indicator.isHidden = true
    }

}
