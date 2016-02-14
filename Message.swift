//
//  Message
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//

import Foundation


struct Message {
    let id: Int
    let updated_at: String
    let image_url: NSString
    let text: String?
    let idnick: Int
    let nickname: String
    let avatar_image: NSURL?
}

struct Param {
    var total_items_count: Int
}

struct structParam2 {
    var idNikForMyMessage: Int?
}

struct structParam3 {
    var sending: Bool?
}