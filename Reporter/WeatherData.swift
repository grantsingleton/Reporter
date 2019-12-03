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

class WeatherData {
    
    //MARK: Properties
    var coordinates: CLLocationCoordinate2D
    var summary: String = ""
    var icon: String = ""
    var precipitationIntensity: Double = 0.0
    var precipitationType: String = ""
    var temperature: Double = 0.0
    var dewPoint: Double = 0.0
    var humidity: Double = 0.0
    var pressure: Double = 0.0
    var windSpeed: Double = 0.0
    var windBearing: Double = 0.0
    
    //MARK: Initialization
    
    init(coordinates: CLLocationCoordinate2D) {
        
        self.coordinates = coordinates
        
        let darkSkyConfig = Configuration(token: "99c234c1ba74ab4b1d68041b623e3089", units: .us, exclude: .alerts, lang: "EN")
        let forecastClient = DarkSkyKit(configuration: darkSkyConfig)
        
        forecastClient.current(latitude: coordinates.latitude, longitude: coordinates.longitude) { result in
          switch result {
            case .success(let forecast):
              // Manage weather data using the Forecast model. Ex:
              if let currentWeather = forecast.currently {
                self.summary = currentWeather.summary ?? ""
                self.icon = currentWeather.icon ?? ""
                self.precipitationIntensity = currentWeather.precipIntensity ?? 0.0
                self.precipitationType = currentWeather.precipType ?? ""
                self.temperature = currentWeather.temperature ?? 0.0
                self.dewPoint = currentWeather.dewPoint ?? 0.0
                self.humidity = currentWeather.humidity ?? 0.0
                self.pressure = currentWeather.pressure ?? 0.0
                self.windSpeed = currentWeather.windSpeed ?? 0.0
                self.windBearing = currentWeather.windBearing ?? 0.0
              }
          case .failure(let error):
              // Manage error case
            print("Unable to fetch weather data: \(error)")
          }
        }
    }
}
