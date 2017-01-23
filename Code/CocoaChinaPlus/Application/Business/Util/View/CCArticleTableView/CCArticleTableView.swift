//
//  CCArticleTableView.swift
//  CocoaChinaPlus
//
//  Created by user on 15/10/28.
//  Copyright © 2015年 zixun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MBProgressHUD
import ZXKit


class CCArticleTableView: UITableView,UITableViewDelegate {

    /// cell是否一直高亮
    var forceHighlight:Bool = false
    
    //Cell选中Observable
    var selectSubject = PublishSubject<CCArticleModel>()
    
    //RxSwift资源回收包
    fileprivate let disposeBag = DisposeBag()
    //文章数组Variable
    fileprivate let articles = Variable([CCArticleModel]())
    //数据源
    fileprivate let tableViewDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CCArticleModel>>()
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.backgroundColor = ZXColor(0x000000, alpha: 0.8)
        self.separatorStyle  = .none

        self.subscribes()
    }
    
    convenience init(forceHighlight:Bool) {
        self.init(frame:CGRect.zero,style:.plain)
        self.forceHighlight = forceHighlight
    }
    
    /**
     添加一组文章model到tableview，并reload
     
     - parameter models: 一组文章model
     */
    func append(_ models:[CCArticleModel]) {
        if models.count == 0 {
            if self.articles.value.count == 0 {
                MBProgressHUD.showText("没找到...")
            }else {
                MBProgressHUD.showText("没有了...")
            }
        }
        self.articles.value += models
    }
    
    /**
     清空数据
     */
    func clean() {
        self.articles.value = [CCArticleModel]()
    }
    
    /**
     重新加载
     */
    func reload(_ models:[CCArticleModel]) {
        self.clean()
        self.append(models)
    }
    
    /**
     tableview是否没有数据
     */
    func isEmpty() -> Bool {
        return self.articles.value.count == 0 ? true : false
    }
    
    
    fileprivate func subscribes() {
        //代理设置
        self.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
        
        //TableViewCell设置
        tableViewDataSource.cellFactory = {[unowned self] (tv, ip, model: CCArticleModel) in
            var cell = tv.dequeueReusableCell(withIdentifier: "CCArticleTableViewCell")
            if cell == nil {
                cell = CCArticleTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CCArticleTableViewCell")
            }
            (cell! as! CCArticleTableViewCell).configure(model, forceHighlight: self.forceHighlight)
            return cell!
        }
        
        //tableView中Cell点击Observable
        self.rx_itemSelected
            .subscribeNext {[weak self] (indexPath:IndexPath) -> Void in
                guard let sself = self else {
                    return
                }
                sself.deselectRowAtIndexPath(indexPath, animated: true)
                
                let article = sself.articles.value[indexPath.row]
                
                if !CCArticleService.isArticleExsitById(article.identity) {
                    CCArticleService.insertArtice(article)
                }
                
                let cell = sself.cellForRowAtIndexPath(indexPath) as! CCArticleTableViewCell
                cell.highlightCell(false)
                
                sself.selectSubject.on(.Next(article))
            }
            .addDisposableTo(disposeBag)
        
        //数据源绑定
        self.articles
            .asDriver()
            .map {
                [SectionModel(model: "Repositories", items: $0)]
            }
            .drive(self.rx_itemsWithDataSource(tableViewDataSource))
            .addDisposableTo(self.disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
