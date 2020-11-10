//
//  NotificationService.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UserNotifications
import UIKit

class PushNotificationService: NSObject {
    
    static let shared = PushNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        addActionCategory()
    }
    
    func requestNotificationAuth() {
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound,.announcement]) { [weak self] isGranted, error in
            
            if isGranted {
                self?.getNotificationSettings()
            }
        }
    }
    
    private func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleNotification(title:String, body: String, image: UIImage? ) {
    
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = "mainAction"
        
        if let image = image {
            if let attachment = UNNotificationAttachment.create(identifier: "photo", image: image, options: nil) {
                content.attachments = [attachment]
            }
        }
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let id = "Local notification"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: triger)
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }  
    }
    
    private func addActionCategory() {
        let actionCategory = "mainAction"
        let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Отложить", options: [])
        let okAction = UNNotificationAction(identifier: "view", title: "Посмотреть", options: [.authenticationRequired])
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Закрыть", options: [.destructive])
        
        let category = UNNotificationCategory(identifier: actionCategory,
                                              actions: [snoozeAction,okAction,cancelAction],
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
        
        if response.notification.request.identifier == "Local notification" {
            print("handle notification")
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
