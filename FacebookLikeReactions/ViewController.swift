//
//  ViewController.swift
//  FacebookLikeReactions
//
//  Created by Shivani Bajaj on 04/08/20.
//  Copyright © 2020 Shivani. All rights reserved.
//

import UIKit

enum ReactionOption: Int, CaseIterable {
    case none
    case like
    case love
    case insightful
    case curious
    
    var reactionObj: Reaction {
        switch self {
        case .none:
            return Reaction(id: self.rawValue, image: UIImage(named: "facebook-like")!, title: "Like", associated_color: UIColor.gray)
            
        case .like:
            return Reaction(id: self.rawValue, image: UIImage(named: "like")!, title: "Like", associated_color: UIColor.gray)
            
        case .love:
            return Reaction(id: self.rawValue, image: UIImage(named: "heart")!, title: "Love", associated_color: UIColor.red)
            
        case .insightful:
            return Reaction(id: self.rawValue, image: UIImage(named: "idea")!, title: "Insightful", associated_color: UIColor(red: 39/255, green: 179/255, blue: 249/255, alpha: 1))
            
        case .curious:
            return Reaction(id: self.rawValue, image: UIImage(named: "brainstorm")!, title: "Curious", associated_color: UIColor(red: 45/255, green: 215/255, blue: 184/255, alpha: 1))
        }
    }
}

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var reactionView: ReactionView!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReactions()
    }
    
    func setupReactions() {
        reactionView.set(reactions: [ReactionOption.like.reactionObj, ReactionOption.love.reactionObj, ReactionOption.insightful.reactionObj, ReactionOption.curious.reactionObj], unselectedReaction: ReactionOption.none.reactionObj)
        reactionView.delegate = self
//        reactionView.set(font: UIFont.systemFont(ofSize: 11))
//        reactionView.set(currentIconSize: 20)
    }
}

// MARK: ReactionViewDelegate

extension ViewController: ReactionViewDelegate {
    func selected(reaction: Reaction) {
        print("Selected reaction is: \(reaction.title)")
    }
    
    func deselectAllReactions() {
        print("Deselected reaction")
    }
}

