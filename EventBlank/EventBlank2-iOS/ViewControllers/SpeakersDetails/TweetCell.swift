//
//  Tweetswift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RelativeFormatter
import Kingfisher
import RxSwift
import RxGesture
import Then

class TweetCell: UITableViewCell, ClassIdentifier {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var attachmentImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    private var attachmentHeight: NSLayoutConstraint!
    
    private var reuseBag = DisposeBag()
    private let lifeBag = DisposeBag()
    
    //MARK: lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        message.delegate = self
        
        attachmentHeight = attachmentImage.constraints.filter {
            $0.firstAttribute == NSLayoutAttribute.Height && $0.relation == NSLayoutRelation.Equal
        }.first!
        
        
    }
    
    static func cellOfTable(tv: UITableView, tweet: Tweet) -> TweetCell {
        return tv.dequeueReusableCell(TweetCell).then {cell in
            cell.populateFromTweet(tweet)
        }
    }

    private func populateFromTweet(tweet: Tweet) {

        message.text = tweet.text
        message.selectedRange = NSRange(location: 0, length: 0)

        timeLabel.text = tweet.created.relativeFormatted()

        //attachment image
        if let attachmentUrl = tweet.imageUrl {
            attachmentImage.kf_setImageWithURL(attachmentUrl, placeholderImage: nil, optionsInfo: nil, completionHandler: {[weak self] (fullImage, error, cacheType, imageURL) -> () in
                if let `self` = self {
                    fullImage?.asyncToSize(.Fill(self.attachmentImage.bounds.width, 150), cornerRadius: 5.0, completion: {result in
                        self.attachmentImage.image = result
                        self.attachmentImage.rx_gesture(.Tap).subscribeNext {_ in
                            PhotoPopupView.showImage(fullImage!,
                                inView: UIApplication.sharedApplication().windows.first!)
                            }.addDisposableTo(self.reuseBag)
                    })
                }
            })
            attachmentHeight.constant = 148.0
        }
        
        //attached url
        if let url = tweet.url {
            rx_gesture(.Tap).subscribeNext {_ in
                openUrl(url)
            }.addDisposableTo(reuseBag)
        }
        
        //user info
        nameLabel.text = tweet.user?.name

        if let avatarUrl = tweet.user?.avatarUrl {
            userImage.kf_setImageWithURL(avatarUrl, placeholderImage: nil, optionsInfo: nil, completionHandler: {[weak self] (image, error, cacheType, imageURL) -> () in
                if let `self` = self, let image = image {
                    image.rx_resizedImage(.FillSize(self.userImage.bounds.size), cornerRadius: 4)
                        .observeOn(MainScheduler.instance)
                        .bindTo(self.userImage.rx_image)
                        .addDisposableTo(self.reuseBag)
                }
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reuseBag = DisposeBag()
        attachmentImage?.image = nil
        attachmentHeight.constant = 1.0
        userImage.image = nil
    }

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        openUrl(URL)
        return false
    }
}