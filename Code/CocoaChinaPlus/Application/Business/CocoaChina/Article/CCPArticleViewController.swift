//
//  CCPArticleViewController.swift
//  CocoaChinaPlus
//
//  Created by 子循 on 15/7/23.
//  Copyright © 2015年 zixun. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import MBProgressHUD
import RxSwift
import SwViewCapture

enum CCPArticleViewType {
    case blog
    case bbs
}

class CCPArticleViewController: ZXBaseViewController {

    fileprivate var webview:CCCocoaChinaWebView!
    fileprivate var cuteView:ZXCuteView!
    //文章的wap链接
    fileprivate var wapURL : String!
    //文章的identity
    fileprivate var identity : String!
    
    fileprivate var type : CCPArticleViewType!
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var semaphore = DispatchSemaphore(value: 0)
    
    required init(navigatorURL URL: URL?, query: Dictionary<String, String>) {
        super.init(navigatorURL: URL, query: query)
        
        if query["identity"] != nil {
            self.identity = query["identity"]
            self.wapURL = CCURLHelper.generateWapURL(query["identity"]!)
            self.type = .blog
        }else if query["link"] != nil {
            self.wapURL = query["link"]
            self.type = .bbs
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview = CCCocoaChinaWebView(frame: self.view.bounds)
        self.view.addSubview(self.webview)
        self.open(wapURL)
        //cuteview逻辑
        self.cuteViewHandle()
        
        //RightBarButtonItems逻辑
        if self.type == .blog {
            self.addRightBarButtonItems()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cuteView.removeFromSuperview()
    }
    
    func open(_ urlString:String) {
        let url = URL(string: urlString)!

        if url.host == "www.cocoachina.com" {
            self.webview.open(urlString)
        }else if url.host == "objccn.io" || url.host == "www.objccn.io" {
            self.webview.loadRequest( URLRequest(url: url))
        }
    }
}

// MARK: Private
extension CCPArticleViewController {
    
    fileprivate func addRightBarButtonItems() {
        let image = self._isLiked() ? R.image.nav_like_yes() : R.image.nav_like_no()
        let likeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        likeButton.setImage(image, for: UIControlState())
        let collectionItem = UIBarButtonItem(customView: likeButton)
        
        let shareButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        shareButton.setImage(R.image.share(), for: UIControlState())
        shareButton.rx.tap.bindNext { [unowned self] _ in
            UMSocialSnsService.presentSnsIconSheetView(self,
                                                       appKey: CCAppKey.appUM,
                                                       shareText: kADText(),
                                                       shareImage: self.webview.image,
                                                       shareToSnsNames: [UMShareToSina,UMShareToWechatSession,
                                                                         UMShareToWechatTimeline,UMShareToWechatFavorite],
                                                       delegate: self)
        }.addDisposableTo(self.disposeBag)
        
        let shareItem = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItemsFixedSpace(items: [collectionItem,shareItem])
        
        likeButton.rx.tap.bindNext { [unowned self] _ in
            if self._isLiked() {
                
                let result = CCArticleService.decollectArticleById(self.identity)
                if result {
                    MBProgressHUD.showText("取消成功")
                    likeButton.setImage(R.image.nav_like_no(), for: UIControlState.normal)
                }else {
                    MBProgressHUD.showText("取消失败")
                }
            }else {
                if !CCArticleService.isArticleExsitById(self.identity) {
                    //如果文章不存在，说明是push之类的进来的
                    let model = CCArticleModel()
                    model.identity = self.identity
                    model.title = self.webview.title
                    model.imageURL = self.webview.imageURL
                    
                    CCArticleService.insertArtice(model)
                }
                let result = CCArticleService.collectArticleById(self.identity)
                
                if result {
                    MBProgressHUD.showText("收藏成功")
                    likeButton.setImage(R.image.nav_like_yes(), for: UIControlState.normal)
                }else {
                    MBProgressHUD.showText("收藏失败")
                }
            }
            
            
            let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.3
            scaleAnimation.values = [1.0,1.2,1.0]
            scaleAnimation.keyTimes = [0.0,0.5,1.0]
            scaleAnimation.isRemovedOnCompletion = true
            scaleAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
            likeButton.layer.add(scaleAnimation, forKey: "likeButtonscale")
        }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func cuteViewHandle() {
        let point = CGPoint(x: self.view.xMax - 50, y: self.view.yMax - 150)
        self.cuteView = ZXCuteView(point: point, superView: self.view, bubbleWidth: 40)
        self.cuteView.tapCallBack = {[weak self] () -> Void  in
            if let sself = self {
                sself._addAnimationForBackTop()
            }
        }
    }
    
    /**
    文章是否已经标记为收藏
    
    - returns: 是否收藏
    */
    fileprivate func _isLiked() ->Bool {
        return CCArticleService.isArticleCollectioned(self.identity)
    }
    
    fileprivate func _addAnimationForBackTop() {
        //将webview置顶
        for subview in self.webview.subviews {
            if subview.isKind(of: UIScrollView.self) {
                (subview as! UIScrollView).setContentOffset(CGPoint.zero, animated: true)
            }
        }
        
        //置顶动画
        self.cuteView.removeAniamtionLikeGameCenterBubble()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.cuteView.frontView?.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            self.cuteView.frontView?.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.cuteView.frontView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.cuteView.frontView?.alpha = 1.0
                self.cuteView.addAniamtionLikeGameCenterBubble()
        })
    }
}

extension CCPArticleViewController : UMSocialUIDelegate {
    
