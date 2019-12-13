//
//  PDFBuilder.swift
//  Reporter
//
//  Created by Grant Singleton on 12/1/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import CoreLocation

class PDFBuilder {
    
    var name: String
    var contentList: [JobContentItem]
    var weatherData: WeatherInformation
    
    init(name: String, contentList: [JobContentItem], weatherData: WeatherInformation) {
        self.name = name
        self.contentList = contentList
        self.weatherData = weatherData
    }
    
    func buildPDF() -> Data {
        
        // Set dimensions for the page
        let  pageWidth = 612 // 8.5 * 72
        let pageHeight = 11 * 72
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Create a pdf renderer with those dimensions
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // set attributes (font) of pdf text
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // **FIXME** temp hardcode of logo image
            let logoImage = UIImage(named: "Z6logo")
            
            let bottomOfLogo = addLogoImage(pageRect: pageRect, imageTop: 18, image: logoImage!)
            
            // Set vertical space for text content
            let verticalSpace: CGFloat = 10.0
            
            // Set the font for the title
            var titleFont = UIFont(name: "Helvetica Bold", size: 14)
            var backupFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            
            // **FIXME** temp hardcode of text
            let locationTitle = "UTMB Hospital"
            var bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfLogo + 18, title: locationTitle, titleFont: titleFont ?? backupFont)
            
            // **FIXME** temp hardcode of text
            let jobDescription = "Modernization and Facade Replacement"
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: jobDescription, titleFont: titleFont ?? backupFont)
            
            // **FIXME** temp hardcode of text
            let jobNumber = "UTMB 59562"
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: jobNumber, titleFont: titleFont ?? backupFont)
            
            // **FIXME** temp hardcode of text
            let reportNumber = "Daily Field Report 12"
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: reportNumber, titleFont: titleFont ?? backupFont)
            
            // set font smaller
            titleFont = UIFont(name: "Helvetica Bold", size: 12)
            backupFont = UIFont.systemFont(ofSize: 12, weight: .bold)
            
            // **FIXME** temp hardcode of text
            let dayOfVisit = "Day of Visit: November 25, 2019 (Monday)"
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: dayOfVisit, titleFont: titleFont ?? backupFont)
            
            // **FIXME** temp hardcode of text
            let issueDate = "Issued: November 27, 2019"
            var bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace + 10, title: issueDate)
            
            // **FIXME** temp hardcode of text
            let issuedBy = "Issued by: Joe Inspector"
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace, title: issuedBy)
            
            // **FIXME** temp hardcode of text
            let purposeTitle = "Purpose of Visit:"
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace + 10, title: purposeTitle)
            
            let purposeOfVisit = "This AHU was noted to have  a damaged roof seam directly above the leak location and additional caulking at all metal wall/roof panel on the east end.  "
            var bottomOfParagraph = addParagraph(pageRect: pageRect, textTop: bottomOfTitleTuple.bottom + verticalSpace, paragraphText: purposeOfVisit)
            
            //TEST PURPOSES ONLY
            let randomText = "rectangle is the baseline of the only line. The text will be displayed above the rectangle and not inside of it. For example, if you specify a rectangle starting at 0,0 and draw the string ‘juxtaposed’, only the descenders of the ‘j’ and ‘p’ will be seen. The rest of the text will be on the top edge of the rectangle."
            bottomOfParagraph = addParagraph(pageRect: pageRect, textTop: bottomOfParagraph + verticalSpace, paragraphText: randomText)
        }
        return data
    }
    
    func addLogoImage(pageRect: CGRect, imageTop: CGFloat, image: UIImage) -> CGFloat {
        
        // set the image to be at most 5% of the page height and 10% of the page width
        let maxHeight = pageRect.height * 0.15
        let maxWidth = pageRect.width * 0.15
        
        // maximize size of the image while ensuring that it fits within constraints and maintains aspect ratio
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        // calculate the scaled height and width to use
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.width * aspectRatio
        
        // calculate horizontal offset to center the image
        let imageX = (pageRect.width - scaledWidth) / 2.0
        // Create a rectangle at this coordinate with size calculated
        let imageRect = CGRect(x: imageX, y: imageTop, width: scaledWidth, height: scaledHeight)
        
        // Draw image into the rectangle this method scales the image to fit inside of the rectangle
        image.draw(in: imageRect)
        // return coordinates of the bottom of the image to the caller
        return imageRect.origin.y + imageRect.size.height
    }
    
    func addTitle(pageRect: CGRect, titleTop: CGFloat, title: String, titleFont: UIFont) -> CGFloat {
        
        // set the attributes for the title
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        
        // create an attributed title with the text of the title and the font
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        
        // get the rectangle size that the text fits in
        let titleStringSize = attributedTitle.size()
        
        // Set the top (y) of the title text to titleTop which is passed from caller
        // set the x coordninate to center the title text
        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0, y: titleTop, width: titleStringSize.width, height: titleStringSize.height)
        
        // Draw the title onto the page
        attributedTitle.draw(in: titleStringRect)
        
        // return y coordinate for the bottom of the rectangle
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addSectionTitleLeft(pageRect: CGRect, titleTop: CGFloat, title: String) -> (bottom: CGFloat, right: CGFloat) {
        
        // Set the font for the title
        let titleFont = UIFont(name: "Helvetica Bold", size: 12)
        let backupFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        // set the attributes for the title
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont ?? backupFont]
        
        // create an attributed title with the text of the title and the font
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        
        // get the rectangle size that the text fits in
        let titleStringSize = attributedTitle.size()
        
        // set the margin
        let margin: CGFloat = 50.0
        
        // Set the top (y) of the title text to titleTop which is passed from caller
        // set the x coordninate to the left margin
        let titleStringRect = CGRect(x: margin, y: titleTop, width: titleStringSize.width, height: titleStringSize.height)
        
        // Draw the title onto the page
        attributedTitle.draw(in: titleStringRect)
        
        // return y coordinate for the bottom of the rectangle
        return (titleStringRect.origin.y + titleStringRect.size.height, titleStringRect.origin.x + titleStringRect.size.width)
    }
    
    func addParagraph(pageRect: CGRect, textTop: CGFloat, paragraphText: String) -> CGFloat {
        
        let textFont = UIFont(name: "Helvetica", size: 12)
        let backupFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // Set paragraph information. (wraps at word breaks)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        // Set the text attributes
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont ?? backupFont
        ]
        
        let attributedText = NSAttributedString(
            string: paragraphText,
            attributes: textAttributes
        )
        
        // determine the size of CGRect needed for the string that was given by caller
        let paragraphSize = CGSize(width: pageRect.width - 100, height: pageRect.height)
        let paragraphRect = attributedText.boundingRect(with: paragraphSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        // Create a CGRect that is the same size as paragraphRect but positioned on the pdf where we want to draw the paragraph
        let positionedParagraphRect = CGRect(
            x: 50,
            y: textTop,
            width: paragraphRect.width,
            height: paragraphRect.height
        )
        
        // draw the paragraph into that CGRect
        attributedText.draw(in: positionedParagraphRect)
        
        return positionedParagraphRect.origin.y + positionedParagraphRect.size.height
    }

}
