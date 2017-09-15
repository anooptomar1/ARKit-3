//
//  ViewController.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/6.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard ARWorldTrackingConfiguration.isSupported else{
            let alertView = UIAlertController.init(title: "ARKit is not available on this device.", message: "This app requires world tracking, which is available only on iOS devices with the A9 processor or later.", preferredStyle: .alert)
            let cancelAc = UIAlertAction.init(title: "取消", style:.cancel, handler: nil)
            let confirmAc = UIAlertAction.init(title: "确定", style: .default, handler: { (alert) in
                print("开始点击了")
            })
            alertView.addAction(cancelAc);
            alertView.addAction(confirmAc);
            self.present(alertView, animated: true, completion: nil)
            return;
        }
        switch indexPath.row {
        case 0:
            let plateVC = MyARKitViewController.init()
            self.navigationController?.pushViewController(plateVC, animated: true)
        case 1:
            let tapeVC = LineViewController.init()
            self.navigationController?.pushViewController(tapeVC, animated: true)
        case 2:
            let tapeVC = DoorViewController.init()
            self.navigationController?.pushViewController(tapeVC, animated: true)
        default:
            print("还没有跳转事件哦")
        }
    }
}

