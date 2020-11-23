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
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Последняя активность",
                                      info: "Видишь время последней активности пользователей.",
                                      backgroundColor: .mySecondColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Знаешь, кто лайкнул тебя",
                                      info: "Позволяет просматривать всех тех, кто поставил тебе лайк. Решение за тобой.",
                                      backgroundColor: .myFirstColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Безлимитные лайки",
                                      info: "Повысь свои шансы на успех.",
                                      backgroundColor: .myFirstSatColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Чат не будет удален",
                                      info: "Таймер чата будет остановлен, как только ты захочешь.",
                                      backgroundColor: .myFirstColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Приватные фото",
                                      info: "Скрой фото от незнакомцев. Только твои друзья увидят их.",
                                      backgroundColor: .mySecondColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        MCollectionViewGalleryElement(header: "Режим инкогнито",
                                      info: "Скрой себя от других, пока ты не поставишь ему лайк первым.",
                                      backgroundColor: .mySecondSatColor(),
                                      headerColor: .myWhiteColor(),
                                      infoColor: .myWhiteColor()),
        
    ]
}
