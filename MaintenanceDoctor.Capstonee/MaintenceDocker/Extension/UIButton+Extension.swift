//
//  UIButton+Extension.swift
//

import Foundation
import UIKit

extension UIButton {
    
    func applyRoundShadow() {
        //self.backgroundColor = UIColor(cgColor: UIColor.darkGray.cgColor)
        self.layer.cornerRadius = self.frame.size.height / 2
        //self.setTitleColor(UIColor.white, for: .normal)
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
    }
}


// MARK: - round button with round shadow effect
class roundShadowButton: UIButton {
    override func didMoveToWindow() {
        //self.backgroundColor =  UIColor(cgColor: UIColor.white.cgColor)
        self.layer.cornerRadius = 8 //self.height / 2
        //self.setTitleColor(UIColor.white, for: .normal)
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .zero
    }
}

// MARK: - round button with drop-down shadow effect
class dropShadowButton: UIButton {
    override func didMoveToWindow() {
        self.backgroundColor =  UIColor(named: "SecondColor")
        self.layer.cornerRadius = 25
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.textAlignment = .center
        //UIColor(named:"PrimaryColor")?.cgColo
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

class dropShadowSmallButton: UIButton {
    override func didMoveToWindow() {
        self.backgroundColor =  UIColor(named: "PrimaryColor")
        self.layer.cornerRadius = 20
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.textAlignment = .center
        //UIColor(named:"PrimaryColor")?.cgColo
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

class dropShadowHeightButton: UIButton {
    override func didMoveToWindow() {
        self.backgroundColor =  UIColor(named: "SecondColor")
        self.layer.cornerRadius = 30
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLabel?.textAlignment = .center
        //UIColor(named:"PrimaryColor")?.cgColo
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

class dropShadowThemeButton: UIButton {
    override func didMoveToWindow() {
        //self.backgroundColor =  UIColor(cgColor: UIColor.darkGray.cgColor)
        self.layer.cornerRadius = self.frame.size.height / 2
        //self.setTitleColor(UIColor.white, for: .normal)
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
}
