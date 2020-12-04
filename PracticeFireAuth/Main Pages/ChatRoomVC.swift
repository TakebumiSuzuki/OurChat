//
//  ChatRoomVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/28/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView


class ChatRoomVC: MessagesViewController{
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.timeZone   = TimeZone(identifier: "Asia/Tokyo")
        return df
    }()
    var chatRoomID = ""  //これら2つの変数の値は、前の画面から必ず引き渡される。
    var friendUID = ""
    var friendPictureURL = ""
    
    
    private var myUID = "" {   //viewDidLoadからのsetProperties()内でAuthから引っ張ってきて代入。
        didSet{
            print("3.myUIDがセットされ現在didSet内です。")
            guard let name = Auth.auth().currentUser?.displayName else{return}
            print("3.5.myDisplayNameをAuthから取得し、myDisplayNameに代入するところです。")
            myDisplayName = name
            print("5.myDisplayNameをAuthから取得し、myDisplayNameに代入が終わりました。")
        }
    }
    private var myDisplayName = "" {     //上のmyUIDのcomputeされる。ここではSenderオブジェクトを作て、代入。
        didSet{
            sender = Sender(senderId: myUID, displayName: myDisplayName)
            print("4.decentなsenderが作られました \(sender)")
        }
    }
    private var sender = Sender(senderId: "", displayName: "")
    
    private var messages = [Message(sender: Sender(senderId: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("1.viewDidLoad発動")
        setProperties()
        print("8. これからdelegate設定に入ります")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = .red
        
        
        if let layout = self.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
            layout.setMessageIncomingAvatarSize(CGSize(width: 50, height: 50))
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)))
        }
        setupInputButton()
    }
    
    private func setupInputButton() {  //チャット画面の左下に現れる添付ボタン。 InputBarAccessoryKitについてくるInputBarButtonItemクラスを使う。
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "camera.on.rectangle"), for: .normal)
        button.onTouchUpInside { [weak self] _ in    //messageInputBarについてくるメソッド
            guard let self = self else{return}
            self.cameraButtonPressed()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false) //messageInputBarについてくるメソッド
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false) //messageInputBarについてくるメソッド
        
    }
    
    func cameraButtonPressed(){
        
        let action1 = UIAlertAction(title: "Photo Library", style: .default) { [weak self](action) in
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
        let action2 = UIAlertAction(title: "Take Photo", style: .default) { [weak self](action) in
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
        let action3 = UIAlertAction(title: "Video Library", style: .default) { [weak self](action) in
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self.present(picker, animated: true)
        }
        let action4 = UIAlertAction(title: "Take Video", style: .default) { [weak self](action) in
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
        let action5 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Choose picture or video to send.", message: "", actions: [action1, action2, action3, action4, action5])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        (print("9.viewwillappear発動しました。オートのreloadがこの直後に行われると思われます。"))
        
        //self.messagesCollectionView.scrollToBottom(animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        (print("viewDIDappear発動しました。"))
    }
    
    private func setProperties(){
        
        guard let uid = Auth.auth().currentUser?.uid else{print("Authから自分のUIDの取得に失敗しました"); return}
        print("2.myUIDの取得が終わったところです")
        myUID = uid  //ここでmyUIDに値がセットされると、下にいくよりも先にdidSetの方を実行する。
        print("6.myUIDの取得が終わりセットされ、今からFirestoreにfirendドキュメントを得るためのコマンドを実行します。----")
        Firestore.firestore().collection("users").document(friendUID).getDocument { [weak self](snapshot, error) in
            print("12.friendNameを得るためのDocumentの取得が終わりました。")
            guard let self = self else{return}
            if error != nil{print("FireStoreからfriend nameの取得に失敗しました\(error!)"); return}
            
            guard let snapshot = snapshot, let dictionary = snapshot.data() else{return}
            guard let friendName = dictionary["displayName"] as? String else{print("FireStoreドキュメントにfriend nameがないようです"); return}
            DispatchQueue.main.async {
                self.navigationItem.title = friendName
                print("13.friendNameを得るためのFirestore getDocumentの最後のDispatchqeueです")
            }
        }
        fetchMessages()
        
    }
    
    
    
//MARK: - Fetch Messages
    private func fetchMessages(){
        
        Firestore.firestore().collection("chatRooms").document(chatRoomID).collection("messages").order(by: "sentDate", descending: false).addSnapshotListener {[weak self] (snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("messageドキュメントの取得に失敗しました。\(error!)"); return}
            guard let snapshot = snapshot else{return}
            
            self.messages.removeAll()
            snapshot.documents.forEach { (eachDocument) in
                
                let dictionary = eachDocument.data()
                
                let senderArray = dictionary["Sender"] as? [String : Any] ?? [String : Any]()
                let displayName = senderArray["displayName"] as? String ?? ""
                let senderID = senderArray["senderID"] as? String ?? ""
                let sender = Sender(senderId: senderID, displayName: displayName)
                
                let messageId = dictionary["messageId"] as? String ?? ""
                
                //Firestoreにセーブする時はDateでも、それを今度はDLするとTimestampフォーマットになっているのでdateFormatterを使うため元に戻す必要あり
                let sentDateTimestampFormat = dictionary["sentDate"] as? Timestamp ?? Timestamp()
                let sentDate = sentDateTimestampFormat.dateValue()
                
                let color = senderID == self.myUID ? UIColor(white: 1.0, alpha: 1) : UIColor(white: 0.0, alpha: 1)
                
                
                let kindString = dictionary["kind"] as? String ?? ""
                let messageText = dictionary["messageText"] as? String ?? ""
                let kind: MessageKind
                
                switch kindString{
                case "text":
                    kind = .attributedText(NSAttributedString(string: messageText,attributes: [.font: UIFont.preferredFont(forTextStyle: .title3),.foregroundColor: color]))
                case "photo":
                    guard let url = URL(string: messageText), let placeholderImage = UIImage(systemName: "cloud") else{return}
                    let media = Media(url: url, image: nil, placeholderImage: placeholderImage, size: CGSize(width: 300, height: 200))
                    kind = .photo(media)
                case "video":
                    return
                default:
                    return
                }
                
                let message = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: kind)
                
                self.messages.append(message)
            }
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
            }
        }
    }
    
}



