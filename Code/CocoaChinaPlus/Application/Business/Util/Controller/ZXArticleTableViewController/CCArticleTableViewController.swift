//
//  ZXTableViewController.swift
//  CocoaChinaPlus
//
//  Created by user on 15/11/5.
//  Copyright © 2015年 zixun. All rights reserved.
//

import UIKit
import RxSwift
//import GoogleMobileAds

class CCArticleTableViewController: ZXBaseViewController {//GADBannerViewDelegate

    //RxSwift资源回收包
    fileprivate let disposeBag = DisposeBag()
    
    //文章列表
    var tableView : CCArticleTableView!
    
    //加载下一页触发器
    let loadNextPageTrigger = PublishSubject<Void>()
    
    
    required init(navigatorURL URL: Foundation.URL, query: Dictionary<String, String>) {
        super.init(navigatorURL: URL, query: query)
        
        //tableview 配置
        let forceHighlight = query["forceHighlight"] == "1" ? true : false
        self.tableView = CCArticleTableView(forceHighlight: forceHighlight)
        
        //广告配置
        let adposStr = query["adpos"]
        if (adposStr != nil && Int(adposStr!) != nil) {
            if adposStr! == "1" {
                self.adPosition = CCADBannerViewType.search
            }
        }
        if self.adPosition == CCADBannerViewType.search {
            print("invoke");
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.frame = self.view.bounds
        self.view.addSubview(self.tableView)
        
        //上拉加载
        self.tableView.addInfiniteScrolling { [weak self] () -> Void in
            guard let sself = self else {
                return
            }
            sself.loadNextPageTrigger.on(.next())
        }
        self.tableView.infiniteScrollingView.activityIndicatorViewStyle = .white
        
        //tableview行点击Observable
        self.tableView.selectSubject
            .subscribeNext {[weak self] (model) -> Void in
                guard let sself = self else {
                    return
                }
                
                sself.dismissViewControllerAnimated(true, completion: nil)
                var param = Dictionary<String,String>()
                param["identity"] = model.identity
                ZXOpenURL("go/ccp/article", param:param)
            }
            .addDisposableTo(disposeBag)
        
        if (self.adPosition != nil) {
            self.adView = CCADBanner(type: CCADBannerViewType.Search, rootViewController: self, completionBlock: { (succeed:Bool, errorInfo:[AnyHashable: Any]!) -> Void in
                
                if succeed {
                    var rect = self.view.bounds
                    rect.size.height -= 50
                    self.tableView.frame = rect
                }else {
                    self.tableView.frame = self.view.bounds
                }
                
            });
            
            self.view.addSubview(self.adView!);
            self.adView!.anchorAndFillEdge(.Bottom, xPad: 0, yPad: 0, otherSize:48)
        }
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.adView?.anchorAndFillEdge(.Bottom, xPad: 0, yPad: 0, otherSize:48)
    }
}
