//
//  MessagingService.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseMessaging

class PushMessagingService: NSObject {
    static let shared = PushMessagingService()
    let notificationName = "FirebaseMessageToken"
    
    private let serverKey = "AAAArMXNdi0:APA91bFPWVxZHcPH84GYK6VY9T2aFjzWJpxJI48tLSnDmXDiWSduU7Ih6vW8MeFiuqMwSkHdfUDJIunBBslcINM3N1s2ekIrSj0V-SZxZ9h7NnyLFrnp48LLqDSAEi8CgjY809UGwu1i"
    
    private let sendUrlString = "https://fcm.googleapis.com/fcm/send"
    private let infoUrlString = "https://iid.googleapis.com/iid/info/"
    
    //MARK: sendMessage
    private func sendMessage(token: String?,
                             topic: String?,
                             title: String,
                             body: String,
                             category: String,
                             bageCount: Int,
                             sound: String,
                             isMutableContent: String,
                             data: [String:String]?) {
        guard let url = URL(string: sendUrlString) else { fatalError("can't cast to url")}
        
        var to = ""
        //if set token = send to token
        if let token = token {
            to = token
            //else send to topic
        } else if let topic = topic {
            to = "/topics/\(topic)"
        }
        
        let param = MPushMessage(to: to,
                                 notification: MAps(title: title,
                                                    body: body,
                                                    category: category,
                                                    badge: bageCount,
                                                    sound: sound,
                                                    mutableContent: isMutableContent),
                                 data: data)
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(param)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                   // print("Data received \(jsonData)")
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    private func subscribeToTopic(topic: String) {
        Messaging.messaging().subscribe(toTopic: topic)
    }
    
    private func unSubscribeToTopic(topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic)
    }
    
    //MARK: registerDelegate
    func registerDelegate() {
        Messaging.messaging().delegate = self
    }
    
    
    //MARK: getToken
    func getToken() -> String? {
        var gettedToken:String?
        Messaging.messaging().token { token, error in
            if let error = error {
                fatalError(error.localizedDescription)
            } else if let token = token {
                print("FCM registration token: \(token)")
                gettedToken = token
            }
        }
        return gettedToken
    }
    
}
//MARK: -  subscribe / unsubscribe

extension PushMessagingService {
    
    func subscribeMainTopic(userID: String) {
        let myIDTopic = userID.replacingOccurrences(of: "@", with: "_")
        subscribeToTopic(topic: MTopics.allDevice.rawValue)
        subscribeToTopic(topic: MTopics.news.rawValue)
        subscribeToTopic(topic: myIDTopic)
    }
    
    func unSubscribeMainTopic(userID: String) {
        let myIDTopic = userID.replacingOccurrences(of: "@", with: "_")
        unSubscribeToTopic(topic: MTopics.allDevice.rawValue)
        unSubscribeToTopic(topic: MTopics.news.rawValue)
        unSubscribeToTopic(topic: myIDTopic)
    }
    
    func logInSubscribe(currentUserID: String, acceptChats: [MChat]) {
        let myIDTopic = currentUserID.replacingOccurrences(of: "@", with: "_")
        subscribeToTopic(topic: myIDTopic)
        //subscribe all chats
        acceptChats.forEach { chat in
            subscribeToChatNotification(currentUserID: currentUserID,
                                        chatUserID: chat.friendId)
        }
    }
    
    func logOutUnsabscribe(currentUserID: String, acceptChats: [MChat]) {
        //unsubscribe current user topic
        let myIDTopic = currentUserID.replacingOccurrences(of: "@", with: "_")
        unSubscribeToTopic(topic: myIDTopic)
        //unsubscribe all chats
        acceptChats.forEach { chat in
            unSubscribeToChatNotification(currentUserID: currentUserID,
                                          chatUserID: chat.friendId)
        }
    }
    
    func subscribeToChatNotification(currentUserID: String, chatUserID: String){
        let topic = [currentUserID, chatUserID].joined(separator: "_")
        let correctTopic = topic.replacingOccurrences(of: "@", with: "_")
        
        subscribeToTopic(topic: correctTopic)
    }
    
    func unSubscribeToChatNotification(currentUserID: String, chatUserID: String){
        let topic = [currentUserID, chatUserID].joined(separator: "_")
        let correctTopic = topic.replacingOccurrences(of: "@", with: "_")
        
        unSubscribeToTopic(topic: correctTopic)
    }
}

//MARK: - send message
extension PushMessagingService {
    
    func sendPushMessageToUser(userID: String, header: String, text: String, category: MActionType) {
        let topic = userID.replacingOccurrences(of: "@", with: "_")
        
        sendMessage(token: nil,
                    topic: topic,
                    title: header,
                    body: text,
                    category: category.rawValue,
                    bageCount: 1,
                    sound: "default",
                    isMutableContent: "true",
                    data: nil)
    }
    
    func sendMessageToUser(currentUser: MPeople, toUserID: MChat, header: String, text: String) {
        let topic = [toUserID.friendId, currentUser.senderId].joined(separator: "_")
        let correctTopic = topic.replacingOccurrences(of: "@", with: "_")
        
        sendMessage(token: nil,
                    topic: correctTopic,
                    title: header,
                    body: text,
                    category: MActionType.message.rawValue,
                    bageCount: 1,
                    sound: "default",
                    isMutableContent: "true",
                    data: nil)
    }
}


//MARK: - MessagingDelegate
extension PushMessagingService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("\n FCM registration token: \(fcmToken) \n")
        let data = [PushMessagingService.shared.notificationName : fcmToken]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PushMessagingService.shared.notificationName),
                                        object: nil,
                                        userInfo: data)
    }
    
}
