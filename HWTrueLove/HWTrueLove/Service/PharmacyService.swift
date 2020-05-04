//
//  PharmacyService.swift
//  HWTrueLove
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import Foundation

protocol PharmacyServiceAbility {
    var hostURL: URL { get }
    
    func fetchData(completion: @escaping(Result<[MaskStoreAbility], Error>) -> Void)
}

class PharmacyService: PharmacyServiceAbility {
    private let session: URLSessionProtocol
    
    lazy var hostURL: URL = {
        if let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json"){
            return url
        }
        else{
            fatalError("not valid url")
        }
    }()
    
    init(session: URLSessionProtocol = URLSession.shared){
        self.session = session
    }
    
    func fetchData(completion: @escaping (Result<[MaskStoreAbility], Error>) -> Void) -> Void{
        session.dataTask(with: hostURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let pharmacies = try JSONDecoder().decode(PharmaciesAPI.self, from: data)
                    completion(.success(pharmacies.allStores))
                }
                catch {
                    completion(.failure(error))
                }
            }
            else{
                completion(.failure(NSError.general))
            }
        }.resume()
    }
}
