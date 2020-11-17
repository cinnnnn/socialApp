//
//  NotificationService.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UserNotifications
import UIKit
import FirebaseMessaging

class PushNotificationService: NSObject {
    
    static let shared = PushNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        addActionCategory()
    }
    
    //MARK: requestNotificationAuth
    func requestNotificationAuth() {
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound,.announcement]) { [weak self] isGranted, error in
            
            if isGranted {
                self?.getNotificationSettings()
            }
        }
    }
    
    //MARK: getNotificationSettings
    private func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //MARK: scheduleNotification
    func scheduleNotification(title:String, body: String, image: UIImage? ) {
        let id = "Local notification"
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = MActionType.systemMessage.rawValue
        
        if let image = image {
            if let attachment = UNNotificationAttachment.create(identifier: "photo", image: image, options: nil) {
                content.attachments = [attachment]
            }
        }

        let request = UNNotificationRequest(identifier: id, content: content, trigger: triger)
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }  
    }
    
    
    //MARK: addActionCategory
    private func addActionCategory() {
        let categoryName = MActionType.message.rawValue
        let readAction = UNNotificationAction(identifier: "readAction",
                                                title: "Перейти к диалогу",
                                                options: [.authenticationRequired])

        let cancelAction = UNNotificationAction(identifier: "cancel",
                                                title: "Отмена",
                                                options: [.destructive])
        
        let category = UNNotificationCategory(identifier: categoryName,
                                              actions: [readAction,cancelAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    
    //when app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       
        
        completionHandler([.sound])
    }
    
    //when receive
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
//        if response.notification.request.identifier == "Local notification" {
//
//        }
      
        if let userName = userInfo["user"] as? String {
            
                print("\n USER is \(userName) \n")
            
        }
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("default action")
        case "snooze":
            print("snooze action")
        case "view":
            print("view action")
        case "cancel":
            print("cancel action")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
}
