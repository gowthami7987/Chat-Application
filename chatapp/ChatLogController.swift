//
//  ChatLogController.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import IQKeyboardManagerSwift
import SDWebImage
import ObjectMapper
import AudioToolbox
import AudioUnit

class ChatLogController: UICollectionViewController, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let uid = Auth.auth().currentUser?.uid
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    let uploadImage = UIImageView()
    
     let sendButton = UIButton(type: .custom)
   
    var selectid : String?
   
   
    var profileimage : String?
    var photo : UIImage?
    var mes: [Message] = []
    var time:Date?
    var final: String?

    var imageqr: String? = nil
    var date1:Date?
    var ref : DocumentReference!
    var gradient1 = CAGradientLayer()
    var gradient = CAGradientLayer()
    var a = [UIBarButtonItem]()
    var refreshControl: UIRefreshControl!
    var list = [String]()
    var offsetY:CGFloat = 0
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    lazy var inputTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .clear
         textField.layer.masksToBounds = true
      textField.font = UIFont(name: "Montserrat-Light", size: 25)

        textField.text = "Write Something"
        textField.textColor = UIColor.lightGray

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                   self.isModalInPresentation = true
               }
    
        print("cxvmnvmncx,v")
        inputTextField.setPadding1()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.title = "Chat"
        handleMessages()
        
        let callButton = UIButton(type: .system)
        callButton.setImage(UIImage(named: "Shape-2"), for: .normal)
        callButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        callButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        callButton.tintColor = UIColor(red: 92/255,green: 86/255, blue: 239/255, alpha: 1);
        //add function for button
        callButton.addTarget(self, action: #selector(callToShopper), for: .touchUpInside)
        //set frame
        let barButton1 = UIBarButtonItem(customView: callButton)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton1
        
        let button = UIButton.init(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "Icon-2"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: #selector(back(sender:)), for: UIControl.Event.touchUpInside)
        //set frame
        button.frame = CGRect(x: 10, y: 10, width: 10, height:20)
        let barButton = UIBarButtonItem(customView: button)
        // barButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
        let doneButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back(sender:)))
        a.append(barButton)
        a.append(doneButton)
        navigationItem.setLeftBarButtonItems(a, animated: true)
        
        refreshControl = UIRefreshControl()
//        IQKeyboardManager.shared.enable = true
     
        
        let colortop = UIColor(red : 134.0/255.0, green: 143.0/255.0, blue: 240.0/255.0, alpha: 1.0).cgColor
        let colorbottom = UIColor(red : 214.0/255.0, green: 102.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        
        
        //let gl = CAGradientLayer()
        gradient.colors = [colortop,colorbottom]
        gradient.locations = [0.0,1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = view.frame
        
        let colortop1 = UIColor(red : 136.0/255.0, green: 134.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let colorbottom1 = UIColor(red : 0.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        //let gl = CAGradientLayer()
        gradient1.colors = [colortop1,colorbottom1]
        gradient1.locations = [0.0,1.0]
        gradient1.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient1.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient1.frame = view.frame
        


        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 150, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(red: 244/255,green: 244/255, blue: 244/255, alpha: 1);
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.keyboardDismissMode = .interactive
         collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true

        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        db.collection("ChatRooms").document(selectid!).collection("ChatMessages")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .modified) {
//                        print("removed city: \(diff.document.data())")
                        self.handleMessages()
                    }
                    if (diff.type == .added) {
//                        print("added city: \(diff.document.data())")
                        self.handleMessages()
                    }
                }
        }
        
        setUpInputCommands()
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           
            if text == "\n" {
                textView.resignFirstResponder()
            }
            return text != "\n"
        }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Something"
            textView.textColor = UIColor.lightGray
        }
    }
    @objc func back(sender: UIBarButtonItem) {
        
        print("Back button")
        self.dismiss(animated: true)
        
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardFrameChangeNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
            let animationCurveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue)
            let animationCurve = UIView.AnimationOptions(rawValue: UInt(animationCurveRawValue))
            if let _ = endFrame, endFrame!.intersects(self.view.frame) {
                self.offsetY = self.view.frame.maxY - endFrame!.minY
                UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                    self.view.frame.origin.y = self.view.frame.origin.y - self.offsetY
                }, completion: nil)
            } else {
                if self.offsetY != 0 {
                    UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                        self.view.frame.origin.y = self.view.frame.origin.y + self.offsetY
                        self.offsetY = 0
                    }, completion: nil)
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChatMessageCell
        
        
        cell.chatLogController = self
        let messages = mes[indexPath.item]
        setupCell(cell, messages: messages)
        
        cell.textView.text = mes[indexPath.item].Text

        if messages.Text != nil  && messages.Text != "" {
       
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(messages.Text!).width + 92
            cell.textView.isHidden = false
          
            cell.requestText.isHidden = true
            //            }
            
        }
        else if messages.ImageURL != nil && messages.ImageURL != ""{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.textView1.textColor = UIColor.white
          
            cell.requestText.isHidden = true
        }
        
        let t1 = messages.Time1
