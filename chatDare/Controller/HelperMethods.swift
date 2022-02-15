//
//  HelperMethods.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/14/21.
//

import Foundation

import UIKit

extension ViewController {


func convertFireBaseTimeToHours(serverTimestamp: Double) -> String {
    
    let formatter = DateFormatter()


    let firebaseTimeStamp = serverTimestamp / 1000
    let date = NSDate(timeIntervalSince1970: firebaseTimeStamp)

// if time between date is more than 24 hours show the data of the message if less 24 hrs so the time


    formatter.dateStyle = .medium
    print(formatter.string(from: date as Date))

    return formatter.string(from: date as Date)
}

func convertFireBaseTime(serverTimestamp: Double) -> String {
        
    let formatter = DateFormatter()


    let firebaseTimeStamp = serverTimestamp / 1000
    let date = NSDate(timeIntervalSince1970: firebaseTimeStamp)


// if time between date is more than 24 hours show the data of the message if less 24 hrs so the time
    formatter.timeStyle = .short

    return formatter.string(from: date as Date)
}

func convertFireBaseToDate(serverTimestamp: Double) -> String {
        
    let formatter = DateFormatter()

    let firebaseTimeStamp = serverTimestamp / 1000
    let date = NSDate(timeIntervalSince1970: firebaseTimeStamp)


// if time between date is more than 24 hours show the data of the message if less 24 hrs so the time
    formatter.dateStyle = .long

    return formatter.string(from: date as Date)
}

}
