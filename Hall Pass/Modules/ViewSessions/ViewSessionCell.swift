//
//  ViewSessionCell.swift
//  Break Tracker
//
//  Created by Ali Murad on 12/12/2023.
//

import UIKit

class ViewSessionCell: UITableViewCell {
    @IBOutlet weak var breaktime: UILabel!
    @IBOutlet weak var signin: UILabel!
    @IBOutlet weak var signout: UILabel!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
    func prepareCell(breakTime: String, sigin: String, signout: String, period: String, name: String) {
        let boldAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        
        let breakTimeText = NSMutableAttributedString(string: "Break time: \(breakTime)")
        breakTimeText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 11))
        self.breaktime.attributedText = breakTimeText
        
        let signInText = NSMutableAttributedString(string: "Signin at: \(sigin)")
        signInText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 10))
        self.signin.attributedText = signInText
        
        let signOutText = NSMutableAttributedString(string: "Signout at: \(signout)")
        signOutText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 11))
        self.signout.attributedText = signOutText
        
        let periodText = NSMutableAttributedString(string: "Period: \(period)")
        periodText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 7))
        self.period.attributedText = periodText
        
        let nameText = NSMutableAttributedString(string: "Name: \(name)")
        nameText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 6))
        self.name.attributedText = nameText
    }


}
