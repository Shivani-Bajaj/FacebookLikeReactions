//
//  ReactionView.swift
//  FacebookLikeReactions
//
//  Created by Shivani Bajaj on 04/08/20.
//  Copyright © 2020 Shivani. All rights reserved.
//

import UIKit

protocol ReactionViewDelegate {
    func selected(reaction: Reaction)
    func deselectAllReactions()
}

class ReactionView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var currentReactionLabel: UILabel!
    @IBOutlet weak var currentReactionImageView: UIImageView!
    @IBOutlet weak var reactionImageViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: Private Variables
    
    private var longPressGesture: UILongPressGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    private let iconsContainerView = UIView()
    private var stackView: UIStackView?
    private var iconHeight: CGFloat = 36
    private var padding: CGFloat = 8
    private var selectedReaction: Reaction?
    private var defaultReaction: Reaction?
    private var unselectedReaction: Reaction?
    
    // MARK: Variables
    
    private var reactions = [Reaction]()
    
    // MARK: Variables Received
    
    var delegate: ReactionViewDelegate?
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Setup Methods
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ReactionView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewLongPressed(gesture:)))
        self.addGestureRecognizer(longPressGesture!)
//        initializeIconsContainer()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:)))
        self.addGestureRecognizer(tapGesture!)
    }
    
    func set(reactions: [Reaction], unselectedReaction: Reaction?) {
        self.reactions = reactions
        defaultReaction = reactions.first
        self.unselectedReaction = unselectedReaction
        deselectReaction()
        initializeIconsContainer()
    }
    
    func setDefaultReaction(with index: Int) {
        if index < reactions.count {
            defaultReaction = reactions[index]
        }
    }
    
    func set(font: UIFont) {
        currentReactionLabel.font = font
    }
    
    func set(currentIconSize: CGFloat) {
        reactionImageViewWidthConstraint.constant = currentIconSize
    }
    
    func select(reaction: Reaction) {
        delegate?.selected(reaction: reaction)
        self.iconsContainerView.removeFromSuperview()
        
        self.currentReactionLabel.text = reaction.title
        self.currentReactionLabel.textColor = reaction.associated_color
      
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.currentReactionImageView.image = reaction.image
            self.currentReactionImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.3) {
                self.currentReactionImageView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func deselectReaction() {
        selectedReaction = nil
        currentReactionImageView.image = unselectedReaction?.image
        currentReactionLabel.text = unselectedReaction?.title
        currentReactionLabel.textColor = unselectedReaction?.associated_color
        delegate?.deselectAllReactions()
    }
    
    private func initializeIconsContainer() {
        iconsContainerView.backgroundColor = .white
        iconsContainerView.alpha = 0
    }
    
    // MARK: Helper Methods
    
    private func setupContainerViewShadow() {
        iconsContainerView.layer.cornerRadius = iconsContainerView.bounds.height / 2
        iconsContainerView.layer.masksToBounds = true
        iconsContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        iconsContainerView.layer.shadowOpacity = 0.8
        iconsContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        iconsContainerView.layer.shadowRadius = iconsContainerView.bounds.height / 2
        iconsContainerView.layer.masksToBounds = false
    }
    
    // MARK: Gesture Recognizer Methods
    
    @objc private func viewTapped(gesture: UITapGestureRecognizer) {
        if let _ = selectedReaction {
            deselectReaction()
        } else {
            if let defaultReaction = defaultReaction {
                selectedReaction = defaultReaction
                select(reaction: defaultReaction)
            }
        }
    }
    
    @objc private func viewLongPressed(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            handleLongPressGestureBegan(gesture: gesture)
        case .changed:
            handleLongPressGestureChanged(gesture: gesture)
        case .ended:
            handleLongPressGestureEnded(gesture: gesture)
        default:
            break
        }
    }
    
    private func handleLongPressGestureBegan(gesture: UILongPressGestureRecognizer) {
        let imagesCount = CGFloat(reactions.count)
        let width = (imagesCount * iconHeight) + ((imagesCount + 1) * padding)
        let frame = UIApplication.shared.windows.first?.convert(self.frame, from: self.superview)
        iconsContainerView.frame = CGRect(x: (frame?.minX ?? 0) + 10, y: frame?.minY ?? 0, width: width, height: iconHeight + 2 * padding)
        setupContainerViewShadow()
        UIApplication.shared.windows.first?.addSubview(iconsContainerView)
        
        if stackView == nil {
            var imageViews = [UIImageView]()
            for (index, reaction) in reactions.enumerated() {
                let imageView = UIImageView(image: reaction.image)
                imageView.tag = index
                imageView.layer.cornerRadius = iconHeight / 2
                imageView.isUserInteractionEnabled = true
                imageViews.append(imageView)
            }
            stackView = UIStackView(arrangedSubviews: imageViews)
            stackView?.spacing = padding
            stackView?.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            stackView?.isLayoutMarginsRelativeArrangement = true
            stackView?.frame = iconsContainerView.bounds
            stackView?.distribution = .fillEqually
            iconsContainerView.addSubview(stackView!)
        }
    
        self.iconsContainerView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.iconsContainerView.transform = CGAffineTransform(translationX: 0, y: -(self.iconHeight + 2 * self.padding + 10))
            self.iconsContainerView.alpha = 1
        }, completion: nil)
    }
    
    private func handleLongPressGestureChanged(gesture: UILongPressGestureRecognizer) {
        let pressedLocation = gesture.location(in: iconsContainerView)
        
        
        // Hit test is userd to check if the view is in the heirarchy of a given point. If yes, then the foremost view is being returned
        
        // self.iconsContainerView.frame.height / 2 is applies here, so that y position is always stated to be in iconContainerView, so that wherever you place the finger, the x position is considered for the hitTest.
        
        let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.iconsContainerView.frame.height / 2)
        let hitTestView = iconsContainerView.hitTest(fixedYLocation, with: nil)
        if hitTestView is UIImageView {
            selectedReaction = reactions[(hitTestView as? UIImageView)?.tag ?? 0]
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let stackView = self.iconsContainerView.subviews.first
                stackView?.subviews.forEach({ (imageView) in
                    imageView.transform = CGAffineTransform.identity
                })
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -(self.iconHeight / 2))
            }, completion: nil)
        }
    }
    
    private func handleLongPressGestureEnded(gesture: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let stackView = self.iconsContainerView.subviews.first
            stackView?.subviews.forEach({ (imageView) in
                imageView.transform = CGAffineTransform.identity
            })
            self.iconsContainerView.transform = CGAffineTransform(translationX: 0, y: self.iconHeight / 2 - 10)
            self.iconsContainerView.alpha = 0
            
        }) { (_) in
            if let selectedReaction = self.selectedReaction {
                self.select(reaction: selectedReaction)
            }
        }
    }
}

