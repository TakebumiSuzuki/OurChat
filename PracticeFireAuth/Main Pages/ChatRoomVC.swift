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
import AVFoundation
import AVKit
import SafariServices


class ChatRoomVC: MessagesViewController{
    
    let dateFormatter: DateFormatter = {  //これはメッセージの日付が変わった時のセパレーターを作るために使われる。
        let df = DateFormatter()
        //df.locale = Locale(identifier: "ja_JP")
        //df.timeZone   = TimeZone(identifier: "Asia/Tokyo") //もし日本時間を試したいなら
        return df
    }()
    var chatRoomID = ""  //この変数の値は、前の画面から必ず引き渡される。
    var friendUID = ""   //この変数の値は、前の画面から必ず引き渡される。
    private var friendName = ""
    private var friendPictureURL = ""
    
    
    private var myUID = "" {   //viewDidLoadからのsetProperties()内でAuthから引っ張ってきて代入。
        didSet{
            guard let name = Auth.auth().currentUser?.displayName else{return}
            myDisplayName = name
        }
    }
    private var myDisplayName = "" {     //上のmyUIDのcomputeされる。ここではSenderオブジェクトを作て、代入。
        didSet{
            sender = Sender(senderId: myUID, displayName: myDisplayName)
        }
    }
    private var sender = Sender(senderId: "", displayName: "")
    
