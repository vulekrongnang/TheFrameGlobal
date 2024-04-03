//
//  PostCell.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import UIKit
import Kingfisher

class PostCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var ivContent: UIImageView!
    
    func updateView(post: PostModel?) {
        let content = post?.content ?? ""
        let mediaUrlString = post?.mediaUrl ?? ""
        
        lbContent.text = content
        lbUserName.text = post?.userName ?? ""
        
        let mediaUrl = URL(string: mediaUrlString)
        ivContent.kf.setImage(with: mediaUrl, placeholder: UIImage(named: "ic_default_image"))
        let avatarUrl = URL(string: post?.userAvatar ?? "")
        ivAvatar.kf.setImage(with: avatarUrl, placeholder: UIImage(named: "ic_default_avatar"))
        
        if let timestamp = Double(post?.id ?? "") {
            let date = Date(timeIntervalSince1970: timestamp/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "HH:mm dd-MM-yyyy "
            let strDate = dateFormatter.string(from: date)
            lbTime.text = strDate
        }
    }
}