//MARK: - UIImagePicker Delegate Methods
extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.5) else{
            print("画像の取得または圧縮に失敗しました"); return
        }
        
        FireStorageManager.uploadMediaData(data: imageData, chatRoomID: chatRoomID, uid: myUID) { [weak self](result) in
            
            guard let self = self else{return}
            
            switch result{
            case .success(let downloadURL):
                
                guard let url = URL(string: downloadURL), let placeholder = UIImage(systemName: "plus") else {return}
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: CGSize(width: 200, height: 200))
                let message = Message(sender: self.sender, messageId: UUID().uuidString, sentDate: Date(), kind: .photo(media))
                self.messages.append(message)
                self.messagesCollectionView.reloadData()
                Message.saveNewMessageToFireStore(newMessage: message, myUID: self.myUID, friendUID: self.friendUID, chatRoomID: self.chatRoomID) {
                    //
                }
            case .failure(let error):
                print("FireStorageへのデータのセーブに失敗しました\(error)"); return
            }
        }
    }
    
}



//MARK: - DataSource

extension ChatRoomVC: MessagesDataSource{
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("MessageDataSource1")
        return messages.count
    }
    
    func currentSender() -> SenderType {
        
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        dateFormatter.dateStyle = .long
        let dateStringToDisplay = NSAttributedString(string: dateFormatter.string(from: message.sentDate),
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                         .foregroundColor: UIColor.darkGray]
        )
        return dateStringToDisplay
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //MessageKitのソースコードにあるMessageKitDateFormatterはSwiftのDateオブジェクトをmodifyしたものだったので、
        //それをコピペして、自分なりに修正して以下のブロックを書いた。doesRelativeDateFormattingというのがポイントとなるプロパティ。
        //正し、同日の場合、英語ではToday,日本語では今日が連続して表示されるので、うざい。そこら辺を消すための行も付け足した。
        
        switch true {
        case Calendar.current.isDateInToday(message.sentDate) || Calendar.current.isDateInYesterday(message.sentDate):
            dateFormatter.doesRelativeDateFormatting = true
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .weekOfYear):
            dateFormatter.dateFormat = "EEEE h:mm a"
        case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .year):
            dateFormatter.dateFormat = "E, d MMM, h:mm a"
        default:
            dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        }
        //dateFormatter.locale = Locale(identifier: "ja_JP")  //もし日本語表記を試したい場合はこの行をオンに。
        let dateString = dateFormatter.string(from: message.sentDate)
        let dateStringVer2 = dateString.replacingOccurrences(of: "Today, ", with: "")
        let dateStringVer3 = dateStringVer2.replacingOccurrences(of: "今日 ", with: "")
        return NSAttributedString(string: dateStringVer3, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.darkGray])
    }
    
}



