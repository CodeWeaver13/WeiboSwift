//
//  HomeViewController.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/2/28.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    /// 微博数据模型
    var weiboData: WeiboData?
    
    ///  MARK: 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    ///  加载微博数据
    func loadData() {
        SVProgressHUD.show()
        WeiboData.loadData { (data, error) -> () in
            if error != nil {
                println(error)
                SVProgressHUD.showInfoWithStatus("网络不给力，请重试")
                return
            }
            SVProgressHUD.dismiss()
            if data != nil {
                self.weiboData = data
                self.tableView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weiboData?.statuses?.count ?? 0
    }
    
    ///  根据indexPath返回微博Cell模型和标识符
    func cellInfo(indexPath: NSIndexPath) -> (model: WeiboModel, cellID: String) {
        let model = self.weiboData!.statuses![indexPath.row]
        let cellID = HomeWeiboCell.cellID(model)
        return (model, cellID)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let info = cellInfo(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(info.cellID, forIndexPath: indexPath) as! HomeWeiboCell
        cell.model = info.model
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let info = cellInfo(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(info.cellID) as! HomeWeiboCell
        return cell.cellHeight(info.model)
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
}