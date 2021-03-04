//
//  Message.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import ObjectMapper

class Message: Mappable {
    
    var SenderId: String?
    var Text: String?
    var Time2: NSObject?
    var ToId: String?
    var ImageURL: String?
    var docid:String?
    var urilink: String?
    
    required init?(map:Map){}
    
    func mapping(map: Map){
        self.SenderId  <- map["SenderId"]
        self.Text <- map["message"]
        self.Time2 <- map["Time"]
        self.ToId  <- map["ToId"]
        self.ImageURL <- map["ImageURL"]
         self.urilink <- map["urilink"]
    }
    
    func setId(Id:String){
        self.docid = Id
    }
    
    var Time1 : String {
        if Time2 == nil{
            return ""
        }
        else{
            let asd = Time2 as! Timestamp
            let dater = asd.dateValue()
            let date0 = dater
            return String(describing: date0)
        }
    }
}

