//
//  PurchasesViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import StoreKit
import ApphudSDK

class PurchasesViewController: UIViewController {
    
    let currentPeople: MPeople
    let scrollView = UIScrollView()
    let loadingView = LoadingView(name: "wallet", isHidden: true, contentMode: .scaleAspectFit)
    let header = UILabel(labelText: "Перейти на Flava premium",
                         textFont: .avenirBold(size: 18))
    
    let closeButton = UIButton(image: UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(font: .avenirBold(size: 16))) ?? #imageLiteral(resourceName: "reject"),
                               tintColor: .myLabelColor(),
                               backgroundColor: .myWhiteColor())
    
    let infoAboutSubscribe = UILabel(labelText: MLabels.subscriptionsAbout.rawValue,
                                     textFont: .avenirRegular(size: 12),
                                     textColor: .myGrayColor(),
                                     linesCount: 0)
    let restorePurchaseButton = UIButton(newBackgroundColor: .myWhiteColor(),
                                         title: "Восстановить покупки",
                                         titleColor: .myLabelColor(),
                                         font: .avenirRegular(size: 12))
    let termsOfServiceButton = UIButton(newBackgroundColor: .myWhiteColor(),
                                        title: "Условия и положения",
                                        titleColor: .myLabelColor(),
                                        font: .avenirRegular(size: 12))
    let privacyPolicyButton = UIButton(newBackgroundColor: .myWhiteColor(),
                                       title: "Политика конфиденциальности",
                                       titleColor: .myLabelColor(),
                                       font: .avenirRegular(size: 12))
    let sevenDayButton = PurchaseButton()
    let oneMonthButton = PurchaseButton()
    let threeMonthButton = PurchaseButton()
    let oneYearButton = PurchaseButton()
    
    init(currentPeople: MPeople) {
        self.currentPeople = currentPeople
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setup()
        setupListners()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.updateContentView()
    }
    
    //MARK: setup
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        restorePurchaseButton.addTarget(self, action: #selector(restorePurchaseTapped), for: .touchUpInside)
        
        sevenDayButton.addTarget(self, action: #selector(sevenDaysTapped), for: .touchUpInside)
        oneMonthButton.addTarget(self, action: #selector(oneMonthTapped), for: .touchUpInside)
        threeMonthButton.addTarget(self, action: #selector(threeMonthTapped), for: .touchUpInside)
        oneYearButton.addTarget(self, action: #selector(oneYearTapped), for: .touchUpInside)
        termsOfServiceButton.addTarget(self, action: #selector(termsOfServiceTapped), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        updateProduct()

    }
    
    private func setupListners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProduct),
                                               name: NSNotification.Name(rawValue: PurchasesService.productNotificationIdentifier),
                                               object: nil)
    }
    
    //MARK: purchas
    private func purchase(identifier: MPurchases) {
        loadingView.show()
        let strongCurrentPeople = currentPeople
        PurchasesService.shared.purcheWithApphud(product: identifier) {[weak self] result in
            self?.loadingView.hide()
            self?.dismiss(animated: true, completion: nil)
            switch result {
            
            case .success(let resultOfpurches):
                if let subscribtion = resultOfpurches.subscription, subscribtion.isActive(){
                    let dateToContine = subscribtion.expiresDate
                    
                    FirestoreService.shared.saveIsGoldMember(id: strongCurrentPeople.senderId,
                                                             isGoldMember: true,
                                                             goldMemberDate: dateToContine,
                                                             goldMemberPurches: identifier ) { result in
                        switch result {
                        
                        case .success(_):
                            PopUpService.shared.showInfo(text: "Flava premium приобретен до \(dateToContine.getShortFormattedDate())")
                        case .failure(let error):
                            PopUpService.shared.showInfo(text: "Подписка удалась, но при сохранении возникла ошибка: \(error.localizedDescription)")
                        }
                    }
                } else  {
                    PopUpService.shared.showInfo(text: "Подписка не удалась")
                }
            case .failure(let error):
                PopUpService.shared.showInfo(text: "Ошибка \(error.localizedDescription)")
            }
        }
    }
}

//MARK: objc
extension PurchasesViewController {
    
    //MARK: updateProduct
    @objc private func updateProduct(){
      
        guard
            let monthProduct = PurchasesService.shared.products.filter({ $0.productIdentifier == MPurchases.oneMonth.rawValue }).first
        else { fatalError("Can't get month product") }
        
        PurchasesService.shared.products.forEach { product in
            switch product.productIdentifier {
            case MPurchases.sevenDays.rawValue:
                sevenDayButton.setup(header: "Неделя",
                                     product: product,
                                     monthCount: 0,
                                     basePricePerMonth: monthProduct.price,
                                     backgroundColor: .mySecondSatColor(),
                                     selectBackground: .mySecondColor())
            case MPurchases.oneMonth.rawValue:
                oneMonthButton.setup(header: "Месяц",
                                     product: product,
                                     monthCount: 1,
                                     basePricePerMonth: monthProduct.price,
                                     backgroundColor: .mySecondSatColor(),
                                     selectBackground: .mySecondColor())
            case MPurchases.threeMonth.rawValue:
                threeMonthButton.setup(header: "Три месяца",
                                       product: product,
                                       monthCount: 3,
                                       basePricePerMonth: monthProduct.price,
                                       backgroundColor: .mySecondSatColor(),
                                       selectBackground: .mySecondColor())
            case MPurchases.oneYear.rawValue:
                oneYearButton.setup(header: "Год",
                                    product: product,
                                    monthCount: 12,
                                    basePricePerMonth: monthProduct.price,
                                    backgroundColor: .mySecondSatColor(),
                                    selectBackground: .mySecondColor())
            default:
                break
            }
        }
    }
    
    //MARK: restorePurchaseTapped
    @objc func restorePurchaseTapped() {
        let strongCurrentPeople = currentPeople
        loadingView.show()
        
        PurchasesService.shared.checkSubscribtion(currentPeople: strongCurrentPeople,
                                                  isRestore: true) {[weak self] _ in
            self?.loadingView.hide()
        }
    }

    
    @objc private func sevenDaysTapped() {
        purchase(identifier: .sevenDays)
    }
    @objc private func oneMonthTapped() {
        purchase(identifier: .oneMonth)
    }
    @objc private func threeMonthTapped() {
        purchase(identifier: .threeMonth)
    }

    @objc private func oneYearTapped() {
        purchase(identifier: .oneYear)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func termsOfServiceTapped() {
        if let url = URL(string: MLinks.termsOfServiceLink.rawValue) {
            let webController = WebViewController(urlToOpen: url)
            webController.modalPresentationStyle = .pageSheet
            present(webController, animated: true, completion: nil)
        }
    }
    
    @objc private func privacyTapped() {
        if let url = URL(string: MLinks.privacyLink.rawValue) {
            let webController = WebViewController(urlToOpen: url)
            webController.modalPresentationStyle = .pageSheet
            present(webController, animated: true, completion: nil)
        }
    }
}

extension PurchasesViewController {
    //MARK: setupConstraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        infoAboutSubscribe.translatesAutoresizingMaskIntoConstraints = false
        restorePurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        termsOfServiceButton.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        sevenDayButton.translatesAutoresizingMaskIntoConstraints = false
        oneMonthButton.translatesAutoresizingMaskIntoConstraints = false
        threeMonthButton.translatesAutoresizingMaskIntoConstraints = false
        oneYearButton.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        view.addSubview(header)
        view.addSubview(closeButton)
        view.addSubview(loadingView)
        scrollView.addSubview(infoAboutSubscribe)
        scrollView.addSubview(restorePurchaseButton)
        scrollView.addSubview(termsOfServiceButton)
        scrollView.addSubview(privacyPolicyButton)
        scrollView.addSubview(sevenDayButton)
        scrollView.addSubview(oneMonthButton)
        scrollView.addSubview(threeMonthButton)
        scrollView.addSubview(oneYearButton)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor,constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sevenDayButton.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sevenDayButton.heightAnchor.constraint(equalTo: sevenDayButton.widthAnchor, multiplier: 0.8),
            sevenDayButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            sevenDayButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
            
            oneMonthButton.topAnchor.constraint(equalTo: scrollView.topAnchor),
            oneMonthButton.heightAnchor.constraint(equalTo: oneMonthButton.widthAnchor, multiplier: 0.8),
            oneMonthButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
            oneMonthButton.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            
            threeMonthButton.topAnchor.constraint(equalTo: sevenDayButton.bottomAnchor, constant: 10),
            threeMonthButton.heightAnchor.constraint(equalTo: threeMonthButton.widthAnchor, multiplier: 0.8),
            threeMonthButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            threeMonthButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
            
            oneYearButton.topAnchor.constraint(equalTo: oneMonthButton.bottomAnchor, constant: 10),
            oneYearButton.heightAnchor.constraint(equalTo: oneYearButton.widthAnchor, multiplier: 0.8),
            oneYearButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
            oneYearButton.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            
            restorePurchaseButton.topAnchor.constraint(equalTo: oneYearButton.bottomAnchor, constant: 10),
            restorePurchaseButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            
            infoAboutSubscribe.topAnchor.constraint(equalTo: restorePurchaseButton.bottomAnchor, constant: 10),
            infoAboutSubscribe.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            infoAboutSubscribe.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            
            termsOfServiceButton.topAnchor.constraint(equalTo: infoAboutSubscribe.bottomAnchor, constant: 5),
            termsOfServiceButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            
            privacyPolicyButton.topAnchor.constraint(equalTo: termsOfServiceButton.bottomAnchor, constant: 5),
            privacyPolicyButton.leadingAnchor.constraint(equalTo: header.leadingAnchor)
            
        ])
    }
}
