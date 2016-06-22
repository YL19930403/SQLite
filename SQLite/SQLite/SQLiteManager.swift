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
    
    ///自定义一个SQLITE_TRANSIENT 
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self )
    
    //MARK: -预编译
    func batchExecSQL(sql : String , args : CVarArgType...) -> Bool{
        //1.将SQL语句转换为c语言
        let cSQL = sql.cStringUsingEncoding(NSUTF8StringEncoding)!
        //2.预编译SQL语句
        var stmt : COpaquePointer = nil
        if sqlite3_prepare_v2(db, cSQL, -1 , &stmt, nil ) != SQLITE_OK  {
            print("预编译失败")
            sqlite3_finalize(stmt )
            return false
        }
        
        //3.绑定数据
        var index : Int32 = 1
        for objc in args {
            if objc is Int {
                sqlite3_bind_int64(stmt, index, sqlite3_int64(objc as! Int ))
            }else if objc is Double {
                sqlite3_bind_double(stmt , index , objc as! Double)
            }else if objc is String {
                let text = objc as! String
                let cText = text.cStringUsingEncoding(NSUTF8StringEncoding)!
                // 第三个参数: 需要绑定的字符串, C语言
                // 第四个参数: 第三个参数的长度, 传入-1系统自动计算
                // 第五个参数: OC中直接传nil, 但是Swift传入nil会有大问题
                /*
                 typedef void (*sqlite3_destructor_type)(void*);
                 
                 #define SQLITE_STATIC      ((sqlite3_destructor_type)0)
                 #define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)
                 
                 第五个参数如果传入SQLITE_STATIC/nil, 那么系统不会保存需要绑定的数据, 如果需要绑定的数据提前释放了, 那么系统就随便绑定一个值
                 第五个参数如果传入SQLITE_TRANSIENT, 那么系统会对需要绑定的值进行一次copy, 直到绑定成功之后再释放
                 */
                sqlite3_bind_text(stmt , index, cText, -1 , SQLITE_TRANSIENT)
            }
            index++
        }
        //执行SQL语句
        if sqlite3_step(stmt) != SQLITE_DONE{
            print("执行SQL语句失败")
            return false
        }
        
        
        //重置STMT
        // 5.重置STMT
        if sqlite3_reset(stmt) != SQLITE_OK
        {
            print("重置失败")
            return false
        }
        // 6.关闭STMT
        // 注意点: 只要用到了stmt, 一定要关闭
        sqlite3_finalize(stmt)
        return true 
    }
    
    //MARK: 事务
    // 1.开启事务
    func beginTransaction()
    {
        exexSQL("BEGIN TRANSACTION")
    }
    // 2.提交事务
    func commitTransaction()
    {
        exexSQL("COMMIT TRANSACTION")
    }
    // 3.回滚
    func rollbackTransaction()
    {
        exexSQL("ROLLBACK TRANSACTION")
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
    
    /**
        查询所有的数据
     returns : 查询到的字典数组
     */
    func execRecordSQL(sql : String) -> [[String : AnyObject]]{
        //1.将Swift字符串转换为C语言字符串
        let cSQL = sql.cStringUsingEncoding(NSUTF8StringEncoding)!
        //2.准备数据
        /*
            预编译SQL语句, 检测里面是否有错误等等, 它可以提供性能优化
         */
        
        /*
            param1 : 已经打开的数据库对象
            param2 : 需要执行的SQL语句
            param3 : 需要执行的SQL语句的长度， 传入-1系统自动计算
            param4 : 预编译之后的句柄，要取出数据就需要这个句柄
            param5 : 一般传nil
         
         */
        var stmt : COpaquePointer = nil
        if (sqlite3_prepare_v2(db, cSQL, -1, &stmt , nil ) != SQLITE_OK ){
            print("准备失败")
        }
        //准备成功
        var records = [[String : AnyObject]]()
        
        //3.查询数据
        // sqlite3_step代表取出一条数据, 如果取到了数据就会返回SQLITE_ROW
        while ( sqlite3_step(stmt) == SQLITE_ROW ) {
            //获取一条记录
            let record =  recordWithStmt(stmt)
            //将当前获取到的这条记录添加到数组中
            records.append(record)
        }
        //4.关闭STMT（必须要关闭）
        sqlite3_finalize(stmt)
        return records
    }
    
    /**
     获取一条记录的值
     
     :param: stmt 预编译好的SQL语句
     
     :returns: 字典
     */
    func recordWithStmt(stmt : COpaquePointer) -> [String : AnyObject]{
        //拿到当前这条数据所有的列
        let count = sqlite3_column_count(stmt)
        
        //定义字典，存储查询到的数据
        var record = [String : AnyObject]()
        
        for index in 0..<count{
            //拿到每一列的名称
            let cName = sqlite3_column_name(stmt, index)
            let name = String(CString: cName, encoding: NSUTF8StringEncoding)
            
            //拿到每一列的类型 SQLITE_INTEGER
            let type = sqlite3_column_type(stmt, index)
            
            switch type  {
            case SQLITE_INTEGER:
                //整型
                let num = sqlite3_column_int64(stmt, index)
                record[name!] = Int(num)
                
            case SQLITE_FLOAT:
                // 浮点型
                let double = sqlite3_column_double(stmt, index)
                record[name!] = Double(double)
            case SQLITE3_TEXT:
                // 文本类型
                let cText = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
                let text = NSString(CString: cText, encoding: NSUTF8StringEncoding)!
                record[name!] = text
            case SQLITE_NULL:
                // 空类型
                record[name!] = NSNull()
            default:
                // 二进制类型 SQLITE_BLOB
                // 一般情况下, 不会往数据库中存储二进制数据
                print("")
            }
        }
        return record
    }

}












































