//
//  ViewController.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    private let viewModel: ViewModeling

    init(viewModel: ViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ViewModel(fetcher: Fetcher())
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl?.beginRefreshing()

        viewModel.doneLoadingOutput.onNext { [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }

        refresh()
    }

    func refresh() {
        viewModel.refresh()
    }
}

// MARK: - Table view data source
extension ViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, en: tableView)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}
