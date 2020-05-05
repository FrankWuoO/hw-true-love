//
//  ViewControllerViewModelTest.swift
//  HWTrueLoveTests
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import XCTest
@testable import HWTrueLove

class ViewControllerViewModelTest: HWTrueLoveTests {
    var viewModel: ViewControllerViewModel!

    override func setUpWithError() throws {
        guard let data = loadJSONFile(name: "correct_data") else {
            XCTFail("correct_data file not exist!")
            return
        }
        let apiService = PharmacyService(session: MockURLSession(data: data))
        
        viewModel = ViewControllerViewModel(api: apiService)
        

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_viewDidAppear() {
        let loadingExpectation = expectation(description: "detect is loading state")
        let notLoadingExpectation = expectation(description: "detect is not loading state")
        let needToReloadExpectation = expectation(description: "detect need to reload data")
        
        viewModel.isLoading = { isLoading in
            if isLoading{
                loadingExpectation.fulfill()
            }
            else{
                notLoadingExpectation.fulfill()
            }
        }
        viewModel.needToReloadData = {
            needToReloadExpectation.fulfill()
        }
        
        viewModel.viewDidAppear()

        wait(for: [loadingExpectation, notLoadingExpectation, needToReloadExpectation], timeout: 1)
    }
    
}
