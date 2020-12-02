//
//  MDefaultInterests.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MDefaultInterests: String, CaseIterable {
    case cofe = "Кофе"
    case wine = "Вино"
    case whiskey = "Виски"
    case soul = "Соул"
    case it = "IT"
    case graphicDesign = "Графический дизайн"
    case architecture = "Архитектура"
    case history = "История"
    case music = "Музыка"
    case fashion = "Мода"
    case dance = "Танцы"
    case snowboard = "Сноуборд"
    case skate = "Скейт"
    case phoyo = "Фото"
    case erotics = "Эротика"
    case health = "Здоровье"
    case auto = "Авто"
    case moto = "Мото"
    case chiald = "Дети"
    case humar = "Юмор"
    case finance = "Финансы"
    case medicine = "Медецина"
    case developer = "Разработка ПО"
    case clubs = "Клубы"
    case films = "Фильмы"
    case tea = "Чай"
    case cats = "Кошки"
    case dogs = "Собаки"
    case blogs = "Блогинг"
    case bear = "Крафтовое пиво"
    case sport = "Спорт"
    case gamer = "Геймер"
    case swimming = "Плавание"
    case politics = "Политика"
    case poetry = "Поэзия"
    case yoga = "Йога"
    case travels = "Путешествия"
    case rap = "Рэп"
    case rock = "Рок"
    case jass = "Джаз"
    case starWars = "Звездные войны"
    case serials = "Сериалы"
    case coocking = "Кулинария"
    case running = "Бег"
    case netflix = "Netflix"
    case instagram = "Instagram"
    case smm = "SMM"
    case videoBloging = "Видеоблогинг"
    
}

extension MDefaultInterests {
    static func getSortedInterests() -> [String] {
        allCases.map { interest -> String in
            interest.rawValue
        }.sorted{ $0 > $1 }
    }
}
