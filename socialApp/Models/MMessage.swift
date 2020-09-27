//
//  MRequestChat.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit

struct MMessage: Hashable, ReprasentationModel, MessageType{
    
    var content: String
    var messageId: String
    var sentDate: Date
    //for MessageKit
    var sender: SenderType
    var kind: MessageKind {
        .text(content)
    }
    
    init(user: MPeople, content: String, id: String? = nil) {
        self.content = content
        messageId = id ?? UUID().uuidString
        sentDate = Date()
        sender = user
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        
        guard let content = documet["content"] as? String else { return nil }
        guard let messageId = documet["messageId"] as? String else { return nil }
        guard let sentDate = documet["sentDate"] as? Timestamp else { return nil }
        guard let displayName = documet["displayName"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.content = content
        self.sentDate = sentDate.dateValue()
        self.messageId = messageId
        
        self.sender = MSender(senderId: senderId, displayName: displayName)
        
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
         let documet = documentSnap.data()  
        
        guard let content = documet["content"] as? String else { return nil }
        guard let messageId = documet["messageId"] as? String else { return nil }
        guard let sentDate = documet["sentDate"] as? Timestamp else { return nil }
        guard let displayName = documet["displayName"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.content = content
        self.sentDate = sentDate.dateValue()
        self.messageId = messageId
        
        self.sender = MSender(senderId: senderId, displayName: displayName)
      }
    
    var reprasentation: [String:Any] {
        let rep:[ String: Any ] = [
            "content": content,
            "displayName": sender.displayName,
            "senderId": sender.senderId,
            "messageId": messageId,
            "sentDate": sentDate
        ]
        return rep
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case messageId
        case sentDate
        case displayName
        case senderId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    

}
