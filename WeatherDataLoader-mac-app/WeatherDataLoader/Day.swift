//
//  Day.swift
//  WeatherDataLoader
//
//  Created by Alex Fiuk on 1/23/16.
//  Copyright © 2016 Kodemodo. All rights reserved.
//

import Foundation

struct Day {
    
    var date : NSDate
    
    // arrays to hold all readings for one day
    var windspeedReadings = [Double]()
    var barometricPressureReadings = [Double]()
    var airTemperatureReadings = [Double]()
    
    init(initialDate: NSDate) {
        self.date = initialDate
    }
}
