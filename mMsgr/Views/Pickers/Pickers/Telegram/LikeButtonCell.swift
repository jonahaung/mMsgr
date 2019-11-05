import UIKit

final class LikeButtonCell: UITableViewCell, ReusableView {
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        imageView?.layer.opacity = 0.8
        textLabel?.font = UIFont.systemFont(ofSize: 19)
        textLabel?.textColor = tintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
