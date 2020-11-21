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
    let onlyActiveLabel = UILabel(labelText: "Недавно активные",
                                textFont: .avenirRegular(size: 16),
                                textColor: .mySecondSatColor())
    let onlyActiveAboutLabel = UILabel(labelText: "Показывать пользователей, которые были активны в течении недели",
                                textFont: .avenirRegular(size: 16),
                                textColor: .mySecondColor(),
                                linesCount: 0)
    let onlyActiveSwitch = UISwitch()
    let distanceSlider = UISlider()
    let ageRangePicker = UIPickerView()
    let lookingForButton = OneLineButtonWithHeader(header: "Ищу", info: "")
    let currentLocationButton = OneLineButtonWithHeader(header: "Локация", info: "")
    let scrollView = UIScrollView()
    
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
        setupNavigationController()
        setupData()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView(bottomOffset: 45)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveData()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        distanceSlider.maximumValue = 400
        distanceSlider.minimumValue = 5
        distanceSlider.thumbTintColor = .myLabelColor()
        distanceSlider.tintColor = .myLabelColor()
        
        ageRangePicker.delegate = self
        ageRangePicker.dataSource = self
        
        onlyActiveSwitch.tintColor = .mySecondSatColor()
        onlyActiveSwitch.onTintColor = .mySecondColor()
        onlyActiveSwitch.thumbTintColor = .myWhiteColor()
        
        distanceSlider.addTarget(self, action: #selector(changeDistanceSlider), for: .valueChanged)
        lookingForButton.addTarget(self, action: #selector(lookingForTapped), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        onlyActiveSwitch.addTarget(self, action: #selector(switchChanged), for: .touchUpInside)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layoutSubviews()
        
        NotificationCenter.addObsorverToPremiumUpdate(observer: self, selector: #selector(premiumIsUpdated))
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.title = "Параметры поиска"
        navigationItem.backButtonTitle = ""
    }
    
    
    //MARK: setupData
    private func setupData() {
        if let distance = currentPeople.searchSettings[MSearchSettings.distance.rawValue]{
            distanceSlider.value = Float(distance)
            let defaultDistance = Int(MSearchSettings.distance.defaultValue)
            if distance == Int(distanceSlider.maximumValue) || distance == defaultDistance {
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
        
        if let onlyActive = currentPeople.searchSettings[MSearchSettings.onlyActive.rawValue] {
            onlyActiveSwitch.isOn = onlyActive == 0 ? false : true
        } else {
            let defaultValue = MSearchSettings.onlyActive.defaultValue
            onlyActiveSwitch.isOn = defaultValue == 0 ? false : true
        }
    }
    
    //MARK: saveData
    private func saveData() {
        var distance = 5
        if distanceSlider.value == distanceSlider.maximumValue {
             distance = Int(MSearchSettings.distance.defaultValue)
        } else {
             distance = Int(distanceSlider.value)
        }
        
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
        let onlyActive = onlyActiveSwitch.isOn ? 1 : 0
        
        let minRange = ageRangePicker.selectedRow(inComponent: 0) + MSearchSettings.minRange.defaultValue
        let maxRange = ageRangePicker.selectedRow(inComponent: 1) + MSearchSettings.minRange.defaultValue + 1
        FirestoreService.shared.saveSearchSettings(id: currentPeople.senderId,
                                                   distance: distance,
                                                   minRange: minRange,
                                                   maxRange: maxRange,
                                                   currentLocation: currentLocationIndex,
                                                   lookingFor: lookingFor,
                                                   onlyActive: onlyActive) {[weak self] result in
            switch result {
            
            case .success(let mPeople):
                //reload people
                self?.peopleListnerDelegate?.reloadPeople(currentPeople: mPeople,
                                                          likeDislikeDelegate: strongLikeDislikeDelegate,
                                                          acceptChatsDelegate: strongAcceptChatsDelegate,
                                                          complition: { _ in })
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
    
    @objc private func switchChanged() {
        if !PurchasesService.shared.checkActiveSubscribtionWithApphud() {
            PopUpService.shared.bottomPopUp(header: "Только активные пользователи",
                                            text: "Данный фильтр доступен с подпиской Flava premium",
                                            image: nil,
                                            okButtonText: "Перейти на Flava premium") { [weak self] in
                guard let currentPeople = self?.currentPeople else { return }
                let purchasVC = PurchasesViewController(currentPeople: currentPeople)
                purchasVC.modalPresentationStyle = .fullScreen
                self?.present(purchasVC, animated: true, completion: nil)
            }
            onlyActiveSwitch.isOn.toggle()
        }
    }
    
    @objc private func premiumIsUpdated() {
        if let updatedUser = UserDefaultsService.shared.getMpeople() {
            self.currentPeople = updatedUser
            setupData()
        }
    }
}

//MARK: setupConstraints
extension EditSearchSettingsViewController {
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(distanceLabel)
        scrollView.addSubview(distanceSlider)
        scrollView.addSubview(ageRangeLabel)
        scrollView.addSubview(ageRangePicker)
        scrollView.addSubview(lookingForButton)
        scrollView.addSubview(currentLocationButton)
        scrollView.addSubview(onlyActiveLabel)
        scrollView.addSubview(onlyActiveAboutLabel)
        scrollView.addSubview(onlyActiveSwitch)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceSlider.translatesAutoresizingMaskIntoConstraints = false
        ageRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        ageRangePicker.translatesAutoresizingMaskIntoConstraints = false
        lookingForButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        onlyActiveLabel.translatesAutoresizingMaskIntoConstraints = false
        onlyActiveAboutLabel.translatesAutoresizingMaskIntoConstraints = false
        onlyActiveSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            distanceLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35),
            distanceLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            distanceLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            distanceSlider.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 5),
            distanceSlider.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            ageRangeLabel.topAnchor.constraint(equalTo: distanceSlider.bottomAnchor, constant: 35),
            ageRangeLabel.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            ageRangeLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            ageRangePicker.topAnchor.constraint(equalTo: ageRangeLabel.bottomAnchor, constant: 5),
            ageRangePicker.leadingAnchor.constraint(equalTo: ageRangeLabel.leadingAnchor),
            ageRangePicker.trailingAnchor.constraint(equalTo: ageRangeLabel.trailingAnchor),
            
            lookingForButton.topAnchor.constraint(equalTo: ageRangePicker.bottomAnchor, constant: 35),
            lookingForButton.leadingAnchor.constraint(equalTo: ageRangePicker.leadingAnchor),
            lookingForButton.trailingAnchor.constraint(equalTo: ageRangePicker.trailingAnchor),
            lookingForButton.heightAnchor.constraint(equalToConstant: 70),
            
            currentLocationButton.topAnchor.constraint(equalTo: lookingForButton.bottomAnchor, constant: 35),
            currentLocationButton.leadingAnchor.constraint(equalTo: lookingForButton.leadingAnchor),
            currentLocationButton.trailingAnchor.constraint(equalTo: lookingForButton.trailingAnchor),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 70),
            
            onlyActiveLabel.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 35),
            onlyActiveLabel.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            onlyActiveLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            onlyActiveSwitch.topAnchor.constraint(equalTo: onlyActiveLabel.topAnchor),
            onlyActiveSwitch.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            
            onlyActiveAboutLabel.topAnchor.constraint(equalTo: onlyActiveLabel.bottomAnchor, constant: 10),
            onlyActiveAboutLabel.leadingAnchor.constraint(equalTo: distanceLabel.leadingAnchor),
            onlyActiveAboutLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: -55),
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
