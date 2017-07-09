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
        if mainButton.titleLabel?.text == clockEmoji{
            return .lightContent
        }
        if mainButton.titleLabel?.text == sunEmoji{
            return .default
        }
        return .lightContent
    }
//
    //MARK: - Emoji Properties
    let sunEmoji = "☀️"
    let moonEmoji = "🌙"
    let clockEmoji = "⏰"
    let tiffanyColor = UIColor(red: 82/255, green: 225/255, blue: 192/255, alpha: 1)
    let navyColor = UIColor(red: 2/255, green: 23/255, blue: 51/255, alpha: 1)
    let darkGrayColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
    let lightGrayColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
    
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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    
    
    
    
    //MARK: - Help button related functions
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if isGettingLocation {
            self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityView.color = UIColor.white
        }
        else {
            self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityView.color = UIColor.black
        }
        self.sendMessageButton.setTitle("", for: .normal)
        self.activityView.isHidden = false
        
        self.activityView.startAnimating()
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
 //           composeVC.recipients = [defaults.string(forKey: "contactName")!]
            var trimmed = self.location
            trimmed = trimmed.replacingOccurrences(of: "\n", with: ", ")
            composeVC.body = "Hey \(name), I sleepwalked and need your help! Find me around: \(trimmed)!"
            self.activityView.stopAnimating()
            self.present(composeVC, animated: true,completion: nil)
            self.sendMessageButton.setTitle("Send Message to Contact", for: .normal)
            
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MainViewController.detectSteps), userInfo: nil, repeats: isGettingLocation )
    }
    
    func reloadTimer() {
         _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainViewController.detectSteps), userInfo: nil, repeats: isGettingLocation )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendMessageButton.layer.cornerRadius = 15
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        
        self.activityView.isHidden = true
        
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
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
            mainButton.setAttributedTitle(NSAttributedString(string: sunEmoji), for: .normal)
            self.backgroundView.layer.backgroundColor = lightGrayColor.cgColor
            self.contactNumber.textColor = darkGrayColor
            self.nameOfContactTextField.textColor = darkGrayColor
            self.sleepModeLabel.textColor = darkGrayColor
            self.sleepModeLabel.text = "Tap before Sleeping"
        }
        
        if isGettingLocation {
            isGettingLocation = false
            avPlayer?.stop()
            isRinging = false
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
            mainButton.setAttributedTitle(NSAttributedString(string: sunEmoji), for: .normal)
            self.backgroundView.backgroundColor = lightGrayColor
            self.sleepModeLabel.text = "Tap before Sleeping"
            self.backgroundView.backgroundColor = lightGrayColor
            self.contactNumber.textColor = darkGrayColor
            self.nameOfContactTextField.textColor = darkGrayColor
            self.sleepModeLabel.textColor = darkGrayColor
            
            
        } else {
            isGettingLocation = true
            self.reloadTimer()
            avPlayer?.stop()
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
            mainButton.setAttributedTitle(NSAttributedString(string: moonEmoji), for: .normal)
            self.backgroundView.backgroundColor = navyColor
            self.sleepModeLabel.text = "Tap when Awake"
            //self.contactNumber.textColor = lightGrayColor
            //self.nameOfContactTextField.textColor = lightGrayColor
            self.sleepModeLabel.textColor = darkGrayColor
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
//            print(self.steps)
            if self.steps >= 3{
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

