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
        let p = Person(dict:["name" : "yuliang" , "age" : 100])
        print(p.insertPerson())
        print(p.updatePerson("zhangli"))
        //        print(p.deletePerson())
        //        let models = Person.loadPersons()
        //        print(models)
        //        p.insertQueuePerson()
    }

}

















































