//
//  PurchaseButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseButton: UIButton {
    
    let headerLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 14), textColor: .white)
    let priceLabel = UILabel(labelText: "", textFont: .avenirBold(size: 18), textColor: .white)
    let monthCountLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 11), textColor: .white)
    let pricePerMonthLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 11), textColor: .white)
    let savingInfoLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 11), textColor: .white)
    var monthCount: Int?
    var product: SKProduct?
    var basePricePerMonth: NSDecimalNumber?
    
     init () {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(header: String, product: SKProduct, monthCount: Int, basePricePerMonth: NSDecimalNumber, backgroundColor: UIColor, selectBackground: UIColor) {
        
        self.monthCount = monthCount
        self.basePricePerMonth = basePricePerMonth
        self.product = product
        self.headerLabel.text = header
        
        if isSelected {
            self.backgroundColor = selectBackground
        } else {
            self.backgroundColor = backgroundColor
        }
        
        let pricePerMoth = Double(truncating: product.price) / Double(monthCount)
        let savingInfoPercent = 100 - (pricePerMoth / Double(truncating: basePricePerMonth) * 100)
        let pricePerMothLocalized = localizedPriceStringFor(product: product, price: pricePerMoth) ?? ""
        
        priceLabel.text = localizedPriceStringFor(product: product)
        
        switch monthCount {
        case 3:
            monthCountLabel.text = "3 месяца"
            pricePerMonthLabel.text = "за \(pricePerMothLocalized) в месяц"
            savingInfoLabel.text = "Сэкономишь \(Int(savingInfoPercent))%"
        case 12:
            monthCountLabel.text = "12 месяцев"
            pricePerMonthLabel.text = "за \(pricePerMothLocalized) в месяц"
            savingInfoLabel.text = "Сэкономишь \(Int(savingInfoPercent))%"
        default:
            break
        }
    }
    
    private func localizedPriceStringFor(product : SKProduct, price: Double? = nil) -> String? {
        let formatter = NumberFormatter()
        
        formatter.locale = product.priceLocale
        formatter.numberStyle = .currency
        if let price = price {
            return formatter.string(from: NSNumber(value: price))
        } else {
            return formatter.string(from: product.price)
        }
    }
}

extension PurchaseButton {
    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        monthCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pricePerMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        savingInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(headerLabel)
        addSubview(priceLabel)
        addSubview(monthCountLabel)
        addSubview(pricePerMonthLabel)
        addSubview(savingInfoLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            priceLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            monthCountLabel.bottomAnchor.constraint(equalTo: pricePerMonthLabel.topAnchor),
            monthCountLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            monthCountLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            pricePerMonthLabel.bottomAnchor.constraint(equalTo: savingInfoLabel.topAnchor),
            pricePerMonthLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            pricePerMonthLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            savingInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            savingInfoLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            savingInfoLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
        ])
    }
}
