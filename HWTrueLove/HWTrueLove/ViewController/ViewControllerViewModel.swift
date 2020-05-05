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
    private var countyMaskStoresData: [TaiwanCounty: [MaskStoreAbility]] = [:]

    private var countyHeaderViewIsExtended: [TaiwanCounty: Bool] = [:]

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
    var needToReloadSection: ((Int) -> Void)? = nil


    init(api service: PharmacyServiceAbility){
        self.service = service
        initVariable()
    }
    
    // MARK: - Private
    private func initVariable(){
        allCounties.forEach({
            countyMaskAmountData[$0] = 0
            countyHeaderViewIsExtended[$0] = false
            countyMaskStoresData[$0] = []
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
    
    private func calculateMaskStoresInCounty(with parsedArray: [MaskStoreAbility]) -> [TaiwanCounty: [MaskStoreAbility]] {
        var calculateData: [TaiwanCounty: [MaskStoreAbility]] = [:]
        allCounties.forEach({ calculateData[$0] = [] })
        
        parsedArray.forEach({
            if let county = TaiwanCounty(rawValue: $0.county){
                calculateData[county]?.append($0)
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
                    let maskAmountData = strongSelf.calculateMaskAmountInCounty(with: parsedArray)
                    strongSelf.countyMaskAmountData = maskAmountData
                    
                    let maskStoresData = strongSelf.calculateMaskStoresInCounty(with: parsedArray)
                    strongSelf.countyMaskStoresData = maskStoresData
                    
                    strongSelf.needToReloadData?()
                case .failure(let error):
                    strongSelf.didReceiveError?(error)
                }
            }
        }
    }
    
    private func extendButtonTitle(with county: TaiwanCounty) -> String {
        let isExtended = countyHeaderViewIsExtended[county] ?? false
        return isExtended ? "-" : "+"
    }
    
    @objc private func clickedCountyExtendButton(_ button: UIButton){
        let county = allCounties[button.tag]
        var isExtended = countyHeaderViewIsExtended[county] ?? false
        isExtended.toggle()
        countyHeaderViewIsExtended[county] = isExtended
        button.setTitle(extendButtonTitle(with: county), for: .normal)
        needToReloadSection?(button.tag)
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
        tableView.register(UINib(nibName: "MaskStoreTableViewCell", bundle: nil), forCellReuseIdentifier: "MaskStoreTableViewCell")
    }
    
    func tableView(numberOfRowsInSection section: Int) -> Int {
        let county = allCounties[section]
        let isExtended = countyHeaderViewIsExtended[county] ?? false
        if isExtended {
            return countyMaskStoresData[county]?.count ?? 1
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let county = allCounties[section]
        let maskAmount = countyMaskAmountData[county] ?? 0
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CountyTableViewHeaderView") as?  CountyTableViewHeaderView
        headerView?.countyLabel.text = county.rawValue
        headerView?.amountLabel.text = "總計：" + (numberFormatter.string(for: maskAmount) ?? "0")
        headerView?.extendButton.tag = section
        headerView?.extendButton.setTitle(extendButtonTitle(with: county), for: .normal)
        headerView?.extendButton.addTarget(self, action: #selector(clickedCountyExtendButton(_:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let county = allCounties[indexPath.section]
        let allMaskStores = countyMaskStoresData[county] ?? []
        let maskStore = allMaskStores[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MaskStoreTableViewCell", for: indexPath) as? MaskStoreTableViewCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = maskStore.name
        cell.addressLabel.text = maskStore.address
        cell.amountLabel.text = "\(maskStore.maskAdult)"
        return cell
    }
}