    /**
    自定义关闭授权页面事件
    
    @param navigationCtroller 关闭当前页面的navigationCtroller对象
    
    */
    
    func closeOauthWebViewController(_ navigationCtroller: UINavigationController!, socialControllerService: UMSocialControllerService!) -> Bool {
        print("自定义关闭授权页面事件");
        return true;
    }
    
    
    /**
    关闭当前页面之后
    
    @param fromViewControllerType 关闭的页面类型
    
    */
    
    func didCloseUIViewController(_ fromViewControllerType: UMSViewControllerType) {
        print("关闭当前页面之后")
    }
    
    
    /**
    各个页面执行授权完成、分享完成、或者评论完成时的回调函数
    
    @param response 返回`UMSocialResponseEntity`对象，`UMSocialResponseEntity`里面的viewControllerType属性可以获得页面类型
    */
    
    func didFinishGetUMSocialData(inViewController response: UMSocialResponseEntity!) {
        print("各个页面执行授权完成、分享完成、或者评论完成时的回调函数")
        
        //根据`responseCode`得到发送结果,如果分享成功
        if(response.responseCode == UMSResponseCodeSuccess)
        {
            //得到分享到的微博平台名
            
            print("share to sns name is \((response.data as NSDictionary).allKeys.first!)")
        }
        
    }
    
    /**
    点击分享列表页面，之后的回调方法，你可以通过判断不同的分享平台，来设置分享内容。
    @param platformName 点击分享平台
    @prarm socialData   分享内容
    */
    func didSelectSocialPlatform(_ platformName: String!, with socialData: UMSocialData!) {
        
        let config : UMSocialExtConfig = socialData.extConfig
        print("点击分享列表页面，之后的回调方法，你可以通过判断不同的分享平台，来设置分享内容。")
        if platformName == UMShareToSina {
            print("分享到新浪")
            //设置微博分享参数
            self.webview.scrollView.swContentCapture({ [unowned self] (image:UIImage?) in
                config.sinaData.shareImage = image
                config.sinaData.shareText = self.webview.title + " " + self.wapURL
                self.semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }else if platformName == UMShareToWechatTimeline {
            print("分享到微信朋友圈")
            //设置微信朋友圈分享参数
            config.wechatTimelineData.title = self.webview.title
            config.wechatTimelineData.shareText = kADText()
            config.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb
            config.wechatTimelineData.url = self.wapURL
        }else if platformName == UMShareToWechatSession {
            print("分享到微信好友")
            //设置微信好友分享参数
            config.wechatSessionData.title = self.webview.title
            config.wechatSessionData.shareText = kADText()
            config.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb
            config.wechatSessionData.url = self.wapURL
        }else if platformName == UMShareToWechatFavorite {
            print("分享到微信收藏")
            //设置微信收藏分享参数
            config.wechatFavoriteData.title = self.webview.title
            config.wechatFavoriteData.shareText = kADText()
            config.wechatFavoriteData.wxMessageType = UMSocialWXMessageTypeWeb
            config.wechatFavoriteData.url = self.wapURL
        }else {
            print("分享到其他")
        }
    };
}
