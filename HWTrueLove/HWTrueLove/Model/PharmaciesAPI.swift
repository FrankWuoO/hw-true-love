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
    
    var address: String { get }
}

// MARK: - PharmaciesAPI
struct PharmaciesAPI: Codable {
    var allStores: [MaskStore]
    
    enum CodingKeys: String, CodingKey {
        case allStores = "features"
    }
    
    // MARK: - allStores
    struct MaskStore: Codable, MaskStoreAbility {
        
        private var properties: Properties
        
        var maskAdult: Int {
            return properties.maskAdult
        }
        
        var county: String {
            return properties.county
        }
        
        var address: String {
            return properties.address
        }
        
        // MARK: Hotfix
        mutating func changeCounty(_ newCounty: String) {
            properties = Properties(maskAdult: maskAdult, county: newCounty, address: address)
        }
        // MARK: - Properties
        struct Properties: Codable {
            let maskAdult: Int
            let county: String
            let address: String

            enum CodingKeys: String, CodingKey {
                case maskAdult = "mask_adult"
                case county, address
            }
        }
    }
}
