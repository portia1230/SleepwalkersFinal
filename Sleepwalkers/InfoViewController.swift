//
//  InfoViewController.swift
//  Sleepwalkers
//
//  Created by Victoria Corrodi on 7/6/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 15
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Class Functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let identifier = segue.identifier{
            if identifier == "gotIt"{
                print("got it button rewind performed")
            }
        }
    }
    
    //MARK: - Segue function
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "gotIt"{
            return true
        }
        return false
    }
    
}
