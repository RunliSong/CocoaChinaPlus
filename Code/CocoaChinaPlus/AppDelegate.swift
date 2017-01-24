//
//  AppDelegate.swift
//  CocoaChina+
//
//  Created by zixun on 15/8/11.
//  Copyright © 2015年 zixun. All rights reserved.
//

import UIKit
import RxSwift
import Neon

func ZXScreenWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func ZXScreenHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let tabbarController = ZXTabBarController()
    
    fileprivate var webview:UIWebView?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        //各种平台配置
        CCAppConfiguration.configure(application, launchOptions: launchOptions)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            window.backgroundColor = UIColor.black
            window.rootViewController = self.tabbarController
            window.makeKeyAndVisible()
        }

        //UINavigationBar设置
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.black
        
        //statusBar设置
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        //删除一个星期前阅读过的未收藏的文章
        CCArticleService.cleanMouthAgo()
        
        
        
        //模拟器模拟自动登录
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let str = "simulator" as NSString
            
        #endif
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        APService.handleRemoteNotification(userInfo)
        CCRemoteNotificationHandler.sharedHandler.handle(userInfo as NSDictionary)
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    // App进入后台
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // App将要从后台返回
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    // 申请处理时间
    func applicationWillTerminate(_ application: UIApplication) {
    }
    

    
    //分享跳转相关
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return UMSocialSnsService.handleOpen(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return UMSocialSnsService.handleOpen(url)
    }
}

