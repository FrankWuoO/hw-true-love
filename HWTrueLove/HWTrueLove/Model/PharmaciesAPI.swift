//
//  PharmaciesAPI.swift
//  HWTrueLove
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

protocol MaskStoreAbility {
    var maskAdult: Int { get }
    
    var county: String { get }
}

// MARK: - PharmaciesAPI
struct PharmaciesAPI: Codable {
    let allStores: [MaskStore]
    
    enum CodingKeys: String, CodingKey {
        case allStores = "features"
    }
    
    // MARK: - allStores
    struct MaskStore: Codable, MaskStoreAbility {
        private let properties: Properties
        
        var maskAdult: Int {
            return properties.maskAdult
        }
        
        var county: String {
            return properties.county
        }
       
        // MARK: - Properties
        struct Properties: Codable {
            let maskAdult: Int
            let county: String

            enum CodingKeys: String, CodingKey {
                case maskAdult = "mask_adult"
                case county
            }
        }
    }
}
