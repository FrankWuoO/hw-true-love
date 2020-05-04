//
//  ViewControllerViewModel.swift
//  HWTrueLove
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import UIKit

enum TaiwanCounty: String, CaseIterable{
    case 台北市
    case 新北市
    case 基隆市
    case 桃園市
    case 新竹市
    case 新竹縣
    case 苗栗縣
    case 台中市
    case 彰化縣
    case 南投縣
    case 雲林縣
    case 嘉義縣
    case 嘉義市
    case 台南市
    case 高雄市
    case 屏東縣
    case 台東縣
    case 花蓮縣
    case 宜蘭縣
    case 澎湖縣
    case 金門縣
    case 連江縣

    init?(fuzzy county: String) {
        let _county = county.replacingOccurrences(of: "臺", with: "台")
        guard let county = TaiwanCounty(rawValue: _county) else { return nil }
        self = county
    }
}

class ViewControllerViewModel {
    private let service: PharmacyServiceAbility
    
    private var allCounties: [TaiwanCounty] = [.台北市, .新北市, .基隆市, .桃園市, .新竹市, .新竹縣, .苗栗縣, .台中市, .彰化縣, .南投縣, .雲林縣, .嘉義縣, .嘉義市, .台南市, .高雄市, .屏東縣, .台東縣, .花蓮縣, .宜蘭縣, .澎湖縣, .金門縣, .連江縣]
    
    private var countyMaskAmountData: [TaiwanCounty: Int] = [:]
    
    private lazy var numberFormatter: NumberFormatter = {
        let fotmatter = NumberFormatter()
        fotmatter.usesGroupingSeparator = true
        fotmatter.groupingSize = 3
        return fotmatter
    }()
    
    var numerOfSecions: Int {
        return allCounties.count
    }
    
    // MARK: Callback functions
    var isLoading: ((Bool) -> Void)? = nil
    var didReceiveError: ((Error) -> Void)? = nil
    var needToReloadData: (() -> Void)? = nil


    init(api service: PharmacyServiceAbility){
        self.service = service
        initVariable()
    }
    
    // MARK: - Private
    private func initVariable(){
        allCounties.forEach({
            countyMaskAmountData[$0] = 0
        })
    }

    private func calculateMaskAmountInCounty(with parsedArray: [MaskStoreAbility]) -> [TaiwanCounty: Int] {
        var calculateData: [TaiwanCounty: Int] = [:]
        allCounties.forEach({ calculateData[$0] = 0 })
        
        parsedArray.forEach({
            if let county = TaiwanCounty(rawValue: $0.county){
                let amount = calculateData[county] ?? 0
                calculateData[county] = amount + $0.maskAdult
            }
        })
        return calculateData
    }
    
    private func fetchData(){
        isLoading?(true)
        
        service.fetchData { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.isLoading?(false)
                
                switch result{
                case .success(let parsedArray):
                    let calculatedData = strongSelf.calculateMaskAmountInCounty(with: parsedArray)
                    strongSelf.countyMaskAmountData = calculatedData
                    strongSelf.needToReloadData?()
                case .failure(let error):
                    strongSelf.didReceiveError?(error)
                }
            }
        }
    }

    // MARK: - Public
    func viewDidAppear() {
        fetchData()
    }
    
    func refreshData(){
        fetchData()
    }
}

// MARK: - TableView Helper
extension ViewControllerViewModel{
    func register(tableView: UITableView) {
        tableView.sectionHeaderHeight = 44
        tableView.register(UINib(nibName: "CountyTableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CountyTableViewHeaderView")
    }
    
    func tableView(numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CountyTableViewHeaderView") as?  CountyTableViewHeaderView
        let county = allCounties[section]
        let maskAmount = countyMaskAmountData[county] ?? 0
        
        headerView?.countyLabel.text = county.rawValue
        headerView?.amountLabel.text = "總計：" + (numberFormatter.string(for: maskAmount) ?? "0")
        return headerView
    }
}