//        print("t1", t1 as Any)
        if(t1 != ""){
            
            let t2 = String(describing: messages.Time1)
            let isoDate1 = t2
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let date = dateFormatter.date(from:isoDate1)!
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            let mysty1 = dateFormatter.string(from: date)
            
            cell.textView1.text = String(describing: mysty1)
        }
        
        return cell
    }
    @objc func callToShopper(){
        
                
        self.db.collection("UserProfile").document(selectid ?? "value").getDocument() { (doc, err) in
                    let data = doc!.data()
                    let phnNum = data!["MobileNumber"] as? String ?? ""
                    
                    if let url = URL(string: "tel://\(phnNum)"),
                        UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler:nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                        
                    }
                }
            
        
    }
    
 
    fileprivate func setupCell(_ cell: ChatMessageCell, messages: Message) {
        
        print("setupCell")
        if(messages.SenderId == uid){
            
            
      cell.bubbleView.backgroundColor = UIColor(red: 137.0 / 255.0, green: 94.0 / 255.0, blue: 163.0 / 255.0, alpha: 1.0)
         
                  cell.bubbleView.layer.cornerRadius=2
                  cell.bubbleView.layer.shadowColor=UIColor.lightGray.cgColor
                  cell.bubbleView.layer.shadowOffset=CGSize(width: 1, height: 1)
                  cell.bubbleView.layer.shadowOpacity=0.2
             cell.bubbleView.layer.shadowRadius=1.0
           // cell.bubbleView.layer.insertSublayer(gradient, at: 0)
            cell.textView.textColor = UIColor.white
            cell.textView1.textColor = UIColor.white
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
   
        }
        else{
//           //cell.bubbleView.backgroundColor = UIColor.red
//            cell.bubbleView.backgroundColor = UIColor(red : 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)

            cell.bubbleView.layer.cornerRadius=2
                           cell.bubbleView.layer.shadowColor=UIColor.lightGray.cgColor
                           cell.bubbleView.layer.shadowOffset=CGSize(width: 1, height: 1)
                           cell.bubbleView.layer.shadowOpacity=0.2
                           cell.bubbleView.layer.shadowRadius=1.0
          //  cell.bubbleView.layer.insertSublayer(gradient1, at: 0)
            cell.bubbleView.backgroundColor = UIColor(red : 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.textView1.textColor = UIColor.black
            cell.bubbleLeftAnchor?.isActive = true
            cell.bubbleRightAnchor?.isActive = false
     
        }
        
        let image = messages.ImageURL
        if image != nil && image != ""{
            cell.messageImageView.sd_setImage(with:URL(string: image!))
            cell.messageImageView.isHidden = false
        
        }
        else{
            cell.messageImageView.isHidden = true
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 180
     
        let message = mes[indexPath.item]
        if message.Text  != nil && message.Text != ""{
            height = estimatedFrameForText(message.Text!).height + 32
        }
        else if message.Text  != nil && message.Text != "" && message.Text == "OK" {
            height = estimatedFrameForText("Request Request Request Request Request Request Request").height + 60
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func estimatedFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, context: nil)
    }
    
    
    // image buttom tapping method
    
    @objc func handleUploadTap() {
         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let myAlert = UIAlertController(title : "Select Image From",message:"",preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera",style: .default){(action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated:  true, completion: nil)
            }
        }
        let cameraRollAction = UIAlertAction(title: "Gallery",style: .default){(action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated:  true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        myAlert.addAction(cancelAction)
        myAlert.addAction(cameraAction)
        myAlert.addAction(cameraRollAction)
        self.present(myAlert, animated: true)
        
    }
    
    // image picker from gallery and editing pic
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      
        photo =  info[.originalImage] as? UIImage
        uploadImageToFirebase(image: photo!)
        
        self.dismiss(animated: true, completion: nil )
    }
    
    // image dismiss action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // uploadng image to storage
    func uploadImageToFirebase(image: UIImage){
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let imagename = NSUUID().uuidString
        
        let postItem = storage.child("ChatRooms").child(selectid!).child(imagename)
        if let imageToUpload = image.jpegData(compressionQuality: 0.2){
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            postItem.putData(imageToUpload, metadata: metaData) { (metadata, error) in
                if error != nil{
                    return
                }
                postItem.downloadURL(completion: { (url, error) in
                    if error != nil{

                        return
                    }
                    if let imageURL = url?.absoluteString {
                        self.sendImage(imageURL: imageURL, image: image, sv: sv)
                    }
                })
            }
        }
    }
    
    // saving image url to database
    func sendImage(imageURL: String, image: UIImage, sv: UIView){
        

        
        self.db.collection("ChatRooms").document(selectid!).setData( [
            "UserId": selectid as Any], merge: true)
        self.db.collection("ChatRooms").document(uid!).setData( [
            "UserId": selectid as Any], merge: true)
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Successfully document added")
                self.inputTextField.text = nil
            }
        }
        
        self.db.collection("ChatRooms").document(selectid!).collection("ChatMessages").document().setData( [
            "SenderId": uid as Any,
            "ToId": selectid as Any,
            "Time": FieldValue.serverTimestamp(),
            "ImageURL": imageURL,
            
            "message": ""], merge: true)
        self.db.collection("ChatRooms").document(uid!).collection("ChatMessages").document().setData( [
            "SenderId": uid as Any,
            "ToId": selectid as Any,
            "Time": FieldValue.serverTimestamp(),
            "ImageURL": imageURL,
            
            "message": ""], merge: true)
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Successfully document added")
                UIViewController.removeSpinner(spinner: sv)
                self.collectionView?.reloadData()
                self.inputTextField.text = nil
            }
        }
    }
    
    // saving data to database
    @objc func SendMessage() {
        
        if(inputTextField.text != nil && inputTextField.text != ""){
            sendButton.isEnabled = false
            self.db.collection("ChatRooms").document(selectid!).setData( [
                "UserId": selectid as Any], merge: true)
            self.db.collection("ChatRooms").document(uid!).setData( [
                "UserId": selectid as Any], merge: true)
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully document added")
                    self.inputTextField.text = nil
                     self.sendButton.isEnabled = true
                }
            }
            
            self.db.collection("ChatRooms").document(selectid!).collection("ChatMessages").document().setData( [
                "message": inputTextField.text as Any,
                "SenderId": uid as Any,
                "ToId": selectid as Any,
               
                "ImageURL": "",
                "Time": FieldValue.serverTimestamp()], merge: true)
            self.db.collection("ChatRooms").document(uid!).collection("ChatMessages").document().setData( [
                "message": inputTextField.text as Any,
                "SenderId": uid as Any,
                "ToId": selectid as Any,
               
                "ImageURL": "",
                "Time": FieldValue.serverTimestamp()], merge: true)
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully document added")
                    self.handleMessages()
                    self.inputTextField.text = nil
                }
            }
            
        }
        
        else{
            print("NIL")
            showToast(message: "Please Write Something")
        }
        
    }
    
    func handleMessages(){
        
        // Retrieving the Ids's from the firestore
        let acceptedRef = Firestore.firestore().collection("ChatRooms").document(selectid!).collection("ChatMessages")
        
        acceptedRef.order(by: "Time", descending: false)
            .getDocuments() { (querySnapshot, err) in
                
                if let err=err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        
                        if(document.exists){
                            
                            let details = document.documentID
                            let myData = document.data()
                            let t1 = myData["Time"] as? Timestamp
                   let we = myData["SenderId"] as? String
                            let we1 = myData["ToId"] as? String
//                            print("dtime1:",t1," id : ", details)
                            if (we == self.uid)||(we1 == self.uid) {
                            if(t1 != nil){
                                
                                if self.list.contains(details){
                                    self.self.refreshControl.endRefreshing()
                                }
                                else{
                                    self.list.append(details)
//                                    print("dtime2:",t1," id : ", details)
                                    
                                    let obj: Message = Mapper<Message>().map(JSONObject: document.data())!
                                    obj.setId(Id: document.documentID)
                                    self.mes.append(obj)
                                    
                                    //self.mes.insert(Message(ImageURL: imageurl, SenderId: senderid, ToId: toid, Text: message, Time: self.final), at: 0 )
                                    DispatchQueue.main.async(execute: {
                                        self.collectionView?.reloadData()
                                        //scroll to the last index
                                        let indexPath = IndexPath(item: self.mes.count - 1, section: 0)
                                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                                    })
                                    
                                }
                                DispatchQueue.main.async
                                    {
                                        self.collectionView?.reloadData()
                                }
                            }
                        }
                        }
                    }
                }
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
  
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isBeingPresented || isMovingToParent {
            // This is the first time this instance of the view controller will appear
            print("This is the first time this instance of the view controller will appear")
        }
        else
        {
            print("This controller is appearing because another was just dismissed")
            self.tabBarController?.tabBar.isHidden = true
            // This controller is appearing because another was just dismissed
        }
    }
    
    func setUpInputCommands() {
        
      
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor(red: 217/255,green: 206/255, blue: 214/255, alpha: 0);
        
        // x,y,w,h
       containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor , constant: 20).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        //        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70).isActive = true
        containerView.layer.borderColor = UIColor(red: 217/255,green: 206/255, blue: 214/255, alpha: 1).cgColor;
        containerView.layer.borderWidth = CGFloat(Float(2.0));
        containerView.layer.cornerRadius = CGFloat(Float(25.0));
        
        let containerView1 = UIView()
               containerView1.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(containerView1)
               containerView1.backgroundColor = UIColor(red: 217/255,green: 206/255, blue: 214/255, alpha: 0);
             // containerView1.topAnchor.constraint(equalTo: self.view.leftAnchor , constant: 55).isActive = true
               // x,y,w,h
              containerView1.leftAnchor.constraint(equalTo: self.view.leftAnchor , constant: 20).isActive = true
               containerView1.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60).isActive = true
               //        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true
               containerView1.heightAnchor.constraint(equalToConstant: 50).isActive = true
               containerView1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
               containerView1.layer.borderColor = UIColor(red: 217/255,green: 206/255, blue: 214/255, alpha: 1).cgColor;
               containerView1.layer.borderWidth = CGFloat(Float(2.0));
               containerView1.layer.cornerRadius = CGFloat(Float(25.0));
              containerView1.isHidden = true
     
        let image1 = UIImage(named: "Group 3-1")
        sendButton.setImage(image1, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(SendMessage), for: .touchUpInside)
        view.addSubview(sendButton)
        
        // x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        sendButton.leftAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true
        
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        //        let textfieldview = UIView()
        view.addSubview(inputTextField)
        
       

                
      
        view.addSubview(inputTextField)
        // x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
   
        containerView.backgroundColor = UIColor(red: 255/255,green: 255/255, blue: 255/255, alpha: 1);
        
        
        
        uploadImage.isUserInteractionEnabled = true
        uploadImage.image = UIImage(named: "Camera Icon")
        uploadImage.translatesAutoresizingMaskIntoConstraints = false
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        view.addSubview(uploadImage)
        // x,y,w,h
        uploadImage.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        uploadImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.bringSubviewToFront(uploadImage)
      
      

        
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
extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
}


extension UITextView {
    func setPadding1(){
        textContainerInset = UIEdgeInsets(top: 8, left: 40, bottom: 8, right: 4)

    }
    
}





