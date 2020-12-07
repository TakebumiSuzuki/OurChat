//
//  PhotoViewerVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/6/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import SDWebImage

final class PhotoViewerVC: UIViewController {

    private let url: URL

    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo"
        
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }


    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    


}

