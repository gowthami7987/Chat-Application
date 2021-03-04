import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import AudioUnit
import AudioToolbox


class Verificationpage: UIViewController {
    
    //let touchMe = BiometricIDAuth()
    var db : Firestore!
    var activeUser:User!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textfielding: UITextField!
    @IBAction func enter(_ sender: UIButton) {
        
        startAnimate()
        
        if textfielding.text == ""{
            
            stopAnimate()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            textfielding.layer.borderColor = UIColor.red.cgColor
            textfielding.layer.borderWidth = 1.0
        }
        else{
            if let user_id = Auth.auth().currentUser?.uid
            {
                Firestore.firestore().collection("UserProfile").document(user_id).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let key = document.data()!["Key"] as? String ?? ""
                        if key == self.textfielding.text{
                            
                           
                            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                                   self.present(myVC,animated: true,completion: nil)
                                                   self.stopAnimate()
                                                   }
                                           
                          
                        else
                        {
                            self.stopAnimate()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.textfielding.layer.borderColor = UIColor.red.cgColor
                            self.textfielding.layer.borderWidth = 1.0
                        }
                    }
                    else
                    {
                        self.stopAnimate()
                    }
                }
            }
            else{
                stopAnimate()
            }
        }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   self.isModalInPresentation = true
               }
        // Do any additional setup after loading the view.
        self.myActivityIndicator.isHidden = true
        self.title = "Verification Page"
        textfielding.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textfielding.frame.height))
        textfielding.leftViewMode = .always
        textfielding.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textfielding.layer.borderColor = UIColor.gray.cgColor
        textfielding.layer.borderWidth = 1.0
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        textfielding.layer.borderColor = UIColor.gray.cgColor
        textfielding.layer.borderWidth = 1.0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func show(_ sender: UIButton) {
      
        if textfielding.isSecureTextEntry == true{
            textfielding.isSecureTextEntry = false
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        else{
            textfielding.isSecureTextEntry = true
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
    }
    @IBAction func forgetPin(_ sender: UIButton) {
        
        self.myActivityIndicator.isHidden = false
        self.myActivityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = true
        if let uid = Auth.auth().currentUser?.uid{
            if let phone = Auth.auth().currentUser?.phoneNumber {
                 AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                let alert = UIAlertController(title: "Alert!", message: "Is this your number? \n \(String(describing: phone))", preferredStyle: .alert)
                let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in Firestore.firestore().collection("UserProfile").document(uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let key = document.data()!["Key"] as? String ?? ""
                        
                        if key != ""{
                            Firestore.firestore().collection("UserProfile").document(uid).updateData(["Key" : FieldValue.delete()]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    self.myActivityIndicator.isHidden = true
                                    self.myActivityIndicator.stopAnimating()
                                    self.view.isUserInteractionEnabled = true
                                } else {
                                    PhoneAuthProvider.provider().verifyPhoneNumber(phone,uiDelegate:nil) {
                                        verificationID, error in
                                        if error != nil
                                        {
                                            print("error123456: \(String(describing: error?.localizedDescription))")
                                            self.myActivityIndicator.isHidden = true
                                            self.myActivityIndicator.stopAnimating()
                                            self.view.isUserInteractionEnabled = true
                                        }
                                        else
                                        {
                                            self.myActivityIndicator.isHidden = true
                                            self.myActivityIndicator.stopAnimating()
                                            self.view.isUserInteractionEnabled = true
                                            let defaults = UserDefaults.standard
                                            defaults.set(verificationID, forKey: "authVID")
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTP") as! OTP
                                            vc.text = phone//sending phone number
                                            self.present(vc,animated: true,completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            self.showToast(message : "Security key not found")
                            if (Auth.auth().currentUser != nil) {do {
                                try Auth.auth().signOut()
                               
                                self.myActivityIndicator.isHidden = true
                                self.myActivityIndicator.stopAnimating()
                                self.view.isUserInteractionEnabled = true
                                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth")as! PhoneAuth
                                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = myVC
                            }catch let error as NSError{
                                print("errrrrrr \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    }
                }
                let NO = UIAlertAction(title: "No", style: .default){(UIAlertAction) in
                    if (Auth.auth().currentUser != nil) {do {
                        try Auth.auth().signOut()
                       
                        self.myActivityIndicator.isHidden = true
                        self.myActivityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PhoneAuth")as! PhoneAuth
                        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = myVC
                        self.present(myVC,animated: true,completion: nil)
                    }catch let error as NSError{
                        print("er123 \(error.localizedDescription)")
                        }
                    }
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(NO)
                alert.addAction(cancel)
                self.myActivityIndicator.isHidden = true
                self.myActivityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                self.myActivityIndicator.isHidden = true
                self.myActivityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                 AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                let alert = UIAlertController(title: "Phone Number", message: "Current User not found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else{
            self.myActivityIndicator.isHidden = true
            self.myActivityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }

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
}

