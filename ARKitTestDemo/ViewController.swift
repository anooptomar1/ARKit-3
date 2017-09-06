//
//  ViewController.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/6.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let plateVC = MyARKitViewController.init()
            self.navigationController?.pushViewController(plateVC, animated: true)
        default:
            print("还没有跳转事件哦")
        }
    }
}