    private var messages = [Message(sender: Sender(senderId: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        navigationController?.tabBarController?.tabBar.isHidden = true
        
        setProperties()
        avatarConfiguration()
        setupInputButton()
        resetNewMessageNumber()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) { //viewDidDisappearだと動かなかったのでWillAppearにした。
        super.viewWillDisappear(true)
        
        resetNewMessageNumber()
    }
    

    private func resetNewMessageNumber(){
        
        Firestore.firestore().collection("chatRooms").document(chatRoomID).getDocument { [weak self](snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("chatRoom情報(newMessageNumber)を取得するのに失敗しました"); return}
            guard let snapshot = snapshot, let document = snapshot.data(),
                var numberOfNewMessages = document["numberOfNewMessages"] as? Int,
                let latestMessageSenderUID = document["latestMessageSenderUID"] as? String else{return}
            print("------\(latestMessageSenderUID)&&&\(self.friendUID)")
            if latestMessageSenderUID == self.friendUID{
                print("number was reset to 0 because latestMessageSenderUID == self.friendUID")
                numberOfNewMessages = 0
            }
            
            Firestore.firestore().collection("chatRooms").document(self.chatRoomID).updateData(["numberOfNewMessages" : numberOfNewMessages])
        }
    }
    
    private func setProperties(){
        
        guard let uid = Auth.auth().currentUser?.uid else{print("Authから自分のUIDの取得に失敗しました"); return}
        
        myUID = uid  //ここでmyUIDに値がセットされると、下にいくよりも先にdidSetの方を実行する。
        
        Firestore.firestore().collection("users").document(friendUID).getDocument { [weak self](snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("FireStoreからfriend nameの取得に失敗しました\(error!)"); return}
            
            guard let snapshot = snapshot, let dictionary = snapshot.data() else{return}
            guard let friendName = dictionary["displayName"] as? String else{print("FireStoreドキュメントにfriend nameがないようです"); return}
            DispatchQueue.main.async {
                self.friendName = friendName
                self.navigationItem.title = friendName
            }
        }
        fetchMessages()
    }
    
    
    private func avatarConfiguration(){
        
        if let layout = self.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)))
            layout.setMessageIncomingAvatarSize(CGSize(width: 50, height: 50))
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)))
        }
    }
    
    private func setupInputButton() {  //チャット画面の左下に現れる添付ボタン。 InputBarAccessoryKitについてくるInputBarButtonItemクラスを使う。
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "camera.on.rectangle"), for: .normal)
        button.tintColor = .lightGray
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
        //この後に自動のmessagesCollectionView.reloadData()が必ず行われる。
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    
    
    
//MARK: - Fetch Messages メッセージ配列をダウンロードする一番大切な部分。
    private func fetchMessages(){
        
        Firestore.firestore().collection("chatRooms").document(chatRoomID).collection("messages").order(by: "sentDate", descending: false).addSnapshotListener {[weak self] (snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("messageドキュメントの取得に失敗しました。\(error!)"); return}
            guard let snapshot = snapshot else{return}
            
            self.messages.removeAll() //スナップショットリスナーはキャッシュを使い、常に完全なセットのsnapshotデータを返してくれるのでここで全て空にする。
            snapshot.documents.forEach { (eachDocument) in
                
                let dictionary = eachDocument.data()
                
                let senderArray = dictionary["Sender"] as? [String : Any] ?? [String : Any]()
                let displayName = senderArray["displayName"] as? String ?? ""
                let senderID = senderArray["senderID"] as? String ?? ""
                let sender = Sender(senderId: senderID, displayName: displayName)
                
                let messageId = dictionary["messageId"] as? String ?? ""
                
                //Firestoreにセーブする時はDateでも、それを今度はDLするとTimestampフォーマット変換されてしまっているので元のDateフォーマットに戻す必要あり
                let sentDateTimestampFormat = dictionary["sentDate"] as? Timestamp ?? Timestamp()
                let sentDate = sentDateTimestampFormat.dateValue()
                
                let kindString = dictionary["kind"] as? String ?? ""
                let messageText = dictionary["messageText"] as? String ?? ""
                
                let kind: MessageKind
                switch kindString{
                case "attributedText":     //FireStoreに保存する時にプレインのStringに変換したので、ここでまたAttributedStringに戻す。
                    let color = senderID == self.myUID ? UIColor(white: 1.0, alpha: 1) : UIColor(white: 0.0, alpha: 0.7)
                    kind = .attributedText(NSAttributedString(string: messageText,attributes: [.font: UIFont.preferredFont(forTextStyle: .title3),.foregroundColor: color]))
                case "photo":
                    guard let url = URL(string: messageText), let placeholderImage = UIImage(systemName: "photo") else{return}
                    let media = Media(url: url, image: nil, placeholderImage: placeholderImage,
                                      size: CGSize(width: self.messagesCollectionView.frame.width*0.7,
                                                   height: self.messagesCollectionView.frame.width*0.7*2/3))
                    kind = .photo(media)
                    //ちなみにこの部分でちゃんとMediaオブジェクトが作られていても、displayDelegateの設定ができていないと写真は表示されないので注意。
                case "video":
                    guard let url = URL(string: messageText),
                        let placeholderImage = UIImage(systemName: "video"),
                        let thubmnailURL = dictionary["thumbnailURL"] as? String else{return}
                    let media = Media(url: url, image: nil, placeholderImage: placeholderImage, size: CGSize(width: self.messagesCollectionView.frame.width*0.7,height: self.messagesCollectionView.frame.width*0.7*2/3),
                                      thumbnailURL: thubmnailURL)
                    kind = .video(media)
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
    
    func saveNewMessageNumber(){  //テキストの送信ボタンを押した時も、写真、画像を送った時もコンプリーションから呼ばれる。
        //chatRoomドキュメントにある新しい未読数を記録する
        Firestore.firestore().collection("chatRooms").document(chatRoomID).getDocument { [weak self](snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("chatRoom情報(newMessageNumber)を取得するのに失敗しました"); return}
            guard let snapshot = snapshot, let document = snapshot.data() else {return}
            var numberOfNewMessages: Int
            
            if let number = document["numberOfNewMessages"] as? Int { //すでにchatRoomドキュメントにnumbOfMessの記入がある場合
                numberOfNewMessages = number
                numberOfNewMessages += 1
            }else{
                numberOfNewMessages = 1    //chatRoomドキュメントにnumbOfMessの記入がない場合(初めてのチャットの場合)
            }
            Firestore.firestore().collection("chatRooms").document(self.chatRoomID)
                .updateData(["numberOfNewMessages" : numberOfNewMessages])
        }
    }
    
}



//MARK: - 写真と動画の選択/送信
extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.4){
            
            FireStorageManager.uploadImage(data: imageData, chatRoomID: chatRoomID, myUID: myUID) { [weak self](result) in
                //画像はFireStorageに、パスを"imagesUploadedToChatRooms"/chatRoomID/myUID/ランダム名のようにして保存。
                guard let self = self else{return}
                
                switch result{
                case .success(let downloadURL):
                    guard let placeholder = UIImage(systemName: "photo") else {return}
                    //これからFireStoreに保存するにもかかわらずここでオブジェクトを作っている理由は、オフラインになった時にも送れるようにするため。
                    let media = Media(url: downloadURL, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 200))
                    let message = Message(sender: self.sender, messageId: UUID().uuidString, sentDate: Date(), kind: .photo(media))
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    }
                    Message.saveNewMessageToFireStore(newMessage: message, myUID: self.myUID, friendUID: self.friendUID, friendName: self.friendName, chatRoomID: self.chatRoomID) {
                        self.saveNewMessageNumber()
                    }
                case .failure(let error):
                    print("FireStorageへのデータのセーブに失敗しました\(error)"); return
                }
            }
        }
        
        if let videoLocalURL = info[.mediaURL] as? URL{
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            var thumbailStringURL = ""
            let asset = AVAsset(url: videoLocalURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do{
                let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 3, preferredTimescale: 60), actualTime: nil)
                let thumbnailUIImage = UIImage(cgImage: thumbnailCGImage)
                if let imageData = thumbnailUIImage.jpegData(compressionQuality: 0.4){
                    FireStorageManager.uploadVideoThumbnail(data: imageData, chatRoomID: chatRoomID, myUID: myUID) { (result) in
                        switch result{
                        case .success(let thumbnailURL):
                            thumbailStringURL = thumbnailURL.absoluteString
                        case .failure(let error):
                            print("FireStorageへの動画Thumbnailデータのセーブに失敗しました\(error)")
                        }
                    }
                 }
                dispatchGroup.leave()
            }catch let error{
                print("動画のThumbnail作成中にエラーです\(error)")
                dispatchGroup.leave()
            }
            
            
            dispatchGroup.enter()
            FireStorageManager.uploadVideo(fileURL: videoLocalURL, chatRoomID: chatRoomID, myUID: myUID) { (result) in
                
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .global()) {
                    switch result{
                    case .success(let downloadURL):
                        guard let placeholder = UIImage(systemName: "video") else {return}
                        
                        let media = Media(url: downloadURL, image: nil, placeholderImage: placeholder,
                                          size: CGSize(width: 300, height: 200),
                                          thumbnailURL: thumbailStringURL)
                        let message = Message(sender: self.sender, messageId: UUID().uuidString, sentDate: Date(), kind: .video(media))
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom(animated: true)
                            print(media.thumbnailURL)
                        }
                        Message.saveNewMessageToFireStore(newMessage: message, myUID: self.myUID, friendUID: self.friendUID, friendName: self.friendName, chatRoomID: self.chatRoomID) {
                            self.saveNewMessageNumber()
                        }
                        
                    case .failure(let error):
                        print("FireStorageへのデータのセーブに失敗しました\(error)"); return
                    }
                }
                
            }
        }
    }
    
}



