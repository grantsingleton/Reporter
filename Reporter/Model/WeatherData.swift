//
//  WeatherData.swift
//  Reporter
//
//  Created by Grant Singleton on 12/2/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation
import WXKDarkSky
import CoreLocation
import os.log

class WeatherData {
    
    //MARK: Properties
    var coordinates: CLLocationCoordinate2D
    var precipitationType: String = ""
    var rainFall: Double = 0.0
    var temperatureHigh: Double = 0.0
    var temperatureLow: Double = 0.0
    var dewPoint: Double = 0.0
    var windSpeedAvg: Double = 0.0
    var windGust: Double = 0.0
    var windBearing: Int = 0
    var humidityMin: Double
    var humidityMax: Double
    var weatherDate: Date
    
    let dispatchGroup = DispatchGroup()
        
    init(coordinates: CLLocationCoordinate2D, weatherDate: Date) {
        
        self.coordinates = coordinates
        self.weatherDate = weatherDate
        
        // temp initialize before async call
        self.precipitationType = ""
        self.rainFall = 0.0
        self.temperatureHigh = 0.0
        self.temperatureLow = 0.0
        self.dewPoint = 0.0
        self.windSpeedAvg = 0.0
        self.windGust = 0.0
        self.windBearing = 0
        self.humidityMin = 0.0
        self.humidityMax = 0.0
        
        getWeatherAsync()
        
    }
    
    func getWeatherAsync() {
        
        let darkSkyRequest = DarkSkyRequest(key: "99c234c1ba74ab4b1d68041b623e3089")
        let requestPoint = DarkSkyRequest.Point(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let options = DarkSkyRequest.Options(exclude: [.minutely, .alerts], extendHourly: false, language: .english, units: .imperial)
        
        darkSkyRequest.loadData(point: requestPoint, time: self.weatherDate, options: options) { (response, error) in
            if let error = error {
                print("Weather fetch error encountered: \(error.localizedDescription)")
            } else if let response = response {
                
                if let todaysWeather = response.daily?.data[0] {
                    self.precipitationType = todaysWeather.precipType ?? ""
                    self.temperatureHigh = todaysWeather.temperatureHigh ?? 0.0
                    self.temperatureLow = todaysWeather.temperatureLow ?? 0.0
                    self.dewPoint = todaysWeather.dewPoint ?? 0.0
                    self.windBearing = todaysWeather.windBearing ?? 0
                    
                    // Calculate the rainfall, average wind speed, min & max humidity
                    let rangeMin = 0
                    let rangeMax = 17
                    var rainFallSum = 0.0;
                    var windSpeedSum = 0.0
                    var humidityArray: [Double] = []
                    
                    if let hourlyWeather = response.hourly?.data {
                        for index in rangeMin...rangeMax {
                            // Sum precipitation intensity from midnight to 5PM
                            rainFallSum += hourlyWeather[index].precipIntensity ?? 0.0
                            windSpeedSum += hourlyWeather[index].windSpeed ?? 0.0
                            humidityArray.append(hourlyWeather[index].humidity ?? 2.0)
                            
                        }
                        self.windSpeedAvg = windSpeedSum / Double((rangeMax - rangeMin + 1))
                        self.rainFall = rainFallSum
                        // calculate min and max humidity
                        var max = 1.0
                        var min = 0.0
                        for number in humidityArray {
                            if (number <= 1) {
                                if (number > max) {
                                    max = number
                                }
                                if (number < min) {
                                    min = number
                                }
                            }
                        }
                        self.humidityMin = min
                        self.humidityMax = max
                    }
                }
            }
        }
    }
    
}
