//
//  ViewController.swift
//  PendWeather
//
//  Created by Alex Fiuk on 1/24/16.
//  Copyright © 2016 Kodemodo. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var periodSegment: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let calendar = NSCalendar.currentCalendar()
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        let earliestDate = calendar.dateWithEra(1, year: 2011, month: 01, day: 01, hour: 0, minute: 0, second: 0, nanosecond: 0)
        datePicker.minimumDate = earliestDate
        //print(datePicker.minimumDate)
        
        let yesterday = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: NSDate(), options: NSCalendarOptions())
        datePicker.maximumDate = yesterday
        
        // This will be our default date
        let thisDayLastYear = calendar.dateByAddingUnit(NSCalendarUnit.Year, value: -1, toDate: NSDate(), options: NSCalendarOptions())
        datePicker.date = thisDayLastYear!
        
        datePicker.addTarget(self, action: "fetchData:", forControlEvents: UIControlEvents.ValueChanged)
        periodSegment.addTarget(self, action: "fetchData:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    // ** look into why the argument is as is
    func fetchData(control: UIControl) {
        // point to our specific CloudKit container
        let container = CKContainer(identifier: "iCloud.com.kodemodo.WeatherDataLoader")
        let publicDB = container.publicCloudDatabase
        
        // get start date from date picker, removing time
        let startDate = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: datePicker.date, options: NSCalendarOptions())
        //print("Start date: \(startDate)")
        
        // get our end date based on start date and period segment selected
        var endDate = startDate
        switch periodSegment.selectedSegmentIndex {
        case 0:
            endDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: startDate!, options: NSCalendarOptions())
        case 1:
            endDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 7, toDate: startDate!, options: NSCalendarOptions())
        case 2:
            endDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: 1, toDate: startDate!, options: NSCalendarOptions())
        default:
            break
        }
        
        print("startDate: \(startDate),  endDate: \(endDate)")
        
        let myPredicate = NSPredicate(format:"date >= %@ AND date < %@", startDate!, endDate!)
        let myQuery = CKQuery(recordType: "weatherData", predicate: myPredicate)
        
        
        // All the work we've done to set up this query so far has been on the main thread.
        // This is okay.  But when we go to actually execute the query, it executes on some other thread.
        // We provide a completion block, which is just a set of code we want to execute on this other thread
        // once our query is finished.  This allows us to handle errors that occur during the query.
        publicDB.performQuery(myQuery, inZoneWithID: nil, completionHandler: {
            results, error in
            if error != nil {
                print(error?.userInfo)
            }
            if results!.count > 0 {
                // deal with the results
                
                // When first created, results were slow since we were calling parseResults in some other thread.
                // This made response time slow and unpredictable.
                // Basically, you should never change UI elements from anywhere other than the main thread
                // So we create an operation that places this back onto the main thread
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.parseResults(results!)
                })
            }
        })
    }
    
    func parseResults(results : [AnyObject]) {
        var windspeedMeans = [Double]()
        var temperatureMeans = [Double]()
        var pressureMeans = [Double]()
        var windspeedMedians = [Double]()
        var temperatureMedians = [Double]()
        var pressureMedians = [Double]()
        
        for eachResult in results {
            print ("gets here")
            windspeedMeans.append(eachResult["windspeedMean"] as! Double)
            temperatureMeans.append(eachResult["temperatureMean"] as! Double)
            pressureMeans.append(eachResult["pressureMean"] as! Double)
            windspeedMedians.append(eachResult["windspeedMedian"] as! Double)
            temperatureMedians.append(eachResult["temperatureMedian"] as! Double)
            pressureMedians.append(eachResult["pressureMedian"] as! Double)
        }
        
        let windMean = calculateAverage(windspeedMeans)
        let windMed = calculateAverage(windspeedMedians)
        let tempMean = calculateAverage(temperatureMeans)
        let tempMed = calculateAverage(temperatureMedians)
        let pressureMean = calculateAverage(pressureMeans)
        let pressureMed = calculateAverage(pressureMedians)
        
        tempLabel.text = "\(tempMean) / \(tempMed)"
        windLabel.text = "\(windMean) / \(windMed)"
        pressureLabel.text = "\(pressureMean) / \(pressureMed)"

    }
    
    // *** why is it good to have the argument be any object
    func calculateAverage(values : [Double]) -> Int {
        let total = values.reduce(0.0, combine: {$0 + $1})
        let avg = (total / Double(values.count))
        let roundedInt = Int(round(avg))
    
        return roundedInt
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

