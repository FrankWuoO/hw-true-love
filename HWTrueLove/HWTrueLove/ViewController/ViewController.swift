//
//  ViewController.swift
//  HWTrueLove
//
//  Created by cheng-en wu on 5/4/20.
//  Copyright © 2020 cheng-en wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var listTableView: UITableView!
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    let viewModel: ViewControllerViewModel = ViewControllerViewModel(api: PharmacyService())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariable()
        initLayout()
        bindViewModel(viewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    //MARK: Init
    private func initVariable(){
        viewModel.register(tableView: listTableView)
    }
    private func initLayout(){
        self.title = "口罩數量"
        refreshControl.frame = CGRect.init(x: 0, y: 0, width: 0, height: 44)
        refreshControl.addTarget(self, action: #selector(triggerRefreshControl(_:)), for: .valueChanged)
        listTableView.refreshControl = refreshControl
    }
    
    private func bindViewModel(_ viewModel: ViewControllerViewModel) {
        viewModel.isLoading = { [unowned self] isLoading in
            if isLoading {
                self.title = "口罩數量(讀取中...)"
            }
            else{
                self.title = "口罩數量"
            }
        }
        viewModel.needToReloadData = { [unowned self] in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.listTableView.reloadData()
        }
        viewModel.didReceiveError = { [unowned self] error in
            self.showErrorAlert(error)
        }
        viewModel.needToReloadSection = { [unowned self] section in
            self.listTableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alertVC = UIAlertController.init(title: "錯誤訊息", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    // MARK: Action
    @objc private func triggerRefreshControl(_ refreshControl: UIRefreshControl) {
        viewModel.refreshData()
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numerOfSecions
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableView(numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.tableView(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.tableView(tableView, cellForRowAt: indexPath)
    }
}
