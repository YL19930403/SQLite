//
//  SQLiteManager.swift
//  SQLite
//
//  Created by 余亮 on 16/6/21.
//  Copyright © 2016年 余亮. All rights reserved.
//

import UIKit

class SQLiteManager: NSObject {
    private static let manager : SQLiteManager = SQLiteManager()
    
    class func shareManager() -> SQLiteManager {
        return manager
    }
    
    //数据库对象
    private var db : COpaquePointer = nil
    
    //创建一个串行队列
    private let dbQueue = dispatch_queue_create("yuliang", DISPATCH_QUEUE_SERIAL)
    
    func execQueueSQL(action : (manager:SQLiteManager) -> ()){
        //1.开启一个子线程
        dispatch_async(dbQueue) { () -> Void in
            //执行闭包
            action(manager: self )
        }
        
       
        
    }
    
    func openDB(SQLiteName : String){
        //1.拿到数据库的路径
        let path = SQLiteName.docDir()
        print(path)
        let cPath = path.cStringUsingEncoding(NSUTF8StringEncoding)!
        //2.打开数据库
         /**
            2.1 需要打开的数据库文件的路径， c语言字符串
            2.2 打开之后的数据库对象（指针），以后所有的数据库操作，都必须拿到这个指针才能进行相关操作
         */
        
        ///open方法 ： 如果要打开的数据库文件存在，则直接打开，如果不存在，则创建一个新的数据库文件
        if sqlite3_open(cPath, &db) != SQLITE_OK {
            print("打开数据库失败")
            return
        }
        //3.创建表
        if createTable() {
            print("创建表成功")
        }else {
            print("创建表失败")
        }
        
    }
    
    
    /**
        创建表
     */
    private func createTable() -> Bool {
        //1.编写SQL语句
        let sql = "CREATE TABLE IF NOT EXISTS T_Person ( \n" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT , \n" +
                    "name TEXT , \n" +
                    "age INTEGER \n" +
                    "); \n"
        return exexSQL(sql)
    }
    
    /**
        执行除查询以外的SQL语句
        param : sql 需要执行的SQL语句
        returns : true 代表执行执行成功    false 代表执行失败
     */
    func exexSQL(sql : String) -> Bool {
        //将Swift字符串转为C语言字符串
        let cSQL =  sql.cStringUsingEncoding(NSUTF8StringEncoding)!
        //注意：在SQLite3中，除了查询以外的SQL语句都使用同一个函数
        /**
            1.已经打开的数据库对象
            2.需要执行的SQL语句，c语言字符串
            3.执行SQL语句之后的回调，一般传nil
            4.第三个参数的第一个参数，一般传nil
            5.错误信息，一般传nil
         */
        if ( sqlite3_exec(db , cSQL, nil , nil , nil ) != SQLITE_OK ){
            return false
        }
        return true
    }
    
}












































