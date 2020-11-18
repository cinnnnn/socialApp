//
//  EditSearchSettingsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class EditSearchSettingsViewController: UIViewController {
    
    var currentPeople: MPeople
    weak var peopleListnerDelegate: PeopleListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    weak var acceptChatsDelegate: AcceptChatListenerDelegate?
    
    let distanceLabel = UILabel(labelText: "Максимальное расстояние поиска:",
                                textFont: .avenirRegular(size: 16),
                                textColor: .myGrayColor())
    let ageRangeLabel = UILabel(labelText: "Возрастной диапозон:",
                                textFont: .avenirRegular(size: 16),
                                textColor: .myGrayColor())
    let distanceSlider = UISlider()
    let ageRangePicker = UIPickerView()
    let lookingForButton = OneLineButtonWithHeader(header: "Ищу", info: "")
    let currentLocationButton = OneLineButtonWithHeader(header: "Локация", info: "")
    
    
    init(currentPeople: MPeople,
         peopleListnerDelegate: PeopleListenerDelegate?,
         likeDislikeDelegate: LikeDislikeListenerDelegate?,
         acceptChatsDelegate: AcceptChatListenerDelegate?) {
        
        self.peopleListnerDelegate = peopleListnerDelegate
        self.likeDislikeDelegate = likeDislikeDelegate
        self.acceptChatsDelegate = acceptChatsDelegate
        self.currentPeople = currentPeople
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupData()
        setupConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveData()
    }
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        distanceSlider.maximumValue = Float(MSearchSettings.distance.defaultValue)
        distanceSlider.minimumValue = 5
        distanceSlider.thumbTintColor = .myLabelColor()
        distanceSlider.tintColor = .myLabelColor()
        
        ageRangePicker.delegate = self
        ageRangePicker.dataSource = self
        
        distanceSlider.addTarget(self, action: #selector(changeDistanceSlider), for: .valueChanged)
        lookingForButton.addTarget(self, action: #selector(lookingForTapped), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
    }
    
    //MARK: setupData
    private func setupData() {
        if let distance = currentPeople.searchSettings[MSearchSettings.distance.rawValue]{
            distanceSlider.value = Float(distance)
            
            if distance == Int(distanceSlider.maximumValue) {
                distanceLabel.text = "Максимальное расстояние: планета Земля"
            } else {
                distanceLabel.text = "Максимальное расстояние: \(distance) км"
            }
        }
        if let minRange = currentPeople.searchSettings[MSearchSettings.minRange.rawValue] {
            if let maxRange = currentPeople.searchSettings[MSearchSettings.maxRange.rawValue] {
                let componentForMin = minRange - MSearchSettings.minRange.defaultValue
                let componentForMax = maxRange - MSearchSettings.minRange.defaultValue - 1
                ageRangePicker.selectRow(componentForMin, inComponent: 0, animated: true)
                ageRangePicker.selectRow(componentForMax, inComponent: 1, animated: true)
            }
        }
        
        if let location = currentPeople.searchSettings[MSearchSettings.currentLocation.rawValue] {
            if let locationName = MVirtualLocation(rawValue: location) {
                currentLocationButton.infoLabel.text = locationName.description()
            }
    
            lookingForButton.infoLabel.text = currentPeople.lookingFor
        }
    }
    
    //MARK: saveData
    private func saveData() {
        let distance = Int(distanceSlider.value)
        guard let lookingFor = lookingForButton.infoLabel.text else { return }
        guard let newLocation = currentLocationButton.infoLabel.text else { return }
        let currentLocationIndex = MVirtualLocation.index(location: newLocation)
        guard let virtualLocation = MVirtualLocation(rawValue: currentLocationIndex) else { return }
        
        guard let strongLikeDislikeDelegate = likeDislikeDelegate else { fatalError("Can't get likeDislikeDelegate")}
        guard let strongAcceptChatsDelegate = acceptChatsDelegate else { fatalError("Can't get acceptChatsDelegate")}
        
        LocationService.shared.getCoordinate(userID: currentPeople.senderId,
                                             virtualLocation: virtualLocation) { [weak self] isAllowPermission in
           //if permission deniy, open settings
            if !isAllowPermission {
                self?.openSettingsAlert()
            }
        }
        
        let minRange = ageRangePicker.selectedRow(inComponent: 0) + MSearchSettings.minRange.defaultValue
        let maxRange = ageRangePicker.selectedRow(inComponent: 1) + MSearchSettings.minRange.defaultValue + 1
        FirestoreService.shared.saveSearchSettings(id: currentPeople.senderId,
                                                   distance: distance,
                                                   minRange: minRange,
                                                   maxRange: maxRange,
                                                   currentLocation: currentLocationIndex,
                                                   lookingFor: lookingFor) {[weak self] result in
            switch result {
            
            case .success(let mPeople):
                //reload peopleListner
                self?.peopleListnerDelegate?.reloadListener(currentPeople: mPeople,
                                                            likeDislikeDelegate: strongLikeDislikeDelegate,
                                                            acceptChatsDelegate: strongAcceptChatsDelegate)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: pickerView delegate
extension EditSearchSettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        MSearchSettings.maxRange.defaultValue - MSearchSettings.minRange.defaultValue
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            let age = MSearchSettings.minRange.defaultValue + row
            let string = NSAttributedString(string: String(age), attributes: [NSAttributedString.Key.font : UIFont.avenirRegular(size: 16)])
            return string
        default:
            let age = MSearchSettings.minRange.defaultValue + row + 1
            let string = NSAttributedString(string: String(age), attributes: [NSAttributedString.Key.font : UIFont.avenirRegular(size: 16)])
            return string
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            let selectedMax = pickerView.selectedRow(inComponent: 1)
            if row > selectedMax {
                pickerView.selectRow(row, inComponent: 1, animated: true)
            }
            
        default:
            let selectedMin = pickerView.selectedRow(inComponent: 0)
            if row < selectedMin {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
}

//MARK: objc
extension EditSearchSettingsViewController {
    @objc private func changeDistanceSlider() {
        let distance = Int(distanceSlider.value)
        if distance == Int(distanceSlider.maximumValue) {
            distanceLabel.text = "Максимальное расстояние: планета Земля"
        } else {
            distanceLabel.text = "Максимальное расстояние: \(distance) км"
        }
    }
    
    @objc private func lookingForTapped() {
        let vc = SelectionViewController(elements: MLookingFor.modelStringAllCases,
                                         description: MLookingFor.description,
                                         selectedValue: lookingForButton.infoLabel.text ?? "",
                                         complition: { [weak self] selected in
                                            self?.lookingForButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func currentLocationTapped() {
        let vc = SelectionViewController(elements: MVirtualLocation.modelStringAllCases,
                                         description: MVirtualLocation.description,
                                         selectedValue: currentLocationButton.infoLabel.text ?? "",
                                         complition: { [weak self] selected in
                                            self?.currentLocationButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }
}

//MARK: setupConstraints
extension EditSearchSettingsViewController {
    private func setupConstraints() {
        view.addSubview(distanceLabel)
        view.addSubview(distanceSlider)
        view.addSubview(ageRangeLabel)
        view.addSubview(ageRangePicker)
        view.addSubview(lookingForButton)
        view.addSubview(currentLocationButton)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceSlider.translatesAutoresizingMaskIntoConstraints = false
        ageRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        ageRangePicker.translatesAutoresizingMaskIntoConstraints = false
        lookingForButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            distanceLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            distanceLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            distanceSlider.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 5),
            distanceSlider.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            ageRangeLabel.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 25),
            ageRangeLabel.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            ageRangeLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            ageRangePicker.topAnchor.constraint(equalTo: ageRangeLabel.bottomAnchor, constant: 5),
            ageRangePicker.leadingAnchor.constraint(equalTo: ageRangeLabel.leadingAnchor),
            ageRangePicker.trailingAnchor.constraint(equalTo: ageRangeLabel.trailingAnchor),
            
            lookingForButton.topAnchor.constraint(equalTo: ageRangePicker.bottomAnchor, constant: 25),
            lookingForButton.leadingAnchor.constraint(equalTo: ageRangePicker.leadingAnchor),
            lookingForButton.trailingAnchor.constraint(equalTo: ageRangePicker.trailingAnchor),
            lookingForButton.heightAnchor.constraint(equalToConstant: 70),
            
            currentLocationButton.topAnchor.constraint(equalTo: lookingForButton.bottomAnchor, constant: 25),
            currentLocationButton.leadingAnchor.constraint(equalTo: lookingForButton.leadingAnchor),
            currentLocationButton.trailingAnchor.constraint(equalTo: lookingForButton.trailingAnchor),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
}

extension EditSearchSettingsViewController {
        //MARK: openSettingsAlert
        private func openSettingsAlert(){
            let alert = UIAlertController(title: "Нет доступа к геопозиции",
                                          text: "Необходимо разрешить доступ к геопозиции в настройках",
                                          buttonText: "Перейти в настройки",
                                          style: .alert) {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            present(alert, animated: true, completion: nil)
        }
    }
