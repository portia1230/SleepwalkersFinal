//
//  InitialViewController.swift
//  Sleepwalkers
//
//  Created by Portia Wang on 7/5/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController{
    
    //Properties
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var labelView: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Functions
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if defaults.string(forKey: "name") != nil {
            performSegue(withIdentifier: "toMainController", sender: self)
        } else {
            performSegue(withIdentifier: "signUpSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 15
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
}
