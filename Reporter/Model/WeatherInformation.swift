//
//  WeatherInformation.swift
//  Reporter
//
//  Created by Grant Singleton on 12/13/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//
// This class is a container for WeatherData info
// For the purpose of making a non async dependent class to be NSCoding complient for saving weather data to the disk
import Foundation

class WeatherInformation: NSObject, NSCoding {
    
    
    //MARK: Properties
    var precipitationType: String
    var rainFall: Double
    var temperatureHigh: Double
    var temperatureLow: Double
    var dewPoint: Double
    var windSpeed: Double
    var windBearing: Double
    
    struct PropertyKey {
        static let precipitationType = "precipitationType"
        static let rainFall = "rainFall"
        static let temperatureHigh = "temperatureHigh"
        static let temperatureLow = "temperatureLow"
        static let dewPoint = "dewPoint"
        static let windSpeed = "windSpeed"
        static let windBearing = "windBearing"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(precipitationType, forKey: PropertyKey.precipitationType)
        coder.encode(rainFall, forKey: PropertyKey.rainFall)
        coder.encode(temperatureHigh, forKey: PropertyKey.temperatureHigh)
        coder.encode(temperatureLow, forKey: PropertyKey.temperatureLow)
        coder.encode(dewPoint, forKey: PropertyKey.dewPoint)
        coder.encode(windSpeed, forKey: PropertyKey.windSpeed)
        coder.encode(windBearing, forKey: PropertyKey.windBearing)
    }
    
    required convenience init?(coder: NSCoder) {
        
        let precipitationType = coder.decodeObject(forKey: PropertyKey.precipitationType) as? String ?? ""
        
        let rainFall = coder.decodeDouble(forKey: PropertyKey.rainFall)
        
        let temperatureHigh = coder.decodeDouble(forKey: PropertyKey.temperatureHigh)
        
        let temperatureLow = coder.decodeDouble(forKey: PropertyKey.temperatureLow)
        
        let dewPoint = coder.decodeDouble(forKey: PropertyKey.dewPoint)
        
        let windSpeed = coder.decodeDouble(forKey: PropertyKey.windSpeed)
        
        let windBearing = coder.decodeDouble(forKey: PropertyKey.windBearing)
        
        
        self.init(precipType: precipitationType, rainFall: rainFall, tempHigh: temperatureHigh, tempLow: temperatureLow, dewPoint: dewPoint, windSpeed: windSpeed, windBearing: windBearing)
    }
    
    init(precipType: String, rainFall: Double, tempHigh: Double, tempLow: Double, dewPoint: Double, windSpeed: Double, windBearing: Double) {
        
        self.precipitationType = precipType
        self.rainFall = rainFall
        self.temperatureHigh = tempHigh
        self.temperatureLow = tempLow
        self.dewPoint = dewPoint
        self.windSpeed = windSpeed
        self.windBearing = windBearing
    }
    
    init(weatherData: WeatherData) {
        
        self.precipitationType = weatherData.precipitationType
        self.rainFall = weatherData.rainFall
        self.temperatureHigh = weatherData.temperatureHigh
        self.temperatureLow = weatherData.temperatureLow
        self.dewPoint = weatherData.dewPoint
        self.windSpeed = weatherData.windSpeed
        self.windBearing = weatherData.windBearing
    }
    
}
