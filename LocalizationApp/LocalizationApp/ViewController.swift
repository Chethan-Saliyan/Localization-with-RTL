//
//  ViewController.swift
//  LocalizationApp
//
//  Created by Chethan on 22/04/19.
//  Copyright © 2019 Chethan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func nextController(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "\(NextViewController.self)") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func switchLanguage(_ sender: Any) {
        if PreferredLanguage.isRTL {
            PreferredLanguage.setCurrentLanguageTo(SupportedLocalizationLanguage.english.rawValue )
        } else {
            PreferredLanguage.setCurrentLanguageTo(SupportedLocalizationLanguage.arabic.rawValue )
        }
        
        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
        let nv = UINavigationController.init(rootViewController: vc!)
        rootviewcontroller.rootViewController = nv
//        let mainwindow = (UIApplication.shared.delegate?.window!)!
//        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
//        UIView.transition(with: mainwindow, duration: 0.55001, options: .layoutSubviews, animations: { () -> Void in
//        }) { (finished) -> Void in
//        }
    }
    
}

