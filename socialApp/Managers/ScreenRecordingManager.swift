//
//  ScreenRecordingManager.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ScreenRecordingManager {
    static let shared = ScreenRecordingManager()
    private init() {}
    private var isCaptured: ((Bool) -> Void)?
    private var window: UIWindow? {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    }
    
    func setupListner(isCaptured: ((Bool)-> Void)?) {
        self.isCaptured = isCaptured
        NotificationCenter.default.addObserver(self, selector: #selector(captureStart), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    func removeListner() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func captureStart() {
        let popUpName = "Screen recording"
        
        if UIScreen.main.isCaptured {
            //window?.isHidden = true
            if let isCaptured = isCaptured {
                isCaptured(true)
            }
            PopUpService.shared.showViewPopUp(view: ScreenRecordingView(),withAnimation: false, name: popUpName)
        } else {
           // window?.isHidden = false
            if let isCaptured = isCaptured {
                isCaptured(false)
            }
            PopUpService.shared.dismisPopUp(name: popUpName)
        }
    }
}
