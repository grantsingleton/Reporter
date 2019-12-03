//
//  PDFBuilder.swift
//  Reporter
//
//  Created by Grant Singleton on 12/1/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation
import SimplePDF
import CoreLocation

class PDFBuilder {
    
    var name: String
    var contentList: [JobContentItem]
    var weatherData: WeatherData
    
    init(name: String, contentList: [JobContentItem], weatherData: WeatherData) {
        self.name = name
        self.contentList = contentList
        self.weatherData = weatherData
    }
    
    func buildPDF() -> Data {
        
        let A4PaperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4PaperSize)
        
        pdf.addText("Summary: " + weatherData.summary)
        pdf.addText("Icon: " + (weatherData.icon ))
        pdf.addText("Humidity: " + String(format:"%f", weatherData.humidity ))
        pdf.addText("Pressure: " + String(format:"%f", weatherData.pressure ))
        pdf.addText("Temperature: " + String(format:"%f", weatherData.temperature ))
        pdf.addText("Wind Bearing: " + String(format:"%f", weatherData.windBearing ))
        pdf.addText("Wind Speed: " + String(format:"%f", weatherData.windSpeed ))
        pdf.addText("Precipitation Intensity: " + String(format:"%f", weatherData.precipitationIntensity ))
        pdf.addText("Precipitation Type: " + String(format:"%f", weatherData.precipitationType ))

        
        /*
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
        */
        let pdfData = pdf.generatePDFdata()
        return pdfData
    }
}
