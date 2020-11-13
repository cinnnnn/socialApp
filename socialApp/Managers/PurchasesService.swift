//
//  PurchasesService.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import StoreKit

class PurchasesService: NSObject {
    
    static let shared = PurchasesService()
    
    private override init() { }
    
    var products: [SKProduct] = []
    
    public func setupPurchases(complition: @escaping(Bool) -> Void) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            complition(true)
        } else {
            complition(false)
        }
    }
    
    public func getProducts() {
        let identifieres: Set = [
            MPurchases.sevenDays.rawValue,
            MPurchases.oneMonth.rawValue,
            MPurchases.threeMonth.rawValue,
            MPurchases.oneYear.rawValue,
        ]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifieres)
        productRequest.delegate = self
        productRequest.start()
    }
}

extension PurchasesService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}

extension PurchasesService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        products = response.products
        
        products.forEach { product in
            print(product.localizedTitle)
        }
    }
}
