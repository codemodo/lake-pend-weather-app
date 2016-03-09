//
//  ArrayExtension.swift
//  WeatherDataLoader
//
//  Created by Alex Fiuk on 1/23/16.
//  Copyright © 2016 Kodemodo. All rights reserved.
//

import Foundation

extension Array {
    
    func calculateMean() -> Double {
        
        // is this array an array of doubles?
        if self.first is Double {
            
            // cast from generic to double array.
            // $0 represents each entry
            let doubleArray = self.map { $0 as! Double}
            
            // reduce collapses the array with 0.0 as the starting
            // value and using the combine operation
            let total = doubleArray.reduce(0.0, combine: {$0 + $1})
            
            let meanAvg = total / Double(self.count)
            return meanAvg
        
        } else {
            return Double.NaN
        }
    }
    
    func calculateMedian() -> Double {
        if self.first is Double {
            
            var doubleArray = self.map { $0 as! Double }
            
            doubleArray.sort( {$0 < $1} )
            
            var medianAvg : Double
            if doubleArray.count % 2 == 0 {
                var halfway = doubleArray.count / 2
                medianAvg = (doubleArray[halfway] + doubleArray[halfway - 1]) / 2
            } else {
                medianAvg = doubleArray[doubleArray.count / 2]
            }
            return medianAvg
        } else {
            return Double.NaN
        }
    }
}
