//
//  PDFUtil.swift
//  Break Tracker
//
//  Created by Ali Murad on 12/12/2023.
//

import UIKit
import PDFKit
import UIKit
import UIKit

class PDFUtil {
    static func createPDF(groupedSessions: [GroupedSession], appName: String) -> Data? {
        let pageSize = CGSize(width: 595.2, height: 841.8) // A4 page size in points
        var currentPage = 0
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        let pdf = renderer.pdfData { context in
            for (index, group) in groupedSessions.enumerated() {
                let sessionsCount = group.sessions.count
                let numberOfRowsPerPage = Int((pageSize.height - 200) / 30) // Calculate number of rows per page
                
                for startIdx in stride(from: 0, to: sessionsCount, by: numberOfRowsPerPage) {
                    currentPage += 1
                    // Begin a new PDF page
                    context.beginPage()
                    
                    let dateRect = CGRect(x: 50, y: 50, width: pageSize.width - 100, height: 30)
                    drawCell(text: group.signOutDate.toDateString(), in: dateRect)
                    
                    // Define table layout variables
                    let cellWidth = (pageSize.width - 100) / 5 // Adjust the number of columns as needed
                    let cellHeight = CGFloat(30)
                    let numberOfRows = min(numberOfRowsPerPage, sessionsCount - startIdx) // Calculate rows for this page
                    let tableStartY = CGFloat(150)
                    
                    // Draw table headers
                    var headerX = CGFloat(50)
                    let headerY = tableStartY
                    for headerTitle in ["Name", "Period", "Signout", "Signin", "Break Time"] {
                        let headerRect = CGRect(x: headerX, y: headerY, width: cellWidth, height: cellHeight)
                        drawCell(text: headerTitle, in: headerRect)
                        headerX += cellWidth
                    }
                    
                    // Draw table rows for the current page
                    var currentY = tableStartY + cellHeight
                    for i in startIdx..<(startIdx + numberOfRows) {
                        let session = group.sessions[i]
                        var currentX = CGFloat(50)
                        for sessionInfo in [session.student?.studentName, session.period?.periodName, session.signOut.toTimeString(), session.signin.toTimeString(), String(session.signOut.minuteDifference(to: session.signin))] {
                            let cellRect = CGRect(x: currentX, y: currentY, width: cellWidth, height: cellHeight)
                            drawCell(text: sessionInfo ?? "", in: cellRect)
                            currentX += cellWidth
                        }
                        currentY += cellHeight
                    }
                    
                    // Add footer with app name
                    let footerText = "Generated with \(appName)"
                    let footerRect = CGRect(x: 50, y: pageSize.height - 20, width: pageSize.width - 100, height: 30)
                    drawCell(text: footerText, in: footerRect, size: 9)
                }
            }
        }
        
        return pdf
    }
    
    static func drawCell(text: String, in rect: CGRect, size: CGFloat = 12) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size),
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: rect)
    }
}
