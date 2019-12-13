//
//  WeatherData.swift
//  Reporter
//
//  Created by Grant Singleton on 12/2/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation
import DarkSkyKit
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
    var windSpeed: Double = 0.0
    var windBearing: Double = 0.0
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
        self.windSpeed = 0.0
        self.windBearing = 0.0
        
        let darkSkyConfig = Configuration(token: "99c234c1ba74ab4b1d68041b623e3089", units: .us, exclude: .alerts, lang: "EN")
        let forecastClient = DarkSkyKit(configuration: darkSkyConfig)
        
        getWeatherAsync(forecastClient: forecastClient)
        
    }
    
    func getWeatherAsync(forecastClient: DarkSkyKit) {
        
        //forecastClient.timeMachine(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude, date: self.weatherDate) { result in
        forecastClient.current(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude) { result in
            
            switch result {
                
            case .success(let forecast):
                // Manage weather data using the Forecast model. Ex:
                if let todaysWeather = forecast.daily?.first {
                    
                    self.precipitationType = todaysWeather.precipType ?? ""
                    print("FROM async func " + self.precipitationType)
                    self.temperatureHigh = todaysWeather.temperatureMax ?? 0.0
                    self.temperatureLow = todaysWeather.temperatureMin ?? 0.0
                    self.dewPoint = todaysWeather.dewPoint ?? 0.0
                    self.windSpeed = todaysWeather.windSpeed ?? 0.0
                    self.windBearing = todaysWeather.windBearing ?? 0.0
                    
                    print("High temp: " + String(self.temperatureHigh ))
                    print("Low temp: " + String(self.temperatureLow ))
                    print("Precip type: " + (self.precipitationType ))
                    
                    // Calculate the rainfall
                    if let hourlyWeather = forecast.hourly {
                        // Sum precipitation intensity from midnight to 5PM
                        var rainFallSum = 0.0;
                        for index in 0...17 {
                            rainFallSum += hourlyWeather[index].precipIntensity ?? 0.0
                        }
                        self.rainFall = rainFallSum
                        print("Rainfall (inches): " + String(self.rainFall ))
                    }
                }
                
            case .failure(let error):
                // Manage error case
                print("Unable to fetch weather data: \(error)")
            }
        }
    }
    
}
