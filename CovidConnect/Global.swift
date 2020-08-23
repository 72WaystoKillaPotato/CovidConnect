//
//  Global.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/7/20.
//  Copyright © 2020 samsu. All rights reserved.
//
import UIKit
import Firebase

struct Global {
    
    //keeps track of the number of days the user used the app. first day = 0
    static var dayIndex : Int = -1
    
    static func isSameDay(completionHandler: @escaping (_ isSameDay:Bool) -> Void){
            if let uid = Auth.auth().currentUser?.uid{
                let ref = Database.database().reference().child("users").child(uid).child("lastLoggedIn")
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    guard snapshot.exists() else {return}
                    if let unixDate = snapshot.value as? Double{
                        let lastLoggedIn = NSDate(timeIntervalSince1970: unixDate) as Date
                        print("lastLoggedIn = ", lastLoggedIn)
                        let daysPassed = Date().interval(fromDate: lastLoggedIn)
                        if daysPassed == 0{
                            completionHandler(true)
                        } else if daysPassed > 0{
                            completionHandler(false)
                        }
                    }
                }
            }
        }
    
    static func totalDays(completionHandler: @escaping (_ noOfDays:Int) -> Void){
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference().child("users").child(uid).child("staticLoginDate")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {return}
                if let unixDate = snapshot.value as? Double{
                    let staticLoginDate = NSDate(timeIntervalSince1970: unixDate) as Date
                    print("staticLoginDate = ", staticLoginDate)
                    let noOfDays = Date().interval(fromDate: staticLoginDate)
                    print("total no of days the user has used the app = ", noOfDays)
                    completionHandler(noOfDays)
                }
            }
        }
    }
    
    static func updateDate(){
        if let uid = Auth.auth().currentUser?.uid{
            let loginTime = NSNumber(value: Int(Date().timeIntervalSince1970))
            Database.database().reference().child("users").child(uid).updateChildValues(["lastLoggedIn": loginTime as Any])
        }
    }
    
    static func cleanIndexedNode(){
        //get all topics contained
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference().child("contacts").child(uid).child("\(dayIndex)")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {
                    print("snapshot doesn't exist in cleanIndexedNode")
                    return}
                print("point 1")
                if let topicArray = snapshot.value as? [String: String]{
                    for (topic, _) in topicArray{
                        //unsubscribe from all topics contained in date and
                        Messaging.messaging().unsubscribe(fromTopic: topic) {(error) in
                            if error != nil{
                                print("error unsubscribing from topic", error!)
                            } else {
                                print("unsubscribed from \(topic)")
                                //clear the node
                                ref.removeValue() {(error, database) in
                                    if error != nil{
                                        print("error removing value: ", error!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //UI design constants
    static let cornerR : CGFloat = 20
    static let purple : CGColor = CGColor(srgbRed: 105/255.0, green: 112/255.0, blue: 135/255.0, alpha: 1.0)
    static let red = UIColor(red: 229.0/255.0, green: 115.0/255.0, blue: 115.0/255.0, alpha: 1)
    static let green = UIColor(red: 147.0/255.0, green: 233.0/255.0, blue: 190.0/255.0, alpha: 1)
}
