import UIKit

final class ItemWithPhoto: CollectionViewCell {
    
    lazy var imageView: UIImageView = {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.maskToBounds = true
        return $0
    }(UIImageView())
    
    lazy var unselectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = UIColor.systemBackground
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = UIColor.systemBackground
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedPoint: UIView = {
        $0.backgroundColor = UIColor.systemBlue
        return $0
    }(UIView())
    
    fileprivate let inset: CGFloat = 6
    public override func setup() {
        super.setup()
        backgroundColor = nil
        
        let unselected: UIView = UIView()
        unselected.addSubview(imageView)
        unselected.addSubview(unselectedCircle)
        backgroundView = unselected
        
        let selected: UIView = UIView()
        selected.addSubview(selectedCircle)
        selected.addSubview(selectedPoint)
        selectedBackgroundView = selected
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.frame
        imageView.cornerRadius = 15
        
        updateAppearance(forCircle: unselectedCircle)
        updateAppearance(forCircle: selectedCircle)
        updateAppearance(forPoint: selectedPoint)
        dropShadow()
    }
    
    func updateAppearance(forCircle view: UIView) {
        view.frame.size = CGSize(width: 28, height: 28)
        view.frame.origin.x = imageView.bounds.width - unselectedCircle.bounds.width - inset
        view.frame.origin.y = inset
        view.circleCorner = true
//        view.shadowColor = UIColor.black.withAlphaComponent(0.4)
//        view.shadowOffset = .zero
//        view.shadowRadius = 4
//        view.shadowOpacity = 0.2
//        view.shadowPath = UIBezierPath(roundedRect: unselectedCircle.bounds, byRoundingCorners: .allCorners, cornerRadii:   CGSize(width: unselectedCircle.bounds.width / 2, height: unselectedCircle.bounds.width / 2)).cgPath
//        view.shadowShouldRasterize = true
//        view.shadowRasterizationScale = UIScreen.main.scale
    }
    
    func updateAppearance(forPoint view: UIView) {
        view.frame.size = CGSize(width: unselectedCircle.width - unselectedCircle.borderWidth * 2, height: unselectedCircle.height - unselectedCircle.borderWidth * 2)
        view.center = selectedCircle.center
        view.circleCorner = true
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}
