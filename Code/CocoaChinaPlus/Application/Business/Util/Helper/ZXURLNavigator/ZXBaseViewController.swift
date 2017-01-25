//
//  UIViewController+Navigator.swift
//  CocoaChinaPlus
//
//  Created by 子循 on 15/7/5.
//  Copyright © 2015年 zixun. All rights reserved.
//

import Foundation
import UIKit

class ZXBaseViewController: UIViewController{
    
    var navURL: URL?
    var navQuery = Dictionary<String,String>()
    
    convenience init(){
        self.init(navigatorURL: nil, query: Dictionary<String, String>())
    }
    
    required init(navigatorURL URL: URL?,query:Dictionary<String,String>) {
        self.navURL = URL
        self.navQuery = query
        super.init(nibName: nil, bundle: nil)
        
//        self.edgesForExtendedLayout = UIRectEdge.None
        //这里不能调用下面的代码，会导致init方法去load视图，然后调用viewDidLoad(),导致viewDidLoad()提前调用，打乱生命周期（比如视图还没有push，就已经load到了内存准备显示了）
//        self.view.backgroundColor = UIColor.blackColor()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    deinit {
        print("\(self.classForCoder)已正常释放!")
    }
}