//MARK: - DisplayDelegate

extension ChatRoomVC: MessagesDisplayDelegate{
    
    //メッセージバブルの吹き出し設定
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.7)
    }
    //アバター設定
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //一度読み込んだ画像をローカルにpersistする必要がある。userDefaultsを使うか、またはSDWebImageにその機能が備わっているか。。。
        avatarView.layer.borderWidth = 1.5
        avatarView.layer.borderColor = UIColor.darkGray.cgColor
        
        if message.sender.senderId == friendUID{
            if friendPictureURL == ""{
                Firestore.firestore().collection("users").document(friendUID).getDocument { [weak self](snapshot, error) in
                    guard let self = self else{return}
                    if error != nil{print("friendUIDのドキュメントをFirestoreから取得するのに失敗しました\(error!)"); return}
                    guard let snapshot = snapshot, let document = snapshot.data() else{return}
                    if let url = document["pictureURL"] as? String{
                        self.friendPictureURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: URL(string: self.friendPictureURL), placeholderImage: UIImage(systemName: "person"))
                        }
                    }
                }
            }
        }else{
            avatarView.image = UIImage(systemName: "")
        }
    }
    
    //urlの他に、mapを検知しても良いかも。通常の.textでも.attributedTextでもどちらでも反応し、例えば、messageのコンテンツの文字列が
    //urlを表す文字列だと検知したらTypeを.urlに置き換えてくれる。
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    //この設定がないと、いくらMessageオブジェクトのKind(media)をしっかり設定しても写真が表示されない！結局イメージをDLして表示するのはSDWebImageの仕事だった。
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else{return}
        
        switch message.kind {
        case .photo(let photoURL):
            guard let url = photoURL.url else {return}
            imageView.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
}




//MARK: - Layout Delegate
extension ChatRoomVC: MessagesLayoutDelegate{
    
    
    //日付が変わった時だけ高さを50にする。そうでない時は高さを0にして見せないように。
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section > 1{
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.timeZone   = TimeZone(identifier: "Asia/Tokyo")
            let dateOfThisMessage = dateFormatter.string(from: message.sentDate)
            let lastMessage = messages[indexPath.section - 1]
            let dateOfLastMessage = dateFormatter.string(from: lastMessage.sentDate)
            print(dateOfThisMessage, dateOfLastMessage)
            if dateOfThisMessage != dateOfLastMessage{
                return 50
            }
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 4
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 23
    }
}



//MARK: - CellDelegate
extension ChatRoomVC: MessageCellDelegate{
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    //以下の3つはKeyboardを閉じるために必要なメソッド、時間がかかったが、Workaroundとしてこの3つを書く必要があった
    func didTapBackground(in cell: MessageCollectionViewCell) {
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
}



//MARK: - InputBarDelegate
extension ChatRoomVC: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        inputBar.inputTextView.text = ""
        
        let newMessage = Message(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(newMessage)//オフラインになった時も画面上メッセージが送られて対処できるように。
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
        Message.saveNewMessageToFireStore(newMessage: newMessage, myUID: myUID, friendUID: friendUID, chatRoomID: chatRoomID) {
            
            DispatchQueue.main.async {
                print("inputBarからのメッセージがFireStoreで保存され、Completion内で今scrollToBottomが実行されるところです。")
                
            }
        }
    }
    
}
