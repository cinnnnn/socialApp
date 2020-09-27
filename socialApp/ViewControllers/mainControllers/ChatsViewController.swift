//
//  ChatsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 25.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatsViewController: MessagesViewController  {
    
    private let user:MPeople
    private let chat:MChat
    private var messages:[MMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        configureInputBar()
        configure()
        
    }
    
    init(user:MPeople, chat:MChat) {
        self.user = user
        self.chat = chat
        
        super.init(nibName: nil, bundle: nil)
        title = chat.friendUserName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMessageListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ListenerService.shared.removeMessageListener()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    private func configure() {
        //delete avatar from message
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func addMessageListener() {
        ListenerService.shared.messageListener(chat: chat) {[weak self] result in
            switch result {
            
            case .success(let message):
                self?.newMessage(message: message)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func newMessage(message: MMessage) {
        
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort { lhs, rhs -> Bool in
            lhs.sentDate < rhs.sentDate
        }
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        
    }
    
    private func configureInputBar() {
        messageInputBar.delegate = self
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.middleContentView?.backgroundColor = .systemBackground
        
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "sendMessage")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.setSize(CGSize(width: 36 , height: 36), animated: false)
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.imageView?.sizeToFit()
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 5)
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

extension ChatsViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 9)
    }
}

extension ChatsViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .myMessageColor() : .friendMessageColor()
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .systemBackground : .label
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        .bubble
    }
}

extension ChatsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MMessage(user: user, content: text)
        
        FirestoreService.shared.sendMessage(chat: chat,
                                            currentUser: user,
                                            message: message) { result in
            switch result {
            
            case .success():
                break
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
        
    }
}
