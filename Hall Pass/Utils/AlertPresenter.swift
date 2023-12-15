//
//  AlertPresenter.swift
//  Break Tracker
//
//  Created by Ali Murad on 15/12/2023.
//

import UIKit

class AlertPresenter {
    static func showAlert(on viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showConfirmationAlert(on viewController: UIViewController, title: String?, message: String?, confirmActionTitle: String = "OK", cancelActionTitle: String = "Cancel", confirmActionHandler: @escaping () -> Void) {
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { _ in
            confirmActionHandler()
        }
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        
        let actions = [confirmAction, cancelAction]
        
        showAlert(on: viewController, title: title, message: message, actions: actions)
    }
    static func showTextFieldAlert(title: String, message: String, placeholder: String, text: String = "", on viewController: UIViewController, submitHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = text
            textField.placeholder = placeholder
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let text = alertController.textFields?.first?.text {
                submitHandler(text)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

