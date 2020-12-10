//
//  NotificationService.swift
//  MyNotificationService
//
//  Created by Денис Щиголев on 10.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
  
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let badgeCount = bestAttemptContent.badge as? Int {
              switch badgeCount {
              case 0:
                UserDefaults.extensions.badge = 0
                bestAttemptContent.badge = 0
              default:
                let current = UserDefaults.extensions.badge
                let new = current + badgeCount

                UserDefaults.extensions.badge = new
                bestAttemptContent.badge = NSNumber(value: new)
              }
            }
            contentHandler(bestAttemptContent)
        }
//        guard let bestAttemptContent = bestAttemptContent,
//              let apsData = bestAttemptContent.userInfo["aps"] as? [String:Any],
//              let attachmentURLString = apsData["attachment-url"] as? String,
//              let attachmetURL = URL(string: attachmentURLString) else { return }
//
//        dowloadFromURL(url: attachmetURL) { attachment in
//            if let attachment = attachment {
//                bestAttemptContent.attachments = [attachment]
//                bestAttemptContent.body = "Ловите фоточку Дениса"
//                contentHandler(bestAttemptContent)
//            }
//        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension NotificationService {
    private func dowloadFromURL(url: URL, complition: @escaping(UNNotificationAttachment?)-> Void) {
        let task = URLSession.shared.downloadTask(with: url) { url, response, error in
            guard let url = url else {
                complition(nil)
                return
            }
            let fileName = ProcessInfo.processInfo.globallyUniqueString + ".png"
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            try? FileManager.default.moveItem(at: url, to: fileURL)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "favicon", url: fileURL, options: nil)
                complition(attachment)
            } catch {
                complition(nil)
            }
        }
        task.resume()
    }
}
