//
//  ViewController.swift
//  WeatherDataLoader
//
//  Created by Alex Fiuk on 1/23/16.
//  Copyright © 2016 Kodemodo. All rights reserved.
//

import Cocoa
import CloudKit

class ViewController: NSViewController {

    @IBAction func saveData(sender: AnyObject) {
        for year in 2012...2015 {
            let arrayOfDays = collapseToSingleDays("\(year)")
            saveDaysIntoCloudKit(arrayOfDays)
        }
    }
    
    func saveDaysIntoCloudKit(oneYear:[Day]) {
        
        // get our cloud kit container and public db (as opposed to the private dbs)
        let myContainer = CKContainer.defaultContainer() // reference to container
        let publicDatabase = myContainer.publicCloudDatabase // reference to public db
        
        // create array of records.  allows us to add as a batch
        var cloudRecords = [CKRecord]()
        
        // go through array of Day objects
        for singleDay in oneYear {
            
            // create a single CKRecord and give it a "type" (arbitrary; think "table name", but you're not creating a new table, just tagging the record)
            let weatherRecord = CKRecord(recordType: "weatherData")
            
            // fill the new record with key/value pairs
            weatherRecord.setObject(singleDay.date, forKey: "date")
            weatherRecord.setObject(singleDay.windspeedReadings.calculateMean(), forKey:"windspeedMean")
            weatherRecord.setObject(singleDay.windspeedReadings.calculateMedian(), forKey:"windspeedMedian")
            weatherRecord.setObject(singleDay.barometricPressureReadings.calculateMean(), forKey:"pressureMean")
            weatherRecord.setObject(singleDay.barometricPressureReadings.calculateMedian(), forKey:"pressureMedian")
            weatherRecord.setObject(singleDay.airTemperatureReadings.calculateMean(), forKey:"temperatureMean")
            weatherRecord.setObject(singleDay.airTemperatureReadings.calculateMedian(), forKey:"temperatureMedian")
            
            // save the CKRecord into the array of records
            cloudRecords.append(weatherRecord)
        }
        
        print("There are \(cloudRecords.count) records about to be saved...")
        
        // create an operation that will do the work of saving the records in a separate thread
        let operation = CKModifyRecordsOperation(recordsToSave: cloudRecords, recordIDsToDelete: nil)
        // we add this extra block of code to check for errors upon completion of operation
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("There was an error \(error!.description)!")
            } else {
                print("Saved \(savedRecords!.count) records into CloudKit")
            }
        }
        
        // this actually runs the operation
        publicDatabase.addOperation(operation)
    }
    
    func collapseToSingleDays(year : String) -> [Day] {
        
        // create array to hold 365 Day structs
        var daysArray = [Day]()
        
        // get file path to one text file
        let path = NSBundle.mainBundle().pathForResource(year, ofType: "txt")
        
        // read the text file into a string
        var fullText : String
        do {
            fullText = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            // break into an array of individual readings
            let readings = fullText.componentsSeparatedByString("\n") as [String]!
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy_MM_dd"

            for i in 1..<readings.count {
                let weatherData = readings[i].componentsSeparatedByString("\t")
                
                let dateTime = weatherData[0]
                let justDate = dateTime.substringToIndex(dateTime.startIndex.advancedBy(10))
                let dateOfCurrentReading = formatter.dateFromString(justDate)
                
                let temperatureValue = NSNumberFormatter().numberFromString(weatherData[1])!.doubleValue
                let pressureValue = NSNumberFormatter().numberFromString(weatherData[2])!.doubleValue
                let windValue = NSNumberFormatter().numberFromString(weatherData[7])!.doubleValue
                
                if daysArray.count == 0 || (daysArray[daysArray.count - 1].date != dateOfCurrentReading) {
                    let newDay = Day(initialDate: dateOfCurrentReading!)
                    daysArray.append(newDay)
                }
                
                daysArray[daysArray.count - 1].barometricPressureReadings.append(pressureValue)
                daysArray[daysArray.count - 1].windspeedReadings.append(windValue)
                daysArray[daysArray.count - 1].airTemperatureReadings.append(temperatureValue)
            }

        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return daysArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

