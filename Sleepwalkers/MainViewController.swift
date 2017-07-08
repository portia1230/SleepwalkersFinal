//
//  MainController.swift
//  Sleepwalkers
//
//  Created by Portia Wang on 7/4/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AVFoundation
import MessageUI
import AddressBookUI
import CoreMotion
import AudioToolbox

class MainViewController : UIViewController, MFMessageComposeViewControllerDelegate {

    //MARK: - Serious Properties
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var isGettingLocation = false
    var isRinging = false
    var avPlayer: AVAudioPlayer!
    var location = ""
    let pedoMeter = CMPedometer()
    let activityManager = CMMotionActivityManager()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Emoji Properties
    let sunEmoji = "☀️"
    let moonEmoji = "🌙"
    let clockEmoji = "⏰"
    let tiffanyColor = UIColor(red: 82, green: 225, blue: 192, alpha: 1)
    let navyColor = UIColor(red: 2, green: 23, blue: 51, alpha: 1)
    let darkGrayColor = UIColor(red: 235, green: 235, blue: 235, alpha: 1)
    let lightGrayColor = UIColor(red: 251, green: 251, blue: 251, alpha: 1)
    
    //MARK: - IBOutlet Properties
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var nameOfContactTextField: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var sleepModeLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    var steps = 0
    
    
    //MARK: - Help button related functions
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil{
                print(error as Any)
                return
            } else if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
                self.location = address
            }
            let composeVC = MFMessageComposeViewController()
            let name = defaults.string(forKey: "contactName")!
            composeVC.messageComposeDelegate = self
            composeVC.recipients = [defaults.string(forKey: "contactNumber")!]
            composeVC.recipients = [defaults.string(forKey: "contactName")!]
            var trimmed = self.location
            trimmed = trimmed.replacingOccurrences(of: "\n", with: ", ")
            composeVC.body = "Hey \(name), I sleepwalked and need your help! Find me around: \(trimmed)!"
            self.present(composeVC, animated: true,completion: nil)
        }
    }
    
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "modifyContact", sender: self)
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toInfo", sender: self)
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getHelpButtonTapped(_ sender: UIButton) {
        let location = getLocation(manager: locationManager)
        reverseGeocoding(latitude: location.latitude, longitude: location.longitude)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "modifyContact"{
            return true
        }
        if identifier == "toInfo"{
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendMessageButton.layer.cornerRadius = 15
        
        nameOfContactTextField.text = "Contact Name: " + ( defaults.string(forKey: "contactName"))!
        contactNumber.text = "Contact Number: " + ( defaults.string(forKey: "contactNumber"))!
        
        // For use in background
        detectSteps()
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    //MARK: - Location related functions + Buttons
    
    @IBAction func mainButtonTapped(_ sender: UIButton) {
        if isRinging{
            avPlayer?.stop()
            isRinging = false
            isGettingLocation = false
            mainButton.setAttributedTitle(NSAttributedString(string: sunEmoji), for: .normal)
            self.backgroundView.layer.backgroundColor = lightGrayColor.cgColor
            self.settingButton.setTitleColor(darkGrayColor, for: .normal)
            self.contactNumber.textColor = darkGrayColor
            self.nameOfContactTextField.textColor = darkGrayColor
            self.sleepModeLabel.textColor = darkGrayColor
            self.infoButton.setTitleColor(darkGrayColor, for: .normal)
            self.sleepModeLabel.text = "Tap before Sleeping"
        }
        
        if isGettingLocation {
            isGettingLocation = false
            avPlayer?.stop()
            isRinging = false
            mainButton.setAttributedTitle(NSAttributedString(string: sunEmoji), for: .normal)
            self.backgroundView.backgroundColor = lightGrayColor
            self.sleepModeLabel.text = "Tap before Sleeping"
            self.backgroundView.backgroundColor = lightGrayColor
            self.settingButton.setTitleColor(darkGrayColor, for: .normal)
            self.contactNumber.textColor = darkGrayColor
            self.nameOfContactTextField.textColor = darkGrayColor
            self.sleepModeLabel.textColor = darkGrayColor
            self.infoButton.setTitleColor(darkGrayColor, for: .normal)
            
            
        } else {
            isGettingLocation = true
            avPlayer?.stop()
            mainButton.setAttributedTitle(NSAttributedString(string: moonEmoji), for: .normal)
            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MainViewController.detectSteps), userInfo: nil, repeats: true)
            self.backgroundView.backgroundColor = navyColor
            self.sleepModeLabel.text = "Tap when Awake"
            self.settingButton.setTitleColor(lightGrayColor, for: .normal)
            self.contactNumber.textColor = lightGrayColor
            self.nameOfContactTextField.textColor = lightGrayColor
            self.sleepModeLabel.textColor = lightGrayColor
            self.infoButton.setTitleColor(lightGrayColor, for: .normal)
        }
        
    }
    
    //MARK: - Wake up and get location functions
    
    func wakeUp() {
        if let urlpath = Bundle.main.path(forResource: "alarmNoise",ofType: "wav") {
            //let url = NSURL.fileURL(withPath: urlpath!)
            let url = URL(fileURLWithPath: urlpath)
            //var audioPlayer = AVAudioPlayer()
            
            do{
                avPlayer = try AVAudioPlayer(contentsOf: url)
                avPlayer.prepareToPlay()
                avPlayer.play()
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                mainButton.setAttributedTitle(NSAttributedString(string: clockEmoji), for: .normal)
                isRinging = true
                self.sleepModeLabel.text = "Tap Alarm to Stop"
                self.backgroundView.layer.backgroundColor = navyColor.cgColor
                self.settingButton.setTitleColor(lightGrayColor, for: .normal)
                self.contactNumber.textColor = lightGrayColor
                self.nameOfContactTextField.textColor = lightGrayColor
                self.sleepModeLabel.textColor = lightGrayColor
                self.infoButton.setTitleColor(lightGrayColor, for: .normal)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            let alertController = UIAlertController(title: "", message:
                "Enable location services in settings for sleepwalkers to function properly", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func getLocation(manager: CLLocationManager) -> CLLocationCoordinate2D {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        return locValue
    }
    
    //MARK: - Step detection function
    
    func detectSteps(){
        if(CMPedometer.isStepCountingAvailable()){
            print(self.steps)
            if self.steps >= 5{
                wakeUp()
            }
            self.steps = 0
            let startTime = Date() as NSDate
            self.pedoMeter.queryPedometerData(from: startTime as Date, to: NSDate() as Date) { (data : CMPedometerData!, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        self.steps = Int(data.numberOfSteps)
                    }
                })
                self.pedoMeter.startUpdates(from: startTime as Date) { (data: CMPedometerData!, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if(error == nil){
                            self.steps = Int(data.numberOfSteps)
                        }
                    })
                }
            }
        }
    }
}
