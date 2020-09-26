//
//  ChatsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 25.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import MessageKit

class ChatsViewController: MessagesViewController  {
    
    private let user:MPeople
    private let chat:MChat
    private var messages:[MMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInputBar()
    }
    
    init(user:MPeople, chat:MChat) {
        self.user = user
        self.chat = chat
        
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUserName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureInputBar() {
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.middleContentView?.backgroundColor = .systemBackground
        
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "sendMessage")
       // messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "sendMessage"), for: .normal)
      //  messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "sendMessageDisable"), for: .disabled)
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.setSize(CGSize(width: 36 , height: 36), animated: false)
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.imageView?.sizeToFit()
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.placeholder = "Начни общение..."
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.borderColor = UIColor.myHeaderColor().cgColor
        messageInputBar.middleContentViewPadding.right = -38
        messageInputBar.middleContentViewPadding.top = 20
    }
}

extension ChatsViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
}
