//
//  NSError+HWTrueLove.swift
//  HWTrueLove
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import Foundation

extension NSError {
    static var general: NSError = NSError(domain: "com.hwTrueLove.error.general", code: -1, userInfo: [NSLocalizedDescriptionKey: "哎呀...出了一點小問題"])
}
