//
//  PurchasesViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import StoreKit

class PurchasesViewController: UIViewController {
    
    let scrollView = UIScrollView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setup()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.updateContentView()
    }
    
    //MARK: setup
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        let products = PurchasesService.shared.products
        let basePrisePerMonth = products.firstIndex { product -> Bool in
            product.productIdentifier == MPurchases.oneMonth.rawValue
        }
        guard let indexBasePrisePerMonth = basePrisePerMonth else { fatalError("Can't get index of one month product") }
        
        products.forEach { product in
            switch product.productIdentifier {
            case MPurchases.sevenDays.rawValue:
                sevenDayButton.setup(header: "Неделя",
                                     product: product,
                                     monthCount: 0,
                                     basePricePerMonth: products[indexBasePrisePerMonth].price,
                                     backgroundColor: .myPurpleColor())
            case MPurchases.oneMonth.rawValue:
                oneMonthButton.setup(header: "Месяц",
                                     product: product,
                                     monthCount: 1,
                                     basePricePerMonth: products[indexBasePrisePerMonth].price,
                                     backgroundColor: .myPurpleColor())
            case MPurchases.threeMonth.rawValue:
                threeMonthButton.setup(header: "Три месяца",
                                     product: product,
                                     monthCount: 3,
                                     basePricePerMonth: products[indexBasePrisePerMonth].price,
                                     backgroundColor: .myPurpleColor())
            case MPurchases.oneYear.rawValue:
                oneYearButton.setup(header: "Год",
                                     product: product,
                                     monthCount: 12,
                                     basePricePerMonth: products[indexBasePrisePerMonth].price,
                                     backgroundColor: .myPurpleColor())
            default:
                break
            }
        }
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

    }
    
   
}

//MARK: objc
extension PurchasesViewController {
    @objc func sevenDaysTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc func oneMonthTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc func threeMonthTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc func oneYearTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeTapped() {
        dismiss(animated: true, completion: nil)
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
        
        view.addSubview(scrollView)
        view.addSubview(header)
        view.addSubview(closeButton)
        scrollView.addSubview(infoAboutSubscribe)
        scrollView.addSubview(restorePurchaseButton)
        scrollView.addSubview(termsOfServiceButton)
        scrollView.addSubview(privacyPolicyButton)
        scrollView.addSubview(sevenDayButton)
        scrollView.addSubview(oneMonthButton)
        scrollView.addSubview(threeMonthButton)
        scrollView.addSubview(oneYearButton)
        
        NSLayoutConstraint.activate([
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
