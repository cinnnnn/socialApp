//
//  MMediaItem.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import MessageKit

struct MMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
