//
//  PhoneAuth.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase
import AudioToolbox
import AudioUnit
class PhoneAuth: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var picking: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var number: UITextField!
    var handle:AuthStateDidChangeListenerHandle?
    var count = 0
    var text = ""
    var db : Firestore!
    var ID : String?
   
      
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        startAnimate()
        //pickCountry Button and call action PhoneAuth.showCountryViewScreen
        let pickCountry1 = UIButton()
        pickCountry1.setTitle("", for: UIControl.State())
        pickCountry1.setTitleColor(.black, for: UIControl.State())
        pickCountry1.frame = CGRect(x: 30, y: 314, width: 30, height: 32)
        view.addSubview(pickCountry1)
        pickCountry1.addTarget(self, action: #selector(PhoneAuth.showCountryViewScreen), for: UIControl.Event.touchUpInside)
        
        //number design
        number.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: number.frame.height))
        number.leftViewMode = .always
        number.delegate = self
        number.layer.borderColor = UIColor.gray.cgColor
        number.keyboardType = .phonePad
        number.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        number.layer.borderColor = UIColor.gray.cgColor
        number.layer.borderWidth = 1.0
        
        //myLabel for Terms and Services and call action tapLabel
//
       
        
        stopAnimate()
    }
    
    //Function for highlight of terms and services
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        
    
    }
    //Function for number to gray from red
    @objc func textFieldDidChange(_ textField: UITextField) {
        number.layer.borderColor = UIColor.gray.cgColor
        number.layer.borderWidth = 1.0
    }
    //to send the otp on clicking of login button
    @IBAction func sendotp(_ sender: UIButton) {
      
       
            startAnimate()
            
            if number.text == "" {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                number.layer.borderColor = UIColor.red.cgColor
                number.layer.borderWidth = 1.0
                stopAnimate()
            }
            else{
                let a = number.text
                let b = a?.count
                let z = picking.text! + number.text!
                let  preferencees = UserDefaults.standard
               let actualphonenumber = "actualphonenumber"
               preferencees.set(a,forKey:actualphonenumber)
               preferencees.synchronize()
                if (b == 10 || b == 11)
                {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    let alert = UIAlertController(title: "Alert!", message: "Is this your number? \n \(z)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                        //code to send a verification message to mobilenumber
                        PhoneAuthProvider.provider().verifyPhoneNumber(z,uiDelegate:nil) {
                            verificationID, error in

                                let defaults = UserDefaults.standard
                                defaults.set(verificationID, forKey: "authVID")
                             
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTP") as! OTP
                                       vc.text = z//sending phone number
                                       self.present(vc,animated: true,completion: nil)
                              
                                self.stopAnimate()
                            
                        }
                    }
                    let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
                   
                    alert.addAction(cancel)
                     alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    let vc1 = storyboard?.instantiateViewController(withIdentifier: "OTP") as! OTP
                    
                    self.present(vc1,animated: true,completion: nil)
                    stopAnimate()
                    
                }
                else
                {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    let alert = UIAlertController(title: "Alert!", message: "Please enter a valid Mobile Number.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    stopAnimate()
                }
                
            }
            
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc func showCountryViewScreen() {
        self.performSegue(withIdentifier: "countryScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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



extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
