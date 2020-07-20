//
//  LocalNotificationManager.swift
//  MyList
//
//  Created by Samuel Folledo on 7/17/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit.UNNotificationResponse_UIKitAdditions

struct LocalNotificationManager {
    
    static let center = UNUserNotificationCenter.current()
    
    ///asks permission to push local notication
    static func requestLocalNotification(completion: @escaping (_ error: String?, _ granted: Bool) -> Void) {
        checkPermision { (granted) in
            if granted {
                completion(nil, granted)
            } else { //if not permitted then ask for permission
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    guard error == nil else {
                        completion(error!.localizedDescription, granted)
                        return
                    }
                    completion(nil, granted)
                }
            }
        }
    }
    
    ///Add local notification after checking permissions
    static func schedule(title: String, message: String, userInfo: [AnyHashable: Any], identifier: String, dueDate: Date,
                              completion: @escaping (_ error: String?) -> Void) {
        checkPermision { (granted) in
            if granted {
                create(title: title, message: message, userInfo: userInfo, identifier: identifier, dueDate: dueDate)
                completion(nil)
            } else {
                requestLocalNotification { (error, granted) in
                    guard error == nil else {
                        completion(error!)
                        return
                    }
                    if granted {
                        create(title: title, message: message, userInfo: userInfo, identifier: identifier, dueDate: dueDate)
                        completion(nil)
                    } else {
                        completion("Notification is disabled. Please go to Settings and allow us to send you notifications.")
                    }
                }
            }
        }
    }
    
    //MARK: Private Helpers
    private static func checkPermision(completion: @escaping (_ granted: Bool) -> Void) {
        center.getNotificationSettings() { (settings) in
            switch settings.alertSetting {
            case .enabled:
                completion(true)
            case .disabled, .notSupported:
                completion(false)
            default:
                break
            }
        }
    }
    
    private static func create(title: String, message: String, userInfo: [AnyHashable: Any], identifier: String, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.categoryIdentifier = "alarm" //custom actions
        content.userInfo = userInfo //custom data to notification
        content.sound = UNNotificationSound.default
        //NOTE: Trigger by date
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate) //convert dueDate to calendar
        print("Alert for \(identifier) is created at \(dateComponents)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        //NOTE: Trigger by seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }
    
    static func removeNotification(identifier:String) {
        center.getPendingNotificationRequests { (requests) in
            for request in requests {
                if request.identifier == identifier {
                    print("Deleting... ", request.content.title)
                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                }
            }
        }
    }
}
