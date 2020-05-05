//
//  HWTrueLoveTests.swift
//  HWTrueLoveTests
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import XCTest
@testable import HWTrueLove

class HWTrueLoveTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func loadJSONFile(name: String) -> Data? {
        guard let path = Bundle(for: type(of: self)).path(forResource: name, ofType: "json") else { return nil }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        } catch {
            XCTFail(error.localizedDescription)
            return nil
        }
    }
}