//MARK: - DataSource
extension ChatRoomVC: MessagesDataSource{
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func currentSender() -> SenderType {
        return sender
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    //日付が変わるごとに挿入される。
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateStringToDisplay = NSAttributedString(string: dateFormatter.string(from: message.sentDate),
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                         .foregroundColor: UIColor.darkGray]
        )
        return dateStringToDisplay
    }
    //各メッセージ下の送信時間
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //MessageKitのソースコードにあるMessageKitDateFormatterはSwiftのDateオブジェクトをmodifyしたものだったので、
        //それをコピペして、自分なりに修正して以下のブロックを書いた。doesRelativeDateFormattingというのがポイントとなるプロパティ。
        //但し、同日の場合、英語ではToday,日本語では今日が連続して表示されるので、うざい。そこら辺を消すための行も付け足した。
        
        let dateString = Date.getString(date: message.sentDate)
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
        switch message.kind{
            
        case .photo(_):
            return UIColor.lightGray
        case .video(_):
            return UIColor.lightGray
        default:
            return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.7)
        }
        
    }
    //アバター設定
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
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
            }else{
                DispatchQueue.main.async {
                    avatarView.sd_setImage(with: URL(string: self.friendPictureURL), placeholderImage: UIImage(systemName: "person"))
                }
            }
        }else{
            avatarView.image = UIImage(systemName: "globe")
        }
    }
    
    //.textまたは.attributedTextのメッセージの場合に、もしurlを表す文字列を検知したらTypeを.urlに置き換えてくれる。
    //urlの他に、mapを検知しても良いかも。通常の.textでも.attributedTextでもどちらでも反応し、例えば、messageのコンテンツの文字列が
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    //この設定がないと、いくらMessageオブジェクトのKind(media)をしっかり設定しても写真が表示されない！結局イメージをDLして表示するのはSDWebImageの仕事だった。
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else{return}
        
        switch message.kind {
        case .photo(let photoMedia):
            guard let url = photoMedia.url else {return}
            imageView.sd_setImage(with: url, completed: nil)
            
        case .video(let videoMedia):
            //Mediaオブジェクトのimage:UIImageのプロパティにサムネイルを入れたかったので、動画の0秒地点の画像で作ったサムネイル画像を
            //FirebaseStorageに保存し、そのurlをString情報でFireStoreに保存し、メッセージバブル作成時にSDWebKitで表示させる。かなり面倒な事になったが。。
            guard let media = videoMedia as? Media else{return}
            let urlString = media.thumbnailURL
            let url = URL(string: urlString)
            imageView.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    //.urlとディテクトされたメッセージテキストの書式を決める。ここでは青にして下線を加えている。
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        
        let detectorAttributes: [NSAttributedString.Key: Any] = {
            [
                NSAttributedString.Key.foregroundColor: UIColor.link,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: UIColor.link,
            ]
        }()
        MessageLabel.defaultAttributes = detectorAttributes
        return MessageLabel.defaultAttributes
    }
}




