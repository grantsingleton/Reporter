//
//  PDFBuilder.swift
//  Reporter
//
//  Created by Grant Singleton on 12/1/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation
import SimplePDF

class PDFBuilder {
    
    var name: String
    var contentList: [JobContentItem]
    
    init(name: String, contentList: [JobContentItem]) {
        self.name = name
        self.contentList = contentList
    }
    
    func buildPDF() -> Data {
        
        let A4PaperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4PaperSize)
        
        for item in contentList {
            
            pdf.addText(item.shortDescription)
            
            if item.containsPhoto {
                pdf.addImage(item.photo!)
            }
            
            pdf.addVerticalSpace(20)
            
            if item.containsLongDescription {
                pdf.addText(item.longDescription)
            }
            
            pdf.beginNewPage()
        }
        let pdfData = pdf.generatePDFdata()
        return pdfData
    }
}
