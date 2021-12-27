import UIKit
import Toast_Swift
import SwiftyUserDefaults
import MBProgressHUD
import Foundation

class BaseViewController: UIViewController {

    let kColorOrange = UIColor(hex: "FDB913")
  
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        // to enable swiping left when back button in navigation bar customized
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        overrideUserInterfaceStyle = .light
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(email:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
        
    }    

    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (positive != nil) {
            
            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }
        
        if (negative != nil) {
            
            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }
        
        DispatchQueue.main.async(execute:  {
            self.present(alert, animated: true, completion: nil)
        })
    }

    func showError(_ message: String!) {

        showAlertDialog(title: "", message: message, positive:"Ok", negative: nil)
    }

    func showSuccess(_ message: String!) {
        showAlertDialog(title: "", message: message, positive: "Ok", negative: nil)
    }
    
    internal func showAlert(title: String?, message: String?, positive: String, negative: String?, okClosure: (() -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let yesAction = UIAlertAction(title: positive, style: .default, handler: { (action: UIAlertAction) in
            
            if okClosure != nil {
                okClosure!()
            }
        })
        alertController.addAction(yesAction)
        if negative != nil {
            let noAction = UIAlertAction(title: negative, style: .cancel, handler: { (action: UIAlertAction) in
                
            })
            alertController.addAction(noAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
   
    
    func showToast(_ message : String) {
        self.view.makeToast(message)
    }
    
    func showToast(_ message : String, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = .center) {
    
        self.view.makeToast(message, duration: duration, position: position)
    }
    
    func gotoNavVC (_ nameVC: String) {
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        self.navigationController?.pushViewController(toVC!, animated: true)
    }
    
    func doDismiss(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoVC(_ nameVC: String){
        
        let toVC = self.storyboard?.instantiateViewController( withIdentifier: nameVC)
        toVC!.modalPresentationStyle = .fullScreen
        self.present(toVC!, animated: false, completion: nil)
    }
    
    func progressHUD(view : UIView, mode: MBProgressHUDMode = .annularDeterminate) -> MBProgressHUD {
    
    let hud = MBProgressHUD .showAdded(to:view, animated: true)
    hud.mode = mode
    hud.label.text = "Loading";
    hud.animationType = .zoomIn
    hud.tintColor = UIColor.white
    hud.contentColor = UIColor(named: "PrimaryColor")
    return hud
        
    }
    
    func progressLogin(_ data: [String : Any]) {
        
        g_user.userName    = data[Constant.kUSER_NAME] as! String
        g_user.email        = data[Constant.kEMAIL] as! String
        g_user.phoneNumber  = data[Constant.kPHONENUMBER] as! String
        g_user.photoUrl     = data[Constant.kPHOTO_URL] as! String

        gotoVC("UserTabVC")
    }
}

extension DefaultsKeys {
    
    var userEmail : DefaultsKey<String?>{ return .init("userEmail")}
    var userPwd : DefaultsKey<String?>{ return .init("userPwd")}
    var userId : DefaultsKey<String?>{ return .init("userId")}
    var userPhotoUrl : DefaultsKey<String?>{ return .init("userPhotoUrl")}
    var firstName : DefaultsKey<String?>{ return .init("firstName")}    
    var userPhoneNumber : DefaultsKey<String?>{ return .init("userPhoneNumber")}
    var userLoginStaus : DefaultsKey<Bool>{ return .init("userLoginStaus", defaultValue: false)}
    var device_token : DefaultsKey<String?>{ return .init("device_token")}
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension String {
    /**
     :name:    trim
     */
    public var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /**
     :name:    lines
     */
    public var lines: [String] {
        return components(separatedBy: CharacterSet.newlines)
    }
    
    /**
     :name:    firstLine
     */
    public var firstLine: String? {
        return lines.first?.trimmed
    }
    
    /**
     :name:    lastLine
     */
    public var lastLine: String? {
        return lines.last?.trimmed
    }
    
    /**
     :name:    replaceNewLineCharater
     */
    public func replaceNewLineCharater(separator: String = " ") -> String {
        return components(separatedBy: CharacterSet.whitespaces).joined(separator: separator).trimmed
    }
    
    /**
     :name:    replacePunctuationCharacters
     */
    public func replacePunctuationCharacters(separator: String = "") -> String {
        return components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: separator).trimmed
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
     let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
}

