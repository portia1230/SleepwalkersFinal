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
class ProfileViewController: UIViewController, UITextFieldDelegate {
    
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
    var alreadyEntered = true
    
    
    
    //MARK: - Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if textField == nameTextField{
            view.endEditing(true)
            contactNameTextField.resignFirstResponder()
            view.endEditing(false)
        }
        if textField == contactNameTextField{
            view.endEditing(true)
            contactNumberTextField.resignFirstResponder()
        }
        if textField == contactNumberTextField{
            view.endEditing(true)

        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        contactNameTextField.delegate = self
        contactNumberTextField.delegate = self
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        nextButton.layer.cornerRadius = 15
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        if contactNameTextField.text != "" {
            alreadyEntered = true
        }
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
            
//            if self.name != "" {
//                self.dismiss(animated: true, completion: {
//                })
//            } else {
            performSegue(withIdentifier: "showMainSegue", sender: self)
//            }
        }
    }
    
}

