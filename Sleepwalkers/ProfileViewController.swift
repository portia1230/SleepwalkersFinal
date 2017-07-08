//
//  ViewController.swift
//  Sleepwalkers
//
//  Created by Portia Wang on 7/4/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var defaults: UserDefaults = UserDefaults.standard
class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var name : String?
    
    
    
    //MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 15
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let name = defaults.string(forKey: "name"),
            let nameOfContact = defaults.string(forKey: "contactName"),
            let number = defaults.string(forKey: "contactNumber") {
            nameTextField.text = name
            contactNameTextField.text = nameOfContact
            contactNumberTextField.text = number
            self.name = name
        }
        
    }
    
    
    // MARK: - dismissing keyboard if clicked elsewhere
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - save data in user defaults
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        //
        if (nameTextField.text == "") || (contactNameTextField.text == "") || (contactNumberTextField.text == "") {
            let alertController = UIAlertController(title: "", message:
                "Did you enter all your information correctly?", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            defaults.set(contactNumberTextField.text, forKey:"contactNumber")
            defaults.set(nameTextField.text, forKey:"name")
            defaults.set(contactNameTextField.text, forKey:"contactName")
            
            if self.name != ""{
                self.dismiss(animated: true, completion: {
                })
            } else {
            performSegue(withIdentifier: "showMainSegue", sender: self)
            }
        }
    }
    
}

