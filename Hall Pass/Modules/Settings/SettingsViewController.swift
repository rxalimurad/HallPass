//
//  SettingsViewController.swift
//  Hall Pass
//
//  Created by Ahmad Azam on 08/12/2023.
//

import UIKit
class SettingsViewController: UITableViewController {

    
    @IBOutlet var passCodeSwitch: UISwitch!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Settings"
        self.navigationItem.title = self.title
        passCodeSwitch.isOn = PasscodeKit.enabled()
 
        
    }
    
    @IBAction func onValueChange(_ sender: Any) {
        if passCodeSwitch.isOn {
            PasscodeKit.createPasscode(self)
        } else {
            PasscodeKit.removePasscode(self)
        }
    }
    
   
}

extension SettingsViewController: PasscodeKitDelegate {
    func passcodeEnteredSuccessfully() {
        passCodeSwitch.isOn = PasscodeKit.enabled()
    }
    func passcodeRemoved() {
        passCodeSwitch.isOn = PasscodeKit.enabled()
        
    }
    func onCancel() {
        passCodeSwitch.isOn = PasscodeKit.enabled()
    }
}
