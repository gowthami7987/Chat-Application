//
//  ViewController.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import ObjectMapper
import AudioToolbox
import AudioUnit

class delver: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class delvery : Mappable {


    var name1 : String = ""
    var num : String = ""
 var Id: String?

required init?(map: Map) {}

func mapping(map: Map) {
   
    
    self.name1                  <- map["Name"]
    self.num                  <- map["MobileNumber"]
}
    func setId(Id:String){
          self.Id = Id
      }
    
}
class ViewController: UIViewController {

    @IBOutlet weak var prepaid: UITableView!
     let user_id = Auth.auth().currentUser?.uid
    var allusers = [delvery]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }

        prepaid.tableFooterView = UIView()
       Firestore.firestore().collection("UserProfile")
       .addSnapshotListener { (documents, error) in
        DispatchQueue.main.async {
        guard (error == nil) else {
            print("Error getting documents:")
            return
        }

           self.allusers.removeAll()
           for document in documents!.documents {
               let myData = document.data()
       
            if self.user_id != document.documentID {
                let obj: delvery = Mapper<delvery>().map(JSONObject: document.data())!
             
                obj.setId(Id: document.documentID)
               self.allusers.append(obj)
               self.prepaid.reloadData()
             
              
            }
           }

           }
       }
        
    }
    
}
    


extension ViewController: UITableViewDataSource, UITableViewDelegate  {
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return self.allusers.count
   
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
    let cell = tableView.dequeueReusableCell(withIdentifier: "delver") as! delver
    if allusers.count > indexPath.row {
    let orders =  self.allusers[indexPath.row]
        cell.name.text = orders.name1
        cell.number.text = orders.num
    }
    return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    let candid = self.allusers[indexPath.row]
    
    let chatlogcontroller = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    
    chatlogcontroller.selectid = candid.Id!
    
    let navigationController = UINavigationController(rootViewController: chatlogcontroller)
     navigationController.modalPresentationStyle = .fullScreen
    print("vxz,nvmnvzm")
   self.present(navigationController, animated: true, completion: nil)
 //self.navigationController?.pushViewController(navigationController,animated: true)
    
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}

