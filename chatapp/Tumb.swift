//
//  Tumb.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import AudioUnit
import AudioToolbox

class Tumb: UIViewController {
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    let touchMe = BiometricIDAuth()
    var db : Firestore!
    var activeUser:User!
    let user_id = Auth.auth().currentUser?.uid
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   self.isModalInPresentation = true
               }
        self.myActivityIndicator.isHidden = true
        startAnimate()
        // Do any additional setup after loading the view.
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            self.touchId((Any).self)
        }
        stopAnimate()
    }
    @IBAction func touchIdAgain(_ sender: Any) {
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            self.touchId((Any).self)
        }
    }
    @IBAction func touchId(_ sender: Any) {
        startAnimate()
        touchMe.authenticateUser() { [weak self] message in
            if let message = message {
                if message == "You pressed password." {
                   
                    let myVC = self?.storyboard?.instantiateViewController(withIdentifier: "Verificationpage") as! Verificationpage
                        self!.present(myVC,animated: true,completion: nil)
                        self!.stopAnimate()
                              
                }
                else {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Done", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
                self?.stopAnimate()
                }
            }
            else
            {
                Auth.auth().addStateDidChangeListener() { auth, user in
                    if user != nil {
                        _ = user?.uid
                        self?.auth()
                    }
                    else
                    {
                         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        let alertController = UIAlertController(title: "Error", message: "Please enter Details", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self?.present(alertController, animated: true, completion: nil)
                        self!.stopAnimate()
                    }
                }
            }
        }
    }
    func auth(){
        Auth.auth().addStateDidChangeListener() { auth, user in
            if let user = user {
                if(self.activeUser != user){
                    self.activeUser = user
                    self.startAnimate()
                    let ref = Firestore.firestore().collection("UserProfile").document(self.user_id!)
                    ref.getDocument() { (docSnapshot, err) in
                        if let err=err {
                            print("Error getting documents: \(err)")
                            self.stopAnimate()
                        } else {
                            let docSnapshot = docSnapshot
                            if (docSnapshot?.exists)!
                            {
                               
                           
                                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                                          self.present(myVC,animated: true,completion: nil)
                                                          self.stopAnimate()
                                                       
                                                    
                                                    }
                                         
                            else
                            {
                                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
                                self.present(myVC,animated: true,completion: nil)
                                self.stopAnimate()
                            }
                        }
                    }
                }
            }
        }
    }
 
  
    @IBAction func EnterPassword(_ sender: Any) {
        startAnimate()
        
         
                let myVC = storyboard?.instantiateViewController(withIdentifier: "Verificationpage") as! Verificationpage
                self.present(myVC,animated: true,completion: nil)
                stopAnimate()
           
       
    }
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-180, width:  self.view.frame.size.width, height: 50))
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 20.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    func startAnimate() {
        //UIApplication.shared.beginIgnoringInteractionEvents()
        self.view.isUserInteractionEnabled = false
        self.myActivityIndicator.isHidden = false
        self.myActivityIndicator.startAnimating()
    }
    
    func stopAnimate() {
        //UIApplication.shared.endIgnoringInteractionEvents()
        self.view.isUserInteractionEnabled = true
        self.myActivityIndicator.isHidden = true
        self.myActivityIndicator.stopAnimating()
    }
}
