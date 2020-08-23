//
//  NotificationWhenOpenDelegate.swift
//  CovidConnect
//
//  Created by Samantha Su on 4/12/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import Firebase

class NotificationWhenOpenDelegate: NSObject , UNUserNotificationCenterDelegate {
    
    var navigationC: UINavigationController?
    var window: UIWindow?
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let aps = response.notification.request.content.userInfo["aps"]
//        print("userInfo = ", aps["alert"])
        if let uid = Auth.auth().currentUser?.uid{
            var number = 0
            let userRef = Database.database().reference().child("users").child(uid).child("noDiagnosedContacts")
            userRef.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {return}
                if var number2 = snapshot.value as? Int{
                    number2 += 1
                    number = number2
                }
                userRef.setValue(number)
            }
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Open Action")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("default")
        }
        completionHandler()
    }
}
