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
    
    //MARK: Data Properties
    var job: Job
    var jobLocationName: String
    var jobDescription: String
    
    //MARK: Page Properties
    let topMargin: CGFloat = 18.0
    let verticalSpace: CGFloat = 10.0 // distance between lines
    let doubleVerticalSpace: CGFloat = 20.0
    let sideMargin: CGFloat = 50.0
    let spaceBar: CGFloat = 5.0
    
    // I dont know if I like this variable but here it is
    // Height of a paragraph word
    let wordHeight: CGFloat = 0.0
    
    // Set the font for the title
    let titleFont = UIFont(name: "Helvetica Bold", size: 14)
    let titleBackupFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    
    // set font for smaller title
    let smallTitleFont = UIFont(name: "Helvetica Bold", size: 12)
    let smallTitleBackupFont = UIFont.systemFont(ofSize: 12, weight: .bold)
    
    // Set font for paragraphs
    let paragraphFont = UIFont(name: "Helvetica", size: 12)
    let paragraphBackupFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    init(job: Job, jobLocationName: String, jobDescription: String) {
        self.job = job
        self.jobLocationName = jobLocationName
        self.jobDescription = jobDescription
    }
    
    func buildPDF() -> Data {
        
        /*
          SET PAGE CONTENT PROPERTIESiop;[']
         
         */
        let locationTitle = self.jobLocationName
        let jobDescription = self.jobDescription
        let jobNumber = self.job.jobNumber!
        let reportNumber = "Daily Field Report " + String(self.job.reportNumber!)
        
        let dayOfVisit = "Day of Visit: " + self.job.date
        
        // get the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        let todaysDate = Date()
        let dateString = dateFormatter.string(from: todaysDate)
        
        // Set the issue date to be todays date
        let issueDate = "Issued: " + dateString
        
        let issuedBy = "Issued by: " + self.job.issuedBy!
        
        let purposeTitle = "Purpose of Visit:"
        
        let purposeOfVisit = self.job.purposeOfVisit!
        
        // Count the number of flags
        let redFlagsCount = countFlags(type: JobContentItem.Severity.RED)
        let yellowFlagsCount = countFlags(type: JobContentItem.Severity.YELLOW)
        let greenFlagsCount = countFlags(type: JobContentItem.Severity.GREEN)
        
        // This is where we list the flags that are in the report
        let findingsTitle = "Findings of Visit:"
        
        let redFlags = "Red Flags - " + String(redFlagsCount)
        let yellowFlags = "Yellow Flags - " + String(yellowFlagsCount)
        let greenFlags = "Green Flags - " + String(greenFlagsCount)
        
        
        /*
         ***FIXME**** Add dynamic weather date here when you get to that point
         */

        
        
        /*
         SET PAGE FORMATTING PROPERTIES
        */
        let  pageWidth = 612 // 8.5 * 72
        let pageHeight = 11 * 72
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Create a pdf renderer with those dimensions
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // set attributes (font) of pdf text
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            //MARK: Begin Cover Page
            // **FIXME** temp hardcode of logo image
            let logoImage = UIImage(named: "Z6logo")
            
            let bottomOfLogo = addLogoImage(pageRect: pageRect, imageTop: topMargin, image: logoImage!)

            
            //MARK: Centered Title
            // Job Location Title
            var bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfLogo + 18, title: locationTitle, titleFont: titleFont ?? titleBackupFont)
            
            // Job Description Title
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: jobDescription, titleFont: titleFont ?? titleBackupFont)
            
            // Job Number Title
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: jobNumber, titleFont: titleFont ?? titleBackupFont)
            
            // Report Number Title
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: reportNumber, titleFont: titleFont ?? titleBackupFont)
            
            
            //MARK: Small title
            // Day of Visit Title
            bottomOfTitle = addTitle(pageRect: pageRect, titleTop: bottomOfTitle + verticalSpace, title: dayOfVisit, titleFont: smallTitleFont ?? smallTitleBackupFont)
            
            
            //MARK: Left Title
            // Issue Date Title
            var bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitle + doubleVerticalSpace, title: issueDate, font: (smallTitleFont ?? smallTitleBackupFont))
            
            // Issued By Title
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace, title: issuedBy, font: (smallTitleFont ?? smallTitleBackupFont))
            
            //MARK: Purpose of Visit
            // Purpose Title
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + doubleVerticalSpace, title: purposeTitle, font: (smallTitleFont ?? smallTitleBackupFont))
            
            // Purpose of Visit Content
            let bottomOfParagraph = addParagraph(pageRect: pageRect, textTop: bottomOfTitleTuple.bottom + verticalSpace, paragraphText: purposeOfVisit, font: (paragraphFont ?? paragraphBackupFont))
    
            //MARK: Findings of Visit (Flags)
            // Finding of Visit Title
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfParagraph + verticalSpace, title: findingsTitle, font: (smallTitleFont ?? smallTitleBackupFont))
            
            // Flag Count
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace + 10, title: redFlags, font: (smallTitleFont ?? smallTitleBackupFont))
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace, title: yellowFlags, font: (smallTitleFont ?? smallTitleBackupFont))
            bottomOfTitleTuple = addSectionTitleLeft(pageRect: pageRect, titleTop: bottomOfTitleTuple.bottom + verticalSpace, title: greenFlags, font: (smallTitleFont ?? smallTitleBackupFont))
            
            
            //MARK: Begin Content
            context.beginPage()
            var bottomOfContent: CGFloat = topMargin
            var photoNumber = 1
            
            for item in self.job.content {
                
                // draw a photo content item
                if (item.photo != UIImage(named: "defaultPhoto")) {
                    
                    photoNumber += 1
                    // If the image and three lines can fit on the page then draw it on the page, otherwise start a new page (Add an AI which resizes image if it barely doesnt fit)
                    if imageCanFitOnPage(pageRect: pageRect, imageTop: bottomOfContent, image: item.photo!, font: (smallTitleFont ?? smallTitleBackupFont)) {
                        
                        bottomOfContent = addContentItem(pageRect: pageRect, item: item, photoNumber: photoNumber, contentTop: bottomOfContent)
                        bottomOfContent += verticalSpace

                    }
                    
                    // if it cant fit on the page then start a new page
                    else {
                        // begin a new page
                        context.beginPage()
                        bottomOfContent = addContentItem(pageRect: pageRect, item: item, photoNumber: photoNumber, contentTop: topMargin)
                        bottomOfContent += verticalSpace
                    }
                    
                }
                // draw a text content item
                else {
                    // draw a content only item
                }
                
                //MARK: Draw Paragraph
                // if there is a long description then write it... word... by... painful... word...
                if (item.longDescription != "") {
                    
                    let wordArray = item.longDescription.components(separatedBy: " ")
                    var wordEdge = (right: sideMargin, bottom: bottomOfContent)
                    
                    for word in wordArray {
                        // if word fits in row, then draw it there
                        if (wordFitsInRow(pageRect: pageRect, edge: wordEdge, word: word, font: (paragraphFont ?? paragraphBackupFont))) {
                            wordEdge = addWordToLine(pageRect: pageRect, edge: wordEdge, word: word, font: (paragraphFont ?? paragraphBackupFont))
                        }
                        // If it doesnt fit in row, then start a new line
                        else {
                            if (newlineFits(pageRect: pageRect, edge: wordEdge, word: word, font: (paragraphFont ?? paragraphBackupFont))) {
                                
                                wordEdge = addNewLine(pageRect: pageRect, edge: wordEdge, word: word, font: (paragraphFont ?? paragraphBackupFont))
                            }
                            // else start a new page
                            else {
                                context.beginPage()
                                wordEdge = (right: sideMargin, bottom: topMargin)
                                // subtract spacebar from edge.right since the function addWordToLine will add spacebar. This only matters for the first word in a new line
                                wordEdge.right = wordEdge.right - verticalSpace
                                wordEdge = addWordToLine(pageRect: pageRect, edge: wordEdge, word: word, font: (paragraphFont ?? paragraphBackupFont))
                            }
                        }
                    }
                    // set bottom of content to the bottom of the paragraph to be used for next content item
                    wordEdge.bottom += verticalSpace + getWordHeight(pageRect: pageRect, font: (paragraphFont ?? paragraphBackupFont)) + verticalSpace
                    bottomOfContent = wordEdge.bottom
                }
            }
        }
        return data
    }
    
    func addLogoImage(pageRect: CGRect, imageTop: CGFloat, image: UIImage) -> CGFloat {
        
        // set the image to be at most 15% of the page height and 15% of the page width
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
    
    func addImage(pageRect: CGRect, imageTop: CGFloat, image: UIImage) -> CGFloat {
        
        // set the image to be at most 15% of the page height and 15% of the page width
        let maxHeight = pageRect.height * 0.40
        let maxWidth = pageRect.width * 0.75
        
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
    
    // This function returns the location on the pdf that the end of the image plus 3 lines will end at
    // It is useful to know if it will fit on the current page or needs to be moved to another
    func imageCanFitOnPage(pageRect: CGRect, imageTop: CGFloat, image: UIImage, font: UIFont) -> Bool {
        
        /*
            First find the bottom of the image
         */
        
        // set the image to be at most 5% of the page height and 10% of the page width
        let maxHeight = pageRect.height * 0.40
        let maxWidth = pageRect.width * 0.75
        
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
        
        var bottomOfContent = imageRect.origin.y + imageRect.size.height
        
        
        
        /*
          Now find the bottom after adding three lines of text
            */
        
        let testString = "Test String"
        
        // set the attributes for the title
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed title with the text of the title and the font
        let attributedTitle = NSAttributedString(string: testString, attributes: titleAttributes)
        
        // get the rectangle size that the text fits in
        let titleStringSize = attributedTitle.size()
        
        // Set the top (y) of the title text to titleTop which is passed from caller
        // set the x coordninate to center the title text
        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0, y: bottomOfContent + verticalSpace, width: titleStringSize.width, height: titleStringSize.height)
        
        // return y coordinate for the bottom of the rectangle
        bottomOfContent += titleStringRect.size.height * 3
        
        // check if drawing this on the page would fit or not
        if ( bottomOfContent > (pageRect.size.height - (topMargin * 2)) ) {
            return false
        } else {
            return true
        }
    
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
    
    func addSectionTitleLeft(pageRect: CGRect, titleTop: CGFloat, title: String, font: UIFont) -> (bottom: CGFloat, right: CGFloat) {
        
        // set the attributes for the title
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
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
    
    func addParagraph(pageRect: CGRect, textTop: CGFloat, paragraphText: String, font: UIFont) -> CGFloat {
        
        // Set paragraph information. (wraps at word breaks)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        // Set the text attributes
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font
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
    
    func addWordToLine(pageRect: CGRect, edge: (right: CGFloat, bottom: CGFloat), word: String, font: UIFont) -> (right: CGFloat, bottom: CGFloat) {
        
        // set the attributes for the word
        let wordAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed word with the text of the word and the font
        let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)
        
        // get the rectangle size that the text fits in
        let wordSize = attributedWord.size()
        
        // Set the top (y) of the word to bottom which is passed from caller
        // set the x coordninate to the left margin
        let wordRect = CGRect(x: edge.right + spaceBar, y: edge.bottom + verticalSpace, width: wordSize.width, height: wordSize.height)
        
        // Draw the word onto the page
        attributedWord.draw(in: wordRect)
        
        // return x coordinate for right side of the word. Bottom edge stays the same
        return (right: wordRect.origin.x + wordRect.size.width, bottom: edge.bottom)
    }
    
    func addNewLine(pageRect: CGRect, edge: (right: CGFloat, bottom: CGFloat), word: String, font: UIFont) -> (right: CGFloat, bottom: CGFloat) {
        
        // set the attributes for the word
        let wordAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed word with the text of the word and the font
        let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)
        
        // get the rectangle size that the text fits in
        let wordSize = attributedWord.size()
        
        // Set the top (y) of the word to bottom (passed by caller) + vertical space + word height + vertical space
        // set the x coordninate to the left margin
        let wordRect = CGRect(x: sideMargin, y: edge.bottom + verticalSpace + wordSize.height + verticalSpace, width: wordSize.width, height: wordSize.height)
        
        // Draw the word onto the page
        attributedWord.draw(in: wordRect)
        
        return (right: wordRect.origin.x + wordRect.size.width, bottom: edge.bottom + verticalSpace + wordRect.size.height)
    }
    
    func wordFitsInRow(pageRect: CGRect, edge: (right: CGFloat, bottom: CGFloat), word: String, font: UIFont) -> Bool {
        
        // set the attributes for the word
        let wordAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed word with the text of the word and the font
        let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)
        
        // get the rectangle size that the word fits in
        let wordSize = attributedWord.size()
        
        // if adding this word fits between the margins
        if ( (edge.right + spaceBar + wordSize.width) > (pageRect.size.width - sideMargin) ) {
            return false
        } else {
            return true
        }
      
    }
    
    func newlineFits(pageRect: CGRect, edge: (right: CGFloat, bottom: CGFloat), word: String, font: UIFont) -> Bool {
        
        // set the attributes for the word
        let wordAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed word with the text of the word and the font
        let attributedWord = NSAttributedString(string: word, attributes: wordAttributes)
        
        // get the rectangle size that the word fits in
        let wordSize = attributedWord.size()
        
        // see if adding the newline fits on the page
        if ( (edge.bottom + verticalSpace + wordSize.height) > (pageRect.size.height - topMargin) ) {
            return false
        } else {
            return true
        }
        
    }
    
    func getWordHeight(pageRect: CGRect, font: UIFont) -> CGFloat {
        
        let testString = "Testing"
        
        // set the attributes for the word
        let wordAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        // create an attributed word with the text of the word and the font
        let attributedWord = NSAttributedString(string: testString, attributes: wordAttributes)
        
        // get the rectangle size that the word fits in
        let wordSize = attributedWord.size()
        
        // return the height of the word
        return wordSize.height
    }
    
    //MARK: Helper Functions
    func flagFactory(flag: JobContentItem.Severity) -> String {
        
        switch flag {
        case JobContentItem.Severity.RED:
            return "Red Flag"
        case JobContentItem.Severity.YELLOW:
            return "Yellow Flag"
        case JobContentItem.Severity.GREEN:
            return "Green Flag"
        }
        
    }

    func addContentItem(pageRect: CGRect, item: JobContentItem, photoNumber: Int, contentTop: CGFloat) -> CGFloat {
        
        var bottomOfContent = contentTop
        
        var photoNumberString = ""
        if (photoNumber >= 10) {
            photoNumberString = String(photoNumber)
        } else {
            photoNumberString = "0" + String(photoNumber)
        }
        photoNumberString = "Photo " + photoNumberString
        bottomOfContent = addImage(pageRect: pageRect, imageTop: bottomOfContent, image: item.photo!)
        bottomOfContent = addTitle(pageRect: pageRect, titleTop: bottomOfContent, title: photoNumberString, titleFont: (smallTitleFont ?? smallTitleBackupFont))
        let flagString = flagFactory(flag: item.status)
        bottomOfContent = addTitle(pageRect: pageRect, titleTop: bottomOfContent + (verticalSpace / 2.0), title: flagString, titleFont: (smallTitleFont ?? smallTitleBackupFont))
        bottomOfContent = addTitle(pageRect: pageRect, titleTop: bottomOfContent + (verticalSpace / 2.0), title: item.shortDescription, titleFont: (smallTitleFont ?? smallTitleBackupFont))
        
        return bottomOfContent
    }
    
    //Used to count the number of a certain color of severity flag for a list of content items
    func countFlags(type: JobContentItem.Severity) -> Int {
        
        var count: Int = 0
        
        for item in self.job.content {
            
            if (item.status == type){
                count += 1
            }
        }
        return count
    }
    
}
