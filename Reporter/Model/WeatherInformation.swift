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
    var windSpeedAvg: Double
    var windGust: Double // FIXME
    var windBearing: Int
    var humidityMin: Double
    var humidityMax: Double
    
    struct PropertyKey {
        static let precipitationType = "precipitationType"
        static let rainFall = "rainFall"
        static let temperatureHigh = "temperatureHigh"
        static let temperatureLow = "temperatureLow"
        static let dewPoint = "dewPoint"
        static let windSpeedAvg = "windSpeedAvg"
        static let windGust = "windGust"
        static let windBearing = "windBearing"
        static let humidityMin = "humidityMin"
        static let humidityMax = "humidityMax"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(precipitationType, forKey: PropertyKey.precipitationType)
        coder.encode(rainFall, forKey: PropertyKey.rainFall)
        coder.encode(temperatureHigh, forKey: PropertyKey.temperatureHigh)
        coder.encode(temperatureLow, forKey: PropertyKey.temperatureLow)
        coder.encode(dewPoint, forKey: PropertyKey.dewPoint)
        coder.encode(windSpeedAvg, forKey: PropertyKey.windSpeedAvg)
        coder.encode(windGust, forKey: PropertyKey.windGust)
        coder.encode(windBearing, forKey: PropertyKey.windBearing)
        coder.encode(humidityMin, forKey: PropertyKey.humidityMin)
        coder.encode(humidityMax, forKey: PropertyKey.humidityMax)
    }
    
    required convenience init?(coder: NSCoder) {
        
        let precipitationType = coder.decodeObject(forKey: PropertyKey.precipitationType) as? String ?? ""
        
        let rainFall = coder.decodeDouble(forKey: PropertyKey.rainFall)
        
        let temperatureHigh = coder.decodeDouble(forKey: PropertyKey.temperatureHigh)
        
        let temperatureLow = coder.decodeDouble(forKey: PropertyKey.temperatureLow)
        
        let dewPoint = coder.decodeDouble(forKey: PropertyKey.dewPoint)
        
        let windSpeedAvg = coder.decodeDouble(forKey: PropertyKey.windSpeedAvg)
        
        let windGust = coder.decodeDouble(forKey: PropertyKey.windGust)
        
        let windBearing = coder.decodeInteger(forKey: PropertyKey.windBearing)
        
        let humidityMin = coder.decodeDouble(forKey: PropertyKey.humidityMin)
        
        let humidityMax = coder.decodeDouble(forKey: PropertyKey.humidityMax)
        
        
        self.init(precipType: precipitationType, rainFall: rainFall, tempHigh: temperatureHigh, tempLow: temperatureLow, dewPoint: dewPoint, windSpeedAvg: windSpeedAvg, windGust: windGust, windBearing: windBearing, humidityMin: humidityMin, humidityMax: humidityMax)
    }
    
    init(precipType: String, rainFall: Double, tempHigh: Double, tempLow: Double, dewPoint: Double, windSpeedAvg: Double, windGust: Double, windBearing: Int, humidityMin: Double, humidityMax: Double) {
        
        self.precipitationType = precipType
        self.rainFall = rainFall
        self.temperatureHigh = tempHigh
        self.temperatureLow = tempLow
        self.dewPoint = dewPoint
        self.windSpeedAvg = windSpeedAvg
        self.windGust = windGust
        self.windBearing = windBearing
        self.humidityMin = humidityMin
        self.humidityMax = humidityMax
    }
    
    init(weatherData: WeatherData) {
        
        self.precipitationType = weatherData.precipitationType
        self.rainFall = weatherData.rainFall
        self.temperatureHigh = weatherData.temperatureHigh
        self.temperatureLow = weatherData.temperatureLow
        self.dewPoint = weatherData.dewPoint
        self.windSpeedAvg = weatherData.windSpeedAvg
        self.windGust = weatherData.windGust
        self.windBearing = weatherData.windBearing
        self.humidityMin = weatherData.humidityMin
        self.humidityMax = weatherData.humidityMax
    }
    
}
