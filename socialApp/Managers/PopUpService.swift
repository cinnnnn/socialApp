//
//  PopUpService.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftEntryKit

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
}
