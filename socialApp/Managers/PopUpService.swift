//
//  PopUpService.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SDWebImage

class PopUpService {
    static let shared = PopUpService()
    
    weak var acceptChatsDelegate: AcceptChatListenerDelegate?
    weak var requestChatsDelegate: RequestChatListenerDelegate?
    weak var peopleDelegate: PeopleListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    weak var messageDelegate: MessageListenerDelegate?
    
    private init() {}
}

extension PopUpService {
    func showMatchPopUP(currentPeople: MPeople, chat: MChat) {
        let matchPopUpView = MatchViewPopUp(currentPeople: currentPeople,
                                            chat: chat,
                                            messageDelegate: messageDelegate,
                                            acceptDelegate: acceptChatsDelegate)
        
        var attributesMatchView = EKAttributes()
        attributesMatchView.displayDuration = .infinity
        attributesMatchView.entryInteraction = .absorbTouches
        attributesMatchView.screenInteraction = .absorbTouches
        attributesMatchView.screenBackground = .visualEffect(style: .standard)
        attributesMatchView.position = .bottom
        attributesMatchView.hapticFeedbackType = .warning
        attributesMatchView.positionConstraints.safeArea = .overridden
        SwiftEntryKit.display(entry: matchPopUpView, using: attributesMatchView)
    }
    
    func showInfoPopUp(header: String,
                       text: String,
                       cancelButtonText: String,
                       okButtonText: String,
                       font: UIFont,
                       okButtonAction: @escaping () -> ()) {
        let simpleMessage = EKSimpleMessage(image: nil,
                                            title: .init(text: header,
                                                         style: .init(font: font,
                                                                      color: EKColor(light: .myWhiteColor(), dark: .myWhiteColor()),
                                                                      alignment: .center,
                                                                      displayMode: .inferred,
                                                                      numberOfLines: 1)),
                                            description: .init(text: text,
                                                               style: .init(font: .avenirRegular(size: 14),
                                                                            color: EKColor(light: .myWhiteColor(), dark: .myWhiteColor()),
                                                                            alignment: .center,
                                                                            displayMode: .inferred,
                                                                            numberOfLines: 0)))
        let okButtonContent = EKProperty.ButtonContent.init(label: .init(text: okButtonText,
                                                                         style: .init(font: font,
                                                                                      color: .init(.myWhiteColor()))),
                                                            backgroundColor: EKColor.init(.myLabelColor()),
                                                            highlightedBackgroundColor: EKColor.init(.myGrayColor())) {
            SwiftEntryKit.dismiss()
            okButtonAction()
        }
        
        let cancelButtonContent = EKProperty.ButtonContent.init(label: .init(text: cancelButtonText,
                                                                             style: .init(font: font,
                                                                                          color: .init(.myWhiteColor()))),
                                                                backgroundColor: EKColor.init(.myLabelColor()),
                                                                highlightedBackgroundColor: EKColor.init(.myGrayColor())) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonBarContent = EKProperty.ButtonBarContent(with: [cancelButtonContent,okButtonContent], separatorColor: .clear, expandAnimatedly: true)
        let message = EKAlertMessage(simpleMessage: simpleMessage,
                                     buttonBarContent: buttonBarContent)
        let infoView = EKAlertMessageView(with: message)
        
        var infoPopUpAttributes = EKAttributes()
        infoPopUpAttributes.displayDuration = 5
        infoPopUpAttributes.position = .top
        infoPopUpAttributes.hapticFeedbackType = .warning
        infoPopUpAttributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        infoPopUpAttributes.entryInteraction = .absorbTouches
        infoPopUpAttributes.entryBackground = .color(color: EKColor.init(.myLabelColor()))
        SwiftEntryKit.display(entry: infoView, using: infoPopUpAttributes)
    }
    
    func showMessagePopUp(header: String, text: String, time: String, imageStringURL: String){
        
        var attributes = EKAttributes()
        attributes = .topToast
        attributes.hapticFeedbackType = .success
        attributes.displayMode = .inferred
        attributes.statusBar = .inferred
        attributes.entryBackground = .color(color: EKColor.init(.myLabelColor()))
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.displayDuration = 4
        attributes.shadow = .active(
            with: .init(
                color: .init(.myLabelColor()),
                opacity: 0.5,
                radius: 10
            )
        )
        
        let title = EKProperty.LabelContent(
            text: header,
            style: .init(
                font: .avenirBold(size: 12),
                color: .init(.myWhiteColor()),
                displayMode: .inferred
            )
        )
        let description = EKProperty.LabelContent(
            text: text,
            style: .init(
                font: .avenirRegular(size: 12),
                color: .init(.myWhiteColor()),
                displayMode: .inferred
            )
        )
        let time = EKProperty.LabelContent(
            text: time,
            style: .init(
                font: .avenirRegular(size: 12),
                color: .init(.myWhiteColor()),
                displayMode: .inferred
            )
        )
        
        let imageURL = URL(string: imageStringURL)
        
        
        //load image and then show popUp
        SDWebImageManager.shared.loadImage(with: imageURL,
                                           options: .highPriority,
                                           progress: nil) { (getedImage, data, error, cache, complite, url) in
            var photoImage = UIImage()
            if let getedImage = getedImage {
                photoImage = getedImage
            }
            
            let image = EKProperty.ImageContent.thumb(
                with: photoImage,
                edgeSize: 34
            )
            
            let simpleMessage = EKSimpleMessage(
                image: image,
                title: title,
                description: description
            )
            let notificationMessage = EKNotificationMessage(
                simpleMessage: simpleMessage,
                auxiliary: time
            )
            let contentView = EKNotificationMessageView(with: notificationMessage)
            
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
        
        
        
        
        
    }
}
