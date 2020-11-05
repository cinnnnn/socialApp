//
//  SetupChatMenu.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class SetupChatMenu: UniversalTableView {
    
    let currentUser: MPeople
    var chat: MChat
    weak var messageControllerDelegate: MessageControllerDelegate?
    
    init(currentUser:MPeople, chat: MChat) {
        self.currentUser = currentUser
        self.chat = chat
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navigationItem.title = chat.friendUserName
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: tableViewDelegate
extension SetupChatMenu {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MChatSettings.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 140
        } else {
            return 70
        }
    }
    
    //MARK: cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menu = MChatSettings(rawValue: indexPath.row)  else { fatalError("Unknown menu index")}
        switch menu {
        
        case .disableTimer:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UniversallSwitchCell.reuseID, for: indexPath) as? UniversallSwitchCell {
                let strongChat = chat
                cell.configure(with: MChatSettings.disableTimer,
                               withImage: false,
                               switchIsOn: chat.currentUserIsWantStopTimer) { [weak self] in
                    let timeToDelete = self?.calculateTextToDeleteChat()
                    if let timeToDelete = timeToDelete {
                        cell.moreInfoLabel.text = timeToDelete
                    }
                    if strongChat.currentUserIsWantStopTimer {
                        cell.switchControl.isEnabled = false
                    }
                }
                cell.setupTimerUpdate(timerInterval: 1, tolerance: 0.1) { [weak self] in
                    let timeToDelete = self?.calculateTextToDeleteChat()
                    if let timeToDelete = timeToDelete {
                        cell.moreInfoLabel.text = timeToDelete
                    }
                }
                cell.setupSwitchAction(target: self, selector: #selector(changeDethTimerSwitch(sender:)),forEvent: .valueChanged)
                return cell
            } else {
                return UITableViewCell()
            }
        case .unmatch:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UniversalButtonCell.reuseID, for: indexPath) as? UniversalButtonCell {
                cell.configure(with: MChatSettings.unmatch, withImage: false)
                return cell
            } else {
                return UITableViewCell()
            }
        case .reportUser:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UniversalButtonCell.reuseID, for: indexPath) as? UniversalButtonCell {
                cell.configure(with: MChatSettings.reportUser, withImage: false)
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    //MARK: didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = MChatSettings(rawValue: indexPath.row)  else { fatalError("Unknown menu index")}
        
        switch menu {
        
        case .disableTimer:
            tableView.deselectRow(at: indexPath, animated: false)
            
        case .unmatch:
            FirestoreService.shared.unMatch(currentUser: currentUser, chat: chat) {[weak self] result in
                switch result {
                
                case .success(_):
                    //setup current user is initiator of delete chat
                    if let messageController = self?.messageControllerDelegate {
                        messageController.isInitiateDeleteChat = true
                    }
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                    self?.navigationController?.popToRootViewController(animated: true)
                    
                case .failure(let error):
                    self?.errorAlert(text: error.localizedDescription)
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .reportUser:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
//MARK: objc
extension SetupChatMenu {
    
    
    //MARK: changeDethTimerSwitch
    @objc func changeDethTimerSwitch(sender: Any?) {
        print("change")
        guard let sender = sender as? UISwitch else { fatalError("Unknown sender") }
        FirestoreService.shared.deactivateChatTimer(currentUser: currentUser,
                                                    chat: chat) {[weak self] result in
            switch result {
            
            case .success():
                self?.chat.currentUserIsWantStopTimer = true
                sender.isEnabled = false
                
            case .failure(let error):
                self?.errorAlert(text: error.localizedDescription)
            }
        }
    }
}

//MARK: alert
extension SetupChatMenu {
    private func errorAlert(text: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      text: text,
                                      buttonText: "Понял",
                                      style: .alert)
        alert.setMyLightStyle()
        present(alert, animated: true, completion: nil)
    }
}

extension SetupChatMenu {
    //MARK: calculateTextToDeleteChat
    private func calculateTextToDeleteChat() -> String {
        let periodMinutesOfLifeChat = MChat.getDefaultPeriodMinutesOfLifeChat()
        let timeToDeleteChat = chat.createChatDate.getPeriodToDate(periodMinuteCount: periodMinutesOfLifeChat)

        if chat.friendIsWantStopTimer {
           let fistLine = "Собеседник отключил таймер удаления чата,"
            if chat.currentUserIsWantStopTimer {
                return "Таймер чата отключен"
            } else {
                return  """
                        \(fistLine)
                        Для остановки необходимо твое подтверждение,
                        Чат будет удален через \(timeToDeleteChat)
                        """
            }
        } else {
            let fistLine = "Собеседник не отключил таймер удаления чата,"
            if chat.currentUserIsWantStopTimer {
                return  """
                        \(fistLine)
                        Для остановки необходимо дождаться подтверждение от собеседника,
                        Чат будет удален через \(timeToDeleteChat)
                        """
            } else {
                return  """
                        Собеседник и ты не отключили таймер удаления чата,
                        Чат будет удален через \(timeToDeleteChat)
                        """
            }
        }
    }
}
