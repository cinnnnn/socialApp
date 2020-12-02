//
//  MPremiumInfo.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//



import Foundation

class MPremiumInfo {
    static let shared = MPremiumInfo()
    private init() { }
    
    let elements: [MCollectionViewGalleryElement] = [
        MCollectionViewGalleryElement(header: "Только активные пользователи",
                                      info: "Включи фильтр и не трать время на неактивных пользователей.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Последняя активность",
                                      info: "Видишь время последней активности пользователей.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Знаешь, кто лайкнул тебя",
                                      info: "Позволяет просматривать всех тех, кто поставил тебе лайк. Решение за тобой.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Безлимитные лайки",
                                      info: "Повысь свои шансы на успех.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Чат не будет удален",
                                      info: "Таймер чата будет остановлен, как только ты захочешь.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Приватные фото",
                                      info: "Скрой фото от незнакомцев. Только твои друзья увидят их.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white),
        MCollectionViewGalleryElement(header: "Режим инкогнито",
                                      info: "Скрой себя от других, пока ты не поставишь ему лайк первым.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .white,
                                      infoColor: .white)
        
    ]
}
