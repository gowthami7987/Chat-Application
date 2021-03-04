//
//  OTP.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AudioUnit
import AudioToolbox


class OTP: UIViewController {
    var count : Int = 1
    var text = ""//Mobilenumber
    @IBOutlet weak var textretrive: UILabel!//MN
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var resending: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var otptext: UILabel!
    @IBOutlet weak var alertview: UIView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var changepin: UIButton!
 
    @IBOutlet weak var Name: UITextField!
    
    var blurView1 : UIView?
    var createwallet : String = ""
    let user_id = Auth.auth().currentUser?.uid
    var ID : String?
    
   
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBAction func show(_ sender: UIButton)
    {
      
        if textfield.isSecureTextEntry == true{
            textfield.isSecureTextEntry = false
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        else{
            textfield.isSecureTextEntry = true
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
    }
    @IBAction func show1(_ sender: UIButton)
    {
       
        if textField1.isSecureTextEntry == true{
            textField1.isSecureTextEntry = false
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        else{
            textField1.isSecureTextEntry = true
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.myActivityIndicator.isHidden = true
        if #available(iOS 13.0, *) {
                   self.isModalInPresentation = true
               }
        startAnimate()
        
        textLabel.text = text
        textretrive.text = text
        
        self.count = 120
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        self.resending.addTarget(self, action: #selector(self.buttontapped), for: .touchUpInside)
        number.layer.borderColor=UIColor.gray.cgColor
        number.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: number.frame.height))
        number.leftViewMode = .always
        number.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        number.layer.borderColor = UIColor.gray.cgColor
        number.layer.borderWidth = 1.0
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 1.0
        textField1.layer.borderColor = UIColor.gray.cgColor
        textField1.layer.borderWidth = 1.0
        
        
        let userid1 = Auth.auth().currentUser?.uid
        stopAnimate()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        number.layer.borderColor = UIColor.gray.cgColor
        number.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 1.0
        textField1.layer.borderColor = UIColor.gray.cgColor
        textField1.layer.borderWidth = 1.0
    }
    
    // after entering the otp log on to the profile page
    @IBAction func login(_ sender: UIButton) {
     
            startAnimate()
            let defaults = UserDefaults.standard
            if number.text == "" {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                number.layer.borderColor = UIColor.red.cgColor
                number.layer.borderWidth = 1.0
                stopAnimate()
            }
            else
            {
                if (self.number.text?.count)! == 6
                {
                    let credential1 = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID") ?? "ghj",verificationCode: self.number.text!)
                    Auth.auth().signInAndRetrieveData(with: credential1) { authData, error in
                        if ((error) != nil) {
                            // Handles error
                            if(error?.localizedDescription == "The user account has been disabled by an administrator.")
                            {
                                 AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                let alertVC = UIAlertController(title: "Alert!", message: "The user account has been disabled \n by an administrator.", preferredStyle: .alert)
                                let alertActionOkay = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertVC.addAction(alertActionOkay)
                                self.present(alertVC, animated: true, completion: nil)
                                self.stopAnimate()
                            }
                            else
                            {
                                print("error: \(String(describing: error?.localizedDescription))")
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.number.layer.borderColor = UIColor.red.cgColor
                                self.number.layer.borderWidth = 1.0
                                self.stopAnimate()
                            }
                        }
                        else
                        {
                            if let user_id = Auth.auth().currentUser?.uid
                            {
                                let ref = Firestore.firestore().collection("UserProfile").document(user_id)
                                ref.getDocument() { (docSnapShot,err) in
                                    if let err = err
                                    {
                                        print("Error getting documents: \(err)")
                                        self.stopAnimate()
                                    }
                                    else
                                    {
                                        let docSnapShot = docSnapShot
                                        if(docSnapShot?.exists)!
                                        {
                                            let key = docSnapShot?.data()! ["Key"] as? String ?? ""
                                            
                                            if key == ""
                                            {
                                               
                                                self.stopAnimate()
                                                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                                                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                                blurEffectView.frame = self.view.bounds
                                                blurEffectView.alpha = 0.8
                                                self.blurView1 = blurEffectView
                                                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                                self.view.addSubview(blurEffectView)
                                                self.view.addSubview(self.alertview)
                                                self.alertview.isHidden = false
                                                self.alertview.layer.borderWidth=0.2
                                                self.alertview.layer.cornerRadius=10
                                                self.alertview.layer.borderColor=UIColor.lightGray.cgColor
                                                self.alertview.layer.shadowColor=UIColor.lightGray.cgColor
                                                self.alertview.layer.shadowOffset=CGSize(width: 3, height: 3)
                                                self.alertview.layer.shadowOpacity=0.2
                                                self.alertview.layer.shadowRadius=4.0
                                                self.changepin.addTarget(self, action: #selector(self.securitypin), for: .touchUpInside)
                                                
                                            }
                                            else
                                            {
                                                
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                                self.present(vc,animated: true,completion: nil)
                                                
                                                    self.stopAnimate()
                                                
                                                
                                            }
                                        }
                                        else
                                        {
                                            self.stopAnimate()
                                            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                                            let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                            blurEffectView.frame = self.view.bounds
                                            blurEffectView.alpha = 0.6
                                            self.blurView1 = blurEffectView
                                            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                            self.view.addSubview(blurEffectView)
                                            self.view.addSubview(self.alertview)
                                            self.alertview.isHidden = false
                                            self.alertview.layer.borderWidth=0.2
                                            self.alertview.layer.cornerRadius=10
                                            self.alertview.layer.borderColor=UIColor.lightGray.cgColor
                                            self.alertview.layer.shadowColor=UIColor.lightGray.cgColor
                                            self.alertview.layer.shadowOffset=CGSize(width: 3, height: 3)
                                            self.alertview.layer.shadowOpacity=0.2
                                            self.alertview.layer.shadowRadius=4.0
                                            self.changepin.addTarget(self, action: #selector(self.securitypin), for: .touchUpInside)
                                        }
                                    }
                                }
                            }
                            else
                            {
                                self.stopAnimate()
                               
                            }
                            //self.stopAnimate()
                           
                        }
                    }
                    
                }
                else
                {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    number.layer.borderColor = UIColor.red.cgColor
                    number.layer.borderWidth = 1.0
                    stopAnimate()
                }
            }
        }
    
    @objc func securitypin(){
        startAnimate()
       
        if self.textfield.text == ""{
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            textfield.layer.borderColor = UIColor.red.cgColor
            textfield.layer.borderWidth = 1.0
            stopAnimate()
        }
        else if self.textField1.text == ""{
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            textField1.layer.borderColor = UIColor.red.cgColor
            textField1.layer.borderWidth = 1.0
            stopAnimate()
        }
        else{
            if (self.textfield.text?.count)! >= 8 && (self.textField1.text?.count)! >= 8 {
                if self.textfield.text == self.textField1.text{
                   
                    let mobile = Auth.auth().currentUser?.phoneNumber
                   
                    if let user_id = Auth.auth().currentUser?.uid {
                        Firestore.firestore().collection("UserProfile").document(user_id).setData( [
                            "MobileNumber": mobile!,
                            "Key": self.textfield.text!,
                            "Name":self.Name.text,
                            
                            ], merge: true) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    self.stopAnimate()
                                }
                                else
                                {
                                   
                                    print("Document added with ID")
                                  
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                    self.present(vc,animated: true,completion: nil)
                                    self.stopAnimate()
                                }
                        }
                    }
                    else
                    {
                        stopAnimate()
                        
                    }
                }
                else
                {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    textfield.layer.borderColor = UIColor.red.cgColor
                    textfield.layer.borderWidth = 1.0
                    textField1.layer.borderColor = UIColor.red.cgColor
                    textField1.layer.borderWidth = 1.0
                    stopAnimate()
                }
            }
            else
            {
                self.showToast(message: "Password must be 8 characters or more.")
                stopAnimate()
            }
        }
    }
    @objc func cancel(){
        self.alertview.isHidden = true
        self.blurView1?.removeFromSuperview()
    }
    // to update the timer field
    @objc func updateCounter() {
        if count == 1 {
            countDownLabel.text = ""
            otptext.text = "Did not receive OTP? Click"
            self.resending.isHidden = false
            count-=1
        }
        else if count > 0
        {
            otptext.text = "You will receive OTP in"
            self.resending.isHidden = true
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            countDownLabel.text = minutes + ":" + seconds
            count-=1
        }
    }
    // to resend the otpon clicking the resend button
    @objc func buttontapped() {
      
            startAnimate()
            textLabel.text = text
            textretrive.text = text
            if let m = textLabel.text{
                    self.count = 120
                    self.updateCounter()
                    PhoneAuthProvider.provider().verifyPhoneNumber(m,uiDelegate:nil) {
                        verificationID, error in
                        if error != nil{
                            print("error: \(String(describing: error?.localizedDescription))")
                            self.showToast(message: String(describing: error?.localizedDescription))
                            self.stopAnimate()
                        }else {
                            let defaults = UserDefaults.standard
                            defaults.set(verificationID, forKey: "authVID")
                            self.stopAnimate()
                        }
                    }
            }
            else{
                self.showToast(message: "Phone number not found")
                stopAnimate()
            }
       
    }
    // status bar
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    // to goback to the main page
    @IBAction func EnteredWrong(_ sender: UIButton) {
      
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneAuth") as! PhoneAuth
        self.present(vc,animated: true,completion: nil)
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

