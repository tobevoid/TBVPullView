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
    private var numberOfRows = Int(5)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        var triggeringImages = [UIImage]()
        for i in 1...3 {
            triggeringImages.append(UIImage(named: "Preloader_2_step_\(i)")!)
        }
        
        var loadingImages = [UIImage]()
        for i in 0...15 {
            loadingImages.append(UIImage(named: String(format: "Preloader_2_000%02d", i))!)
        }
        
        self.tableView.header = TBVAnimatePullView(type: .Header, triggeringImages: triggeringImages, loadingImages: loadingImages, backgroundColor: UIColor.whiteColor()) { (refreshView) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
                print("load new complete")
                self.numberOfRows = 5
                self.tableView.reloadData()
                refreshView.endRefreshing()
                //                refreshView.showPullView = false
            })
            
        }
//        self.tableView.header = TVBAnimatePullView(type: .Header, imageName: "4.gif", backgroundColor: UIColor(red: 102 / 255.0, green: 206 / 255.0, blue: 255 / 255.0, alpha: 1.0)) { (refreshView) in
//        }
//        self.tableView.header?.showPullView = false
        
        //var loadingImages = [UIImage]()
////        if let gifURL = NSBundle.mainBundle().URLForResource("2.gif", withExtension: nil) {
//            if let data = NSData(contentsOfURL: gifURL) {
//                if let images = UIImage.imagesWithGifData(data) {
//                    loadingImages = images
//                }
//            }
//        }
//        
//        self.tableView.footer = TVBAnimatePullView(type: .Footer, triggeringImages: loadingImages, loadingImages: loadingImages, backgroundColor: UIColor(red: 28 / 255.0, green: 39 / 255.0, blue: 42 / 255.0, alpha: 1.0)) { (refreshView) in
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), {
//                print("load more complete")
//                self.numberOfRows += 5
//                self.tableView.reloadData()
//                refreshView.endRefreshing()
//                refreshView.showPullView = false
//                self.tableView.header?.showPullView = true
//            })
//        }
//        
        
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