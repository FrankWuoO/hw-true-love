//
//  MockURLSession.swift
//  HWTrueLoveTests
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import Foundation
@testable import HWTrueLove

class MockURLSession: URLSessionProtocol {
    private let response: URLResponse?
    private let data: Data?
    private let error: Error?
    
    var dataTask = MockURLSessionDataTask()

    init(mock response: URLResponse? = nil, data: Data? = nil, error: Error? = nil){
        self.response = response
        self.data = data
        self.error = error
    }
    
    
    func dataTask(with url: URL, completionHandler: @escaping DataTaskCallBack) -> URLSessionDataTaskProtocol {
        completionHandler(data, response, error)
        return dataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false

    func resume() {
        resumeWasCalled = true
    }
}

