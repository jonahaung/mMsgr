//
//  GuideController.swift
//  mMsgr
//
//  Created by jonahaung on 4/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

class GuideController: UIViewController, MainCoordinatorDelegatee {
    
    struct GuideItem {
        let text: String?
        let detatilText: String?
    }
    
    var items = [GuideItem]()
    
    let tableView: UITableView = {
        let x = UITableView(frame: .zero, style: .plain)

        x.register(GuideCell2.self)
        x.estimatedRowHeight = 200
        x.rowHeight = UITableView.automaticDimension
        return x
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        items = [
            GuideItem(text: "Translate", detatilText: """
In the Conversation View, click the top-right button to toggle "Translate Mode"
"""),
            GuideItem(text: "Dictionary", detatilText: """
In the Conversation View, touch any one of the messages to reveal "Message Menu" Action Sheet.
""")
        ]
    }
}
// Setup
extension GuideController {
    
    private func setup() {
        view.backgroundColor = UIColor.systemBackground
        navigationItem.title = "App Guide"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
}

extension GuideController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell: GuideCell2 = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.titleLabel.text = item.text
        cell.guideLabel.text = item.detatilText
        let imageName = "guide"+indexPath.row.description
        cell.guideImageView.image = UIImage(named: imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


final class GuideCell2: UITableViewCell, ReusableView {
    
    let titleLabel: UILabel = {
        let x = UILabel()
        x.font = UIFont.preferredFont(forTextStyle: .title1)
        return x
    }()
    
    
    let guideLabel: UILabel = {
        let x = UILabel()
        x.font = UIFont.preferredFont(forTextStyle: .footnote)
        x.textColor = .gray
        x.numberOfLines = 0
        return x
    }()
    
    let guideImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFit
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(guideImageView)
        contentView.addSubview(guideLabel)
        
        titleLabel.addConstraints(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        guideImageView.addConstraints(titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        guideImageView.heightAnchor.constraint(equalTo: guideImageView.widthAnchor, multiplier: 1.5).isActive = true
        
        guideLabel.addConstraints(guideImageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 50, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
}
