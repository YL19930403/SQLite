//
//  Person.swift
//  SQLite
//
//  Created by 余亮 on 16/6/22.
//  Copyright © 2016年 余亮. All rights reserved.
//

import UIKit

class Person: NSObject {
    var id : Int = 0
    var age : Int = 0
    var name : String?
    
    //MARK: - 执行数据源CRUD的操作
    /**
        插入一条数据
     */
    func insertQueuePerson(){
        ///断言，保证name必须有值，否则就会崩溃
        assert(name != nil , "必须要给name赋值")
        SQLiteManager.shareManager().execQueueSQL { (manager) -> ()in
            //1.编写SQL语句
            let sql = "INSERT INTO T_Person \n" +
                      "(name , age)  \n" +
                      "VALUES \n" +
                      "('\(self.name!)' , \(self.age)); "
            //2.执行SQL语句
            manager.exexSQL(sql)
            
        }
    }
    
    
    /**
     删除记录
     */
    func deletePerson() -> Bool{
        //1.编写SQL语句
        let sql = "DELETE FROM T_Person WHERE age IS \(self.age);"
        
        //2.执行SQL语句
        return SQLiteManager.shareManager().exexSQL(sql)
    }
    
    /**
        更新
     */
    func updatePerson(name : String) -> Bool {
        let sql = "UPDATE T_Person SET name = '\(name)' WHERE age = \(self.age);"
        return SQLiteManager.shareManager().exexSQL(sql)
    }
    
    /**
        插入一条记录
     */
    func insertPerson() -> Bool{
        assert(name != nil , "必须要给name赋值")
        let sql = "INSERT INTO T_Person" +
                  "(name , age )" +
                  "VALUES" +
                  "('\(name!)' , \(age));"
        return SQLiteManager.shareManager().exexSQL(sql)
    }
    
     init(dict : [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    override var description : String {
        return "id = \(id) , age = \(age) , name = \(name)"
    }
    
}





















































