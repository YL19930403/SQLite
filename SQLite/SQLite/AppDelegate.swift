//
//  AppDelegate.swift
//  SQLite
//
//  Created by 余亮 on 16/6/21.
//  Copyright © 2016年 余亮. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SQLiteManager.shareManager().openDB("yuliang.sqlite")
        return true
    }

}










