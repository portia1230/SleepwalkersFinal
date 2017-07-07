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
    
    
    //MARK: - Emoji Properties
    let sunEmoji = "☀️"
    let moonEmoji = "🌙"
    let clockEmoji = "⏱"
    
    //MARK: - IBOutlet Properties
    @IBOutlet weak var nameOfContactTextField: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var sleepModeLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    
    var steps = 0
    
    
    //MARK: - Help button related functions
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil{
                print(error)
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getHelpButtonTapped(_ sender: UIButton) {
        let location = getLocation(manager: locationManager)
        reverseGeocoding(latitude: location.latitude, longitude: location.longitude)
        //}
    }
    
    //MARK: - Unwind and view did load actions
    
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue){
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
        mainButton.layer.cornerRadius = 100
        
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
            mainButton.backgroundColor = UIColor.blue
            self.sleepModeLabel.text = "Tap before 😴"
        }
        
        if isGettingLocation {
            isGettingLocation = false
            avPlayer?.stop()
            isRinging = false
            mainButton.setAttributedTitle(NSAttributedString(string: sunEmoji), for: .normal)
            mainButton.backgroundColor = UIColor.blue
            self.sleepModeLabel.text = "Tap before 😴"
            
        } else {
            isGettingLocation = true
            avPlayer?.stop()
            mainButton.setAttributedTitle(NSAttributedString(string: moonEmoji), for: .normal)
            mainButton.backgroundColor = UIColor.black
            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("detectSteps"), userInfo: nil, repeats: true)
            self.sleepModeLabel.text = "Tap when awake 🛌"
            
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
                mainButton.setAttributedTitle(NSAttributedString(string: clockEmoji), for: .normal)
                mainButton.backgroundColor = UIColor.white
                isRinging = true
                self.sleepModeLabel.text = "Tap to stop alarm ⏰"
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
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
