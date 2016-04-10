//
//  SpeakerCell.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift
import RxCocoa

import Then

class SpeakerCell: UITableViewCell, ClassIdentifier {

    private let lifeBag = DisposeBag()
    var reuseBag = DisposeBag()
    
    // outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    
    // input
    let isFavorite = PublishSubject<Bool>()
    
    //methods
    override func awakeFromNib() {
        super.awakeFromNib()

        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        btnToggleIsFavorite.setImage(nil, forState: .Normal)
        
        //bindUI
        isFavorite.bindTo(btnToggleIsFavorite.rx_selected).addDisposableTo(lifeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reuseBag = DisposeBag()
        userImage.image = nil
        twitterLabel.text = nil
    }
    
    static func cellOfTable(tv: UITableView, speaker: Speaker) -> SpeakerCell {
        return tv.dequeueReusableCell(SpeakerCell).then {cell in
            cell.populateFromSpeaker(speaker)
        }
    }
    
    private func populateFromSpeaker(speaker: Speaker) {
        //setupUI
        if let userImage = speaker.photo {
            userImage.asyncToSize(.FillSize(self.userImage.bounds.size), cornerRadius: self.userImage.bounds.size.width/2, completion: {result in
                self.userImage.image = result
            })
        }
        
        nameLabel.text = speaker.name
        
        if let twitter = speaker.twitter where twitter.utf8.count > 0 {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        }
    }
}
