//
//  TermsVC.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import WebKit

class TermsVC: BaseViewController, WKNavigationDelegate {
    
    @IBOutlet weak var termsWebView: WKWebView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Terms of User"
        coverView.isHidden = false
        indicator.startAnimating()
        termsWebView.navigationDelegate = self
        
        let url = URL(string: "https://1exerdance.com/terms")!
        termsWebView.load(URLRequest(url: url))
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