//MARK: - Layout Delegate
extension ChatRoomVC: MessagesLayoutDelegate{
    
    //日付が変わった時だけ高さを50にする。そうでない時は高さを0にして見せないように。
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section > 1{
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            //dateFormatter.timeZone   = TimeZone(identifier: "Asia/Tokyo") //日本時間でテストしたい時にはここをオンに。
            let dateOfThisMessage = dateFormatter.string(from: message.sentDate)
            let lastMessage = messages[indexPath.section - 1]
            let dateOfLastMessage = dateFormatter.string(from: lastMessage.sentDate)
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
    
    func didTapImage(in cell: MessageCollectionViewCell) { //Mediaのメッセージをタップした時に呼ばれるデリゲートメソッドかと。
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {return}
            let vc = PhotoViewerVC(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):
            guard let videoUrl = media.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    func didSelectURL(_ url: URL) {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
}



//MARK: - InputBarDelegate  テキストのセーブはここから。この時点でAttributed Textでセーブしていくようにする。
//オフラインになってしまった時も考慮しないといけないので、必ずちゃんと完成形のMessageオブジェクトをここで作って、
//それをFireStorageManagerに飛ばしセーブするようにする。送信者は必ず自分なので文字色は白。

extension ChatRoomVC: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        inputBar.inputTextView.text = ""
        let attributedString = NSAttributedString(string: text,
                                                attributes: [.font: UIFont.preferredFont(forTextStyle: .title3),.foregroundColor: UIColor(white: 1.0, alpha: 1)])
        
        let newMessage = Message(sender: sender, messageId: UUID().uuidString, sentDate: Date(), kind: .attributedText(attributedString))
        messages.append(newMessage) //オフラインになった時も画面上にメッセージが表示されるようにローカルのmessagesにappendし、reloadData()
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
        
        Message.saveNewMessageToFireStore(newMessage: newMessage, myUID: myUID, friendUID: friendUID, friendName: friendName, chatRoomID: chatRoomID) {
            
            self.saveNewMessageNumber()
        }
    }
    
}
