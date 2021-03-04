//
//  InitializeController.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase

class InitializeController: UIViewController {

  
    var handle:AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   self.isModalInPresentation = true
               }
        // Do any additional setup after loading the view.
        
             
                  
                   // Do any additional setup after loading the view.
                      self.handle = Auth.auth().addStateDidChangeListener() { auth , user in
                          if user != nil
                          {
                              if let user_id = Auth.auth().currentUser?.uid{
                                  let ref = Firestore.firestore().collection("UserProfile").document(user_id)
                                  ref.getDocument() { (docSnapShot,err) in
                                      if let err = err{
                                          print("Error getting documents: \(err)")
                                      }
                                      else
                                      {
                                          let docSnapShot = docSnapShot
                                          if (docSnapShot?.exists)!
                                          {
                                              let key = docSnapShot?.data()! ["Key"] as? String ?? ""

                                              if key == ""
                                              {
                                                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
                                                  self.present(vc,animated: true,completion: nil)
                                              }
                                              else
                                              {
                                                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "Tumb") as! Tumb
                                                  self.present(vc,animated: true,completion: nil)
                                              }
                                          }
                                          else
                                          {
                                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
                                              self.present(vc,animated: true,completion: nil)
                                              
                                          }
                                      }
                                  }
                              }
                              else{
                                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
                                  self.present(vc,animated: true,completion: nil)
                              }
                          }
                          else{
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
                              self.present(vc,animated: true,completion: nil)
                          }
                      }
               
    }
    
}

