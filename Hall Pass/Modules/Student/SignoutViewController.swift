//
//  SignoutViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import UIKit

class SignoutViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var signoutTime: UILabel!
    @IBOutlet weak var signinTime: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var siginView: UIView!
    @IBOutlet weak var sigin: UIButton!
    
    var signOutDate: Date?
    var selectedStudent: Student?
    var selectedPeriod: Period?
    var session: Session?
    weak var delegate: SignoutViewCallback?
    
    var timerr: Timer?
    var currentTime = Date().startOfDay
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = selectedStudent?.studentName ?? "N/A"
        if let selectedStudent, let signOutDate, let selectedPeriod {
            signoutTime.text = signOutDate.toTimeString()
            date.text = signOutDate.toDateString()
            session = RealmManager.shared.startSession(student: selectedStudent, signOut: signOutDate, period: selectedPeriod)
            timerr = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
            
        }
    }
    
    @objc func updateTimeLabel() {
        currentTime = currentTime.addingTimeInterval(1.0) // Increment time by 1 second
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let formattedTime = dateFormatter.string(from: currentTime)
        timer.text = formattedTime
    }
    
    
    
    @IBAction func actSignin(_ sender: Any) {
        let time = Date()
        if let session = self.session {
            RealmManager.shared.endSession(sessionID: session.sessionID, signin: time)
        }
        timerr?.invalidate()
        signinTime.text = time.toTimeString()
        siginView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.dismiss(animated: true)
            self.delegate?.resetView()
           
        })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerr?.invalidate()
        timerr = nil
    }
}
