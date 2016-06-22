//
//  ViewController.swift
//  SQLite
//
//  Created by 余亮 on 16/6/21.
//  Copyright © 2016年 余亮. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let p = Person(dict:["name" : "yuliang" , "age" : 100])
//        print(p.insertPerson())
//        print(p.updatePerson("zhangli"))
        //        print(p.deletePerson())
        //        let models = Person.loadPersons()
        //        print(models)
        //        p.insertQueuePerson()
        
        
        let start = CFAbsoluteTimeGetCurrent()
        let manager = SQLiteManager.shareManager()
        //开启事务
        manager.beginTransaction()
        for i in 0..<10000{
            let sql = "INSERT INTO T_Person" +
                "(name, age)" +
                "VALUES" +
            "(?, ?);"
            
            manager.batchExecSQL(sql , args:  "yy +\(i)", 1 + i)
            
        }
        //提交事务
        manager.commitTransaction()
        print("耗时 = \(CFAbsoluteTimeGetCurrent() - start)")
    }

}

















































