//
//  ChatsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 25.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import MessageKit
import SDWebImage
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MessageControllerDelegate  {
    
    private let user:MPeople
    private var chat:MChat
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    weak var messageDelegate: MessageListenerDelegate?
    
    lazy var isInitiateDeleteChat = false
    
    init(people: MPeople, chat: MChat, messageDelegate: MessageListenerDelegate?, acceptChatDelegate: AcceptChatListenerDelegate?) {
        self.user = people
        self.chat = chat
        self.messageDelegate = messageDelegate
        self.acceptChatDelegate = acceptChatDelegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageDelegate?.removeListener()
        NotificationCenter.default.removeObserver(self)
        ScreenRecordingManager.shared.removeListner()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageDelegate?.messageControllerDelegate = self
        
        acceptChatDelegate?.messageCollectionViewDelegate = self
        
        configure()
        configureInputBar()
        configureCameraBar()
        
        addMessageListener()
        readAllMessageInChat()
        showTimerPopUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        acceptChatDelegate?.selectedChat = nil
        readAllMessageInChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: addMessageListener
    private func addMessageListener() {
        messageDelegate?.setupListener(chat: chat)
    }
    
     func chatsCollectionWasUpdate(chat: MChat) {
        if chat.friendId == self.chat.friendId {
            self.chat = chat
        }
    }
    
    private func readAllMessageInChat() {
        FirestoreService.shared.readAllMessageInChat(userID: user.senderId, chat: chat) { _ in
        }
    }
    
    //MARK: configure
    private func configure() {
        showMessageTimestampOnSwipeLeft = true
        acceptChatDelegate?.selectedChat = chat
        
        //delete avatar from message
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        navigationItem.titleView = ChatTitleStackView(chat: chat, target: self, profileTappedAction: #selector(profileTapped))
        navigationItem.backButtonTitle = ""
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                            style: .done,
                                            target: self,
                                            action: #selector(chatSettingsTapped))
        navigationItem.rightBarButtonItem = barButtonItem
        navigationController?.navigationBar.isHidden = false
        //add screenshot observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(screenshotTaken),
                                               name: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil)
        ScreenRecordingManager.shared.setupListner {[weak self] isCaptured in
            if isCaptured {
                self?.screenIsCaptured()
            }
        }
    }
    
    //MARK: configureInputBar
    private func configureInputBar() {
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .myWhiteColor()
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.middleContentView?.backgroundColor = .myWhiteColor()
        let sendImage = UIImage(systemName: "arrow.turn.right.up", withConfiguration: UIImage.SymbolConfiguration(font: .avenirRegular(size: 24), scale: UIImage.SymbolScale.default))
        messageInputBar.sendButton.setImage(sendImage, for: .normal)
        messageInputBar.sendButton.tintColor = .myLabelColor()
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.setSize(CGSize(width: 36 , height: 36), animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 5)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.rightStackView.axis = .horizontal
        messageInputBar.inputTextView.placeholder = "Сообщение..."
        messageInputBar.inputTextView.placeholderLabel.font = .avenirRegular(size: 16)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.backgroundColor = .myWhiteColor()
        messageInputBar.middleContentViewPadding.right = -38
        messageInputBar.middleContentViewPadding.top = 20
    }
    
    //MARK: configureCameraBar
    private func configureCameraBar() {
        let cameraItem = InputBarButtonItem()
        cameraItem.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(font: .avenirRegular(size: 24), scale: UIImage.SymbolScale.large))
        cameraItem.tintColor = .myLabelColor()
        cameraItem.setSize(CGSize(width: 36, height: 36), animated: false)
        cameraItem.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 5)
        cameraItem.addTarget(self, action: #selector(tuppedSendImage), for: .primaryActionTriggered)
        
        messageInputBar.leftStackView.axis = .horizontal
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    
    //MARK: newMessage
    func newMessage() {
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    //MARK: showTimerPopUp
    private func showTimerPopUp() {
        let strongUser = user
        let strongChat = chat
        var messageText = ""
        var okButtonText = ""
        let timeToDeleteChat = chat.createChatDate.getPeriodToDate(periodMinuteCount: MChat.getDefaultPeriodMinutesOfLifeChat())
        if strongUser.isGoldMember || strongUser.isTestUser {
            messageText = "У тебя Flava premium, можешь остановить таймер удаления без подтверждения собеседника"
            okButtonText = "Остановить таймер"
        } else {
            messageText = "Отправь запрос на остановку таймера, если собеседник подтвердит, чат не будет удален"
            okButtonText = "Отправить"
        }
        
        if !chat.currentUserIsWantStopTimer {
            PopUpService.shared.showInfoWithButtonPopUp(header: "Чат будет удален через \(timeToDeleteChat)",
                                              text: messageText,
                                              cancelButtonText: "Позже",
                                              okButtonText: okButtonText,
                                              font: .avenirBold(size: 14)) {
                FirestoreService.shared.deactivateChatTimer(currentUser: strongUser, chat: strongChat) { _  in }
            }
        } else if !chat.friendIsWantStopTimer {
            PopUpService.shared.showInfo(text: """
                                                Собеседник не отключил таймер,
                                                чат будет удален через \(timeToDeleteChat)
                                               """)
        }
    }
    
    //MARK: sendImage
    private func sendImage(image: UIImage) {
        StorageService.shared.uploadChatImage(image: image,
                                              currentUserID: user.senderId,
                                              chat: chat) {[weak self] result in
            switch result {
            
            case .success(let url):
                guard let sender = self?.user else { return }
                guard let chat = self?.chat else { return }
                var imageMessage = MMessage(user: sender, image: image)
                imageMessage.imageURL = url
                FirestoreService.shared.sendMessage(chat: chat,
                                                    currentUser: sender,
                                                    message: imageMessage) { result in
                    switch result {
                    
                    case .success():
                        return
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: objc
extension ChatViewController {
    
    //MARK: tuppedSendImage
    @objc private func tuppedSendImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        choosePhotoAlert {[ weak self ] sourceType in
            guard let sourceType = sourceType else { return }
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                picker.sourceType = sourceType
                self?.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: screenshotTaken
    @objc private func screenshotTaken(){
        
        let text = user.displayName + MLabels.screenshotTaken.rawValue
        
        FirestoreService.shared.sendAdminMessage(currentUser: user,
                                                 chat: chat,
                                                 text: text) {_ in}
    }
    
    //MARK: screenIsCaptured
    @objc private func screenIsCaptured(){
        
        let text = user.displayName + MLabels.isCapturedScreen.rawValue
        
        FirestoreService.shared.sendAdminMessage(currentUser: user,
                                                 chat: chat,
                                                 text: text) {_ in}
    }
    
    //MARK: profileTapped
    @objc private func profileTapped() {
        let profileVC = PeopleInfoViewController(peopleID: chat.friendId, withLikeButtons: false)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK: profileTapped
    @objc private func chatSettingsTapped() {
        
        let settingsVC = SetupChatMenu(currentUser: user, chat: chat)
        settingsVC.messageControllerDelegate = self
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

extension ChatViewController {
    //MARK: choosePhotoAlert
    private func choosePhotoAlert(complition: @escaping (_ sourceType:UIImagePickerController.SourceType?) -> Void) {
        
        let photoAlert = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Открыть камеру",
                                         style: .default) { _ in
            
            complition(UIImagePickerController.SourceType.camera)
        }
        let libraryAction = UIAlertAction(title: "Выбрать из галереи",
                                          style: .default) { _ in
            complition(UIImagePickerController.SourceType.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .default) { _ in
            complition(nil)
        }
        
        photoAlert.setMyStyle()
        photoAlert.addAction(cameraAction)
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cancelAction)
        
        present(photoAlert, animated: true, completion: nil)
    }
    
    //MARK: showDeleteChatAlert
    func showChatAlert(text: String) {
        let alert = UIAlertController(title: nil,
                                      message: text,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понятно",
                                     style: .default) {[weak self] _ in
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.setMyLightStyle()
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: pickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { fatalError("Cant get image")}
        sendImage(image: image)    
    }
}

extension ChatViewController: UINavigationControllerDelegate {
    
}

//MARK: MessagesDataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let messageDelegate = messageDelegate else { fatalError("Can' get messageDelegate") }
        return messageDelegate.messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageDelegate?.messages.count ?? 0
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let currentTime = MessageKitDateFormatter.shared.string(from: message.sentDate)
        let attributedDateString = NSAttributedString(string: currentTime,
                                                      attributes: [NSAttributedString.Key.font : UIFont.avenirRegular(size: 12),
                                                                   NSAttributedString.Key.foregroundColor : UIColor.myGrayColor()])
        
        if indexPath.section == 0 {
            return attributedDateString
        } else {
            guard let messageDelegate = messageDelegate else { return nil }
            //if from previus message more then 10 minets show time
            let timeDifference = messageDelegate.messages[indexPath.section - 1].sentDate.distance(to: message.sentDate) / 600
            
            if timeDifference > 1 {
                return attributedDateString
            }
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if message.sender.senderId == MAdmin.id.rawValue {
            return NSAttributedString(string: message.sender.displayName,
                                      attributes: [NSAttributedString.Key.font : UIFont.avenirRegular(size: 12),
                                                   NSAttributedString.Key.foregroundColor : UIColor.myGrayColor()])
        } else {
            return nil
        }
    }
}

//MARK: MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 9)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 30
        } else {
            guard let messageDelegate = messageDelegate else { return 0 }
            //if from previus message more then 10 minets set new height
            let timeDifference = messageDelegate.messages[indexPath.section - 1].sentDate.distance(to: message.sentDate) / 600
            if timeDifference > 1 {
                return 30
            }
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //if sender of message - Admin, set more Height to label in messageTop
        if message.sender.senderId == MAdmin.id.rawValue {
            return 20
        } else {
            return 0
        }
    }
}

//MARK: MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .myMessageColor()
        } else if message.sender.senderId == MAdmin.id.rawValue {
            return .adminMessageColor()
        } else {
            return .friendMessageColor()
        }
        
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .myWhiteColor() : .myLabelColor()
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        .bubbleTail(isFromCurrentSender(message: message) ? MessageStyle.TailCorner.bottomRight : MessageStyle.TailCorner.bottomLeft, MessageStyle.TailStyle.pointedEdge)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind {
        case .photo(let photoItem):
            if let url = photoItem.url {
                imageView.sd_setImage(with: url)
            }
        default:
            break
        }
    }
}

//
extension ChatViewController: MessageCellDelegate {
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

//MARK: InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let sender = MSender(senderId: user.senderId, displayName: user.displayName)
        let message = MMessage(user: sender, content: text)
        let strongChat = chat
        let strongUser = user
        FirestoreService.shared.sendMessage(chat: chat,
                                            currentUser: user,
                                            message: message) { result in
            switch result {
            
            case .success():
                //send notification to friend
                PushMessagingService.shared.sendMessageToUser(currentUser: strongUser,
                                                              toUserID: strongChat,
                                                              header: strongUser.displayName,
                                                              text: text)
            case .failure(_):
                //no document to update
                break
            }
        }
        inputBar.inputTextView.text = ""
    }
}


