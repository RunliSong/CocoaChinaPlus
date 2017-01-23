//
//  ZXMarkdownView.swift
//  CocoaChinaPlus
//
//  Created by 子循 on 15/6/12.
//  Copyright © 2015年 zixun. All rights reserved.
//

import Foundation
import UIKit
import Ji
import Kingfisher
import ZXKit

class CCCocoaChinaWebView: ZXHighlightWebView {
    
    var title : String!
    var image = R.image.sharetest
    var imageURL : String!
    
    fileprivate let styleString = "<link type='text/css' rel='stylesheet' href='ccstyle.css'>" +
                              "<script src='jquery-1.6.4.min.js'></script>"
    
    

    func open(_ urlString:String) {
        self.hud.show(true)
        CCRequest(.GET, urlString)
            .response {[weak self] (request, response, data, error) -> Void in
            
                guard let sself = self else {
                    return
                }
                
                guard error == nil else {
                    println(error)
                    return
                }
                
                let str = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                sself.loadCocoaChinaString(str)
            }
    }
}

//MARK: - Private
extension CCCocoaChinaWebView {
    
    fileprivate func loadCocoaChinaString(_ string:NSString) {
        let str = _generateNewHTML(string)
        _handleNote(str as String)
        self.loadHTMLString(str as String)
    }
    
    fileprivate func _handleNote(_ html:String) {
        let ji = Ji(htmlString: html)!
        let titleNode = ji.xPath("//div[@class='detailtitle']/h6")!.first!
        self.title = titleNode.content
        
        guard (ji.xPath("//img")?.count)! > 0 else {
            self.image = R.image.sharetest
            return
        }
        let imageNode = ji.xPath("//img")!.first!
        self.imageURL = imageNode.attributes["src"]!
        let downloader = KingfisherManager.sharedManager.downloader
        downloader.downloadImageWithURL(URL(string: imageURL)!, progressBlock: nil, completionHandler: { [weak self] (image, error, imageURL, originalData) -> () in
            
            if let sself = self,let image = image {
                dispatch_async(dispatch_get_main_queue(), {
                    sself.image = image
                })
            }
        })
    }
    
    fileprivate func _generateNewHTML(_ originHTML:NSString) -> NSString {
        var str = originHTML
        //删除CocoaChina的Head
        str = str.stringByDeletingScopeString("<header>", end: "</header>")
        //baseURL为本地，所以网络资源需要加前缀
        str = str.stringByInsertString("http://www.cocoachina.com", beforeOccurrencesOfString: "/cms/plus/count.php")
        //影响代码着色 删除
        str = str.replacingOccurrences(of: "<pre class=\"brush:js;toolbar:false\">", with:"<pre><code>") as NSString
        //删除无用的网络资源请求
        str = str.stringByDeletingOccurrencesOfString("<link href=\"/cms/templets/wap/style/style.css?1113\" rel=\"stylesheet\" type=\"text/css\">")
        str = str.stringByDeletingOccurrencesOfString("<script src=\"http://code.jquery.com/jquery-1.6.4.min.js\"></script>")
        //去除cocoachina自带广告
        str = str.stringByDeletingScopeString("</footer>", end: "</body>")
        //替换写在HTML中的样式
        str = str.replacingOccurrences(of: "rgb(248, 248, 248)", with: "rgba(248, 248, 248, 0.5)") as NSString
        //添加本地资源
        str = str.stringByInsertString(self.styleString, beforeOccurrencesOfString: "</head>")
        
        return str
    }
}
