//
//  LineViewController.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/8.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import UIKit
import ARKit

class LineViewController: ZJBaseViewController,ARSCNViewDelegate {
    
    var mySenceView = ARSCNView()
    var mySession = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    //添加指示显示
    var infoLabel:UILabel!
    var resetBtn:UIButton!
    var unitBtn:UIButton!
    var imageMark:UIImageView!
    var isMeasuring = false //是不是在测量
    
    var vectorZero = SCNVector3()
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    var lines = [Line]()
    var currentLine:Line?
    var unit = LengthUnit.cenitMeter//默认cm
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //全局追踪 重设节点 移除已存在的锚点
        mySession.run(configuration, options: [.resetTracking,.removeExistingAnchors]);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mySession.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true;
        self.modalPresentationCapturesStatusBarAppearance = false;
        self.edgesForExtendedLayout = .all;
        
        mySenceView = ARSCNView.init(frame: self.view.bounds)
        mySenceView.delegate = self
        mySenceView.session = mySession
        
        self.view.addSubview(mySenceView)
        addLabelInfo()
    }
    
    //添加控件
    func addLabelInfo() {
        
        //显示指示符
        infoLabel = UILabel.init(frame: CGRect.init(x: 20, y: 60, width: kViewWidth-40, height: 30))
        infoLabel.textColor = UIColor.white
        infoLabel.text = "环境初始化中"
        infoLabel.textAlignment = .center
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(infoLabel)
        //中间的按钮
        imageMark = UIImageView.init(image: UIImage(named: "WhiteTarget"))
        imageMark.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        imageMark.center = self.view.center
        self.view.addSubview(imageMark)
        //放置按钮
        resetBtn = UIButton.init(frame: CGRect.init(x: 0, y: kViewHeight-30, width: kViewWidth/2.0, height: 30))
        resetBtn.tag = 1
        resetBtn.setTitle("重置", for: .normal)
        resetBtn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        resetBtn.setTitleColor(UIColor.white, for: .normal)
        resetBtn.addTarget(self, action: #selector(lineButtonClickAction(sender:)), for: .touchUpInside)
        self.view.addSubview(resetBtn)
        
        unitBtn = UIButton.init(frame: CGRect.init(x: kViewWidth/2.0, y: kViewHeight-30, width: kViewWidth/2.0, height: 30))
        unitBtn.tag = 2
        unitBtn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        unitBtn.setTitle("切换", for: .normal)
        unitBtn.setTitleColor(UIColor.white, for: .normal)
        unitBtn.addTarget(self, action: #selector(lineButtonClickAction(sender:)), for: .touchUpInside)
        self.view.addSubview(unitBtn)
    }
    
    @objc func lineButtonClickAction(sender:UIButton) {
        if sender.tag == 1 {
            for line in lines{
                line.remove()
            }
            lines.removeAll()
        }else{
            let alertView = UIAlertController.init(title: "提示", message: "修改显示的单位", preferredStyle: .actionSheet)
            let action1 = UIAlertAction.init(title: "米", style: .default, handler: { (action) in
                self.changeUnit(unit: .meter)
            })
            let action2 = UIAlertAction.init(title: "厘米", style: .default, handler: { (action) in
                self.changeUnit(unit: .cenitMeter)
            })
            let action3 = UIAlertAction.init(title: "英寸", style: .default, handler: { (action) in
                self.changeUnit(unit: .inch)
            })
            
            let action4 = UIAlertAction.init(title: "取消", style: .destructive, handler: nil)
            alertView.addAction(action1)
            alertView.addAction(action2)
            alertView.addAction(action3)
            alertView.addAction(action4)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func changeUnit(unit:LengthUnit) {
        self.unit = unit
        for line in self.lines{
            line.unit = unit
            line.text.string = line.distance(to: line.endNode.position)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isMeasuring{
            isMeasuring = false
            if let line = currentLine{
                lines.append(line)
                currentLine = nil
                imageMark.image = UIImage.init(named: "WhiteTarget")
            }
        }else{
            vectorStart = SCNVector3()
            vectorEnd = SCNVector3()
            isMeasuring = true
            imageMark.image = UIImage.init(named: "GreenTarget")
        }
    }
    
    //MARK 添加的使用方法
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.scanWorld()
        }
    }
    
    func scanWorld() {
        //拿到画面中的中心点的位置
        guard let worldPosition = mySenceView.worldVector(for: self.view.center) else {
            return
        }
        //添加划线
        if lines.isEmpty {
            infoLabel.text = "点击画面试试看啊"
        }
        //如果是测量状态
        if isMeasuring {
            //设置开始节点
            if vectorStart == vectorZero{
                vectorStart = worldPosition
                currentLine = Line.init(sceneView: mySenceView, startVector: vectorStart, unit: unit)
            }
            //设置结束节点
            vectorEnd = worldPosition
            currentLine?.updateNode(to: vectorEnd)
            infoLabel.text = currentLine?.distance(to: vectorEnd)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("错误")
        infoLabel.text = "初始化错误"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("结束")
        infoLabel.text = "初始化结束"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("中断")
        infoLabel.text = "初始化中断"
    }
}
