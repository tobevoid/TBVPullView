//
//  TVBViewController.swift
//  TVBAnimatePullView
//
//  Created by tripleCC on 16/5/20.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TVBViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let identifier = "TVBViewControllerCell"
    private var number = Int(0)
    private var numberOfRows = Int(15)
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.header = TVBAnimatePullView(type: .Header, refreshingCallBack: { (refreshView) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
                print("loading complete")
//                self.numberOfRows += self.numberOfRows
                self.tableView.reloadData()
                refreshView.endRefreshing()
            })
        })
        
        tableView.footer = TVBAnimatePullView(type: .Footer, refreshingCallBack: { (refreshView) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
                print("loading complete")
                //                self.numberOfRows += self.numberOfRows
                self.tableView.reloadData()
                refreshView.endRefreshing()
            })
        })
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
//            self.tableView.frame.size.width = 100
        })
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
}


extension TVBViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        cell.textLabel?.text = String(number + 1)
        number = number == numberOfRows ? 0 : number + 1
        return cell
    }
}