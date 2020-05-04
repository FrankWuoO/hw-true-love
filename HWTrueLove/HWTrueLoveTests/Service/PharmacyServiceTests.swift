//
//  PharmacyServiceTests.swift
//  HWTrueLoveTests
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import XCTest
@testable import HWTrueLove

class PharmacyServiceTests: HWTrueLoveTests {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
        
    func test_correct_response_data() {
        let expectation = self.expectation(description: "fetch correct mask sotre data")
        
        guard let data = loadJSONFile(name: "correct_data") else {
            XCTFail("correct_data file not exist!")
            return 
        }
        
        let apiService = PharmacyService(session: MockURLSession(data: data))

        apiService.fetchData { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("This test case should be successful")
            }
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_invalid_response_data() {
        let expectation = self.expectation(description: "fetch invalid mask sotre data")

        let apiService = PharmacyService(session: MockURLSession())
        
        apiService.fetchData { (result) in
            switch result {
            case .success:
                XCTFail("This test case should't be successful")
            case .failure:
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

}
