//
//  ViewController.swift
//  Hall Pass
//
//  Created by Ahmad Azam on 08/12/2023.
//

import UIKit

class StudentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerView: UIPickerView!
    @IBOutlet private var periodSelector: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create UIPickerView
        pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        periodSelector.inputView = pickerView
       
       
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if let periods = RealmManager.shared.getPeriods(), row < periods.count {
            let period = periods[row]
            return NSAttributedString(string: period.periodName, attributes: [.foregroundColor: UIColor.red])
            
        } else {
            return nil
        }
  
    }

    // MARK: - UIPickerViewDelegate and UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RealmManager.shared.getPeriods()?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let periods = RealmManager.shared.getPeriods(), row < periods.count {
            let period = periods[row]
            return period.periodName
        } else {
            return nil
        }
        
    }
    
    
}
