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
    
    // MARK: Private
    private func fixCountyProblems(_ parsedArray: inout [PharmaciesAPI.MaskStore]) {
        for i in 0..<parsedArray.count{
            let store = parsedArray[i]
            var countyString = store.county
            //Sometimes `County` property will be empty, so we need to detect value from address manually
            if countyString.isEmpty {
                let startIndex = store.address.startIndex
                let endIndex = store.address.index(store.address.startIndex, offsetBy: 2)
                countyString = String(store.address[startIndex...endIndex])
            }
            //Fuzzy word of county
            if let county = TaiwanCounty(fuzzy: countyString){
                parsedArray[i].changeCounty(county.rawValue)
            }
            else{
                print("unknown county:", countyString)
            }
        }
    }
    // MARK: Public
    func fetchData(completion: @escaping (Result<[MaskStoreAbility], Error>) -> Void) -> Void{
        session.dataTask(with: hostURL) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    var pharmacies = try JSONDecoder().decode(PharmaciesAPI.self, from: data)
                    strongSelf.fixCountyProblems(&pharmacies.allStores)
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
