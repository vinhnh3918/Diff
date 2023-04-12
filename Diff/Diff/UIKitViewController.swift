//
//  UIKitViewController.swift
//  Diff
//
//  Created by mac on 21/03/2023.
//

import UIKit
import Combine
import UIScrollView_InfiniteScroll

class UIKitViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = CoinViewModel()
    private var cancellable: AnyCancellable?
    
    var refreshControl: UIRefreshControl!
    var activityIndicatorView: UIActivityIndicatorView!
    var isLoadingMore = false
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the table view
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        // Create the refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 16
        tableView.addInfiniteScroll { [weak self] tableView in
            guard let strongSelf = self else { return }
            if !strongSelf.isLoadingMore {
                strongSelf.isLoadingMore = true
                strongSelf.currentPage += 1
                strongSelf.fetchAssets(page: strongSelf.currentPage)
            }
            tableView.finishInfiniteScroll()
        }
        
        // Fetch the asset data
        fetchAssets(page: currentPage)
        
    }
    
    // Fetch the asset data from the API
    func fetchAssets(page: Int) {
        let limit = 15 * page
        cancellable = viewModel.fetchCoins(limit: limit)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                self?.refreshControl.endRefreshing()
                self?.isLoadingMore = false
                self?.tableView.reloadData()
            })
    }
    
    
    // Refresh control value changed
    @objc func refreshControlValueChanged() {
        currentPage = 1
        fetchAssets(page: currentPage)
    }
    
}

extension UIKitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCoins()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String = "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        if let coin = viewModel.coin(at: indexPath.row) {
            cell?.textLabel?.text = "\(coin.rank). \(coin.name)"
            cell?.detailTextLabel?.text = "$\(coin.priceUsd ?? "")"
        }
        return cell!
    }
}
