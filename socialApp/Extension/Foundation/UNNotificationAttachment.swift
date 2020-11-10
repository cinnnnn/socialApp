//
//  UNNotificationAttachment.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//
import UserNotifications
import UIKit

extension UNNotificationAttachment {

    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            let imageData = UIImage.pngData(image)
            try imageData()?.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func create2(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
       
        let fileName = ProcessInfo.processInfo.globallyUniqueString + identifier + ".png"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            let imageData = UIImage.pngData(image)
            try imageData()?.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: identifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func dowloadFromURL(url: URL, complition: @escaping(UNNotificationAttachment?)-> Void) {
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
