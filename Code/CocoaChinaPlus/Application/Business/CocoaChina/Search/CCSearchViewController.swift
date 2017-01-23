//
//  CCAboutViewController.swift
//  CocoaChinaPlus
//
//  Created by zixun on 15/10/3.
//  Copyright © 2015年 zixun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class CCSearchViewController: CCArticleTableViewController {
    //搜索条
    fileprivate var searchfiled:UISearchBar!
    //取消按钮
    fileprivate var cancelButton:UIButton!
    //RxSwift资源回收包
    fileprivate let disposeBag = DisposeBag()
    
    
    required init(navigatorURL URL: Foundation.URL, query: Dictionary<String, String>) {
        super.init(navigatorURL: URL, query: query)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(navigatorURL URL: NSURL, query: Dictionary<String, String>) {
        fatalError("init(navigatorURL:query:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        self.cancelButton.setImage(R.image.nav_cancel, for: UIControlState())
        self.navigationItem.rightBarButtonItemFixedSpace(UIBarButtonItem(customView: cancelButton))
        
        self.searchfiled = UISearchBar()
        self.searchfiled.placeholder = "关键字必需大于2个字符哦"
        self.navigationItem.titleView = self.searchfiled
        
        
        self.subscribes()
    }
    
    fileprivate func subscribes() {
        //取消按钮点击Observable
        self.cancelButton.rx_tap
            .subscribeNext { [weak self] x in
                guard let sself = self else {
                    return
                }
                sself.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        //tableView滚动偏移量Observable
        self.tableView.rx_contentOffset
            .subscribe { [weak self]  _ in
                
                guard let control = self else {
                    return
                }
                
                if control.searchfiled.isFirstResponder() {
                    _ = control.searchfiled.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
        
        
        //搜索框搜索按钮点击Observable
        self.searchfiled.rx_delegate
            .observe("searchBarSearchButtonClicked:")
            .map { [weak self] (field) -> PublishSubject<[CCArticleModel]>  in
                guard let sself = self else {
                    return PublishSubject<[CCArticleModel]>()
                }
                
                sself.tableView.clean()
                return CCHTMLModelHandler.sharedHandler
                    .handleSearchPage(sself.searchfiled.text!, loadNextPageTrigger: sself.loadNextPageTrigger)
                }
            .switchLatest()
            .subscribeNext { [weak self] (models) -> Void in
                guard let sself = self else {
                    return
                }
                
                sself.tableView.append(models)
                sself.tableView.infiniteScrollingView.stopAnimating()
            }
            .addDisposableTo(disposeBag)
        
    }
}


