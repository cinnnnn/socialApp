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
    
    var messageId: String
    var sentDate: Date
    
    //media message
    var imageURL: URL? = nil
    var image: UIImage? = nil
    
    //text message
    var content: String? = nil
    
    //for MessageKit
    var sender: SenderType
    var kind: MessageKind {
        if let image = image {
            let mediaItem = MMediaItem(url: imageURL,
                                       image: nil,
                                       placeholderImage: image,
                                       size: CGSize(width: 400, height: 400))
            return .photo(mediaItem)
        } else {
            return .text(content ?? "")
        }
    }
    
    init(user: MSender, content: String, id: String? = nil) {
        self.content = content
        messageId = id ?? UUID().uuidString
        sentDate = Date()
        sender = user
    }
    
    init(user: MPeople, image: UIImage) {
        messageId = UUID().uuidString
        sentDate = Date()
        sender = user
        self.image = image
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
       
        guard let messageId = documet["messageId"] as? String else { return nil }
        guard let sentDate = documet["sentDate"] as? Timestamp else { return nil }
        guard let displayName = documet["displayName"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        if let content = documet["content"] as? String {
            self.content = content
        } else if let stringURL = documet["URL"] as? String, let url = URL(string: stringURL) {
            self.imageURL = url
        } else { return nil }
        
        self.sentDate = sentDate.dateValue()
        self.messageId = messageId
        
        self.sender = MSender(senderId: senderId, displayName: displayName)
        
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
         let documet = documentSnap.data()  
        
        guard let messageId = documet["messageId"] as? String else { return nil }
        guard let sentDate = documet["sentDate"] as? Timestamp else { return nil }
        guard let displayName = documet["displayName"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        if let content = documet["content"] as? String {
            self.content = content
        } else if let stringURL = documet["URL"] as? String, let url = URL(string: stringURL) {
            self.imageURL = url
        } else { return nil }
  
        self.sentDate = sentDate.dateValue()
        self.messageId = messageId
        
        self.sender = MSender(senderId: senderId, displayName: displayName)
      }
    
    var reprasentation: [String:Any] {
        var rep:[String: Any] = [
            "displayName": sender.displayName,
            "senderId": sender.senderId,
            "messageId": messageId,
            "sentDate": sentDate
        ]
        
        if let url = imageURL {
            rep["URL"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case imageURL = "URL"
        case image
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
