//
//  ChatMessageCell.swift
//  chatapp
//
//  Created by gowthamichintha on 03/03/21.
//
import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    
    let textView: UITextView = {
        let tv = UITextView()
         tv.isScrollEnabled = false
        tv.text = "Hello"
        tv.textColor = UIColor.white
        tv.font = tv.font!.withSize(16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        return tv
    }()
    
    let textView1: UITextView = {
        let tv = UITextView()
    tv.isScrollEnabled = false
        tv.text = "12.00 PM"
        tv.textColor = UIColor.red
        tv.font = tv.font!.withSize(12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1.0)
        //view.backgroundColor = UIColor.colorWithHexString(hexStr: "#007AFF")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    

    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
       // imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    let requestText: UITextView = {
        let tv = UITextView()
        tv.text = "Request Request Request Request Request Request Request"
        tv.textColor = UIColor.black
        tv.font = tv.font!.withSize(16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
                  tv.isScrollEnabled = false
        return tv
    }()
    

    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(textView1)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(requestText)
     
        
        // x,y,w,h
        (requestText).topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        (requestText).leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        (requestText).rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        //(requestText).widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        (requestText).heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
      
        
        
        // x,y,w,h
        (messageImageView).leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        (messageImageView).topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        (messageImageView).widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        (messageImageView).heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        
        // x,y,w,h
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = (bubbleView).widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        // x,y,w,h
        //(textView1).leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        (textView1).topAnchor.constraint(equalTo: textView1.topAnchor).isActive = true
        (textView1).bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        (textView1).rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        (textView1).widthAnchor.constraint(equalToConstant: 65).isActive = true
        (textView1).heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // x,y,w,h
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: textView1.rightAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
