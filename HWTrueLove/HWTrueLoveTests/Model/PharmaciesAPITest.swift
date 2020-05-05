//
//  PharmaciesAPI.swift
//  HWTrueLoveTests
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import XCTest
@testable import HWTrueLove

class PharmaciesAPITest: HWTrueLoveTests {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func test_codable() {
        let data = loadJSONFile(name: "correct_data")
        XCTAssertNotNil(data, "data should not nil")
        
        let pharmacies = try? JSONDecoder().decode(PharmaciesAPI.self, from: data!)
        XCTAssertNotNil(pharmacies, "PharmaciesAPI data is nil")
        
        let maskStore = pharmacies!.allStores.first
        XCTAssertNotNil(maskStore, "mask store should not nil")
        
        XCTAssertNotNil(maskStore?.county, "mask store -county should not nil")
        XCTAssertNotNil(maskStore?.maskAdult, "mask store -maskAdult should not nil")
    }
}
