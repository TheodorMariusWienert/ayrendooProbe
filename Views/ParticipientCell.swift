//
//  ParticipientCell.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 16.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import UIKit

class ParticipientCell: UITableViewCell {

    let participient: UILabel = {
        let label = UILabel()
        label.backgroundColor = .green
        label.font = UIFont.boldSystemFont(ofSize: 18)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Participient"
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .orange
        addSubview(participient)
        participient.leftAnchor.constraint(equalToSystemSpacingAfter: self.leftAnchor, multiplier: 0)
        participient.rightAnchor.constraint(equalToSystemSpacingAfter: self.rightAnchor, multiplier: 0)
        participient.bottomAnchor.constraint(equalToSystemSpacingBelow: self.bottomAnchor, multiplier: 0)
        participient.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(user: User) {
//        let label = UILabel()
//        label.backgroundColor = .green
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.layer.cornerRadius = 25
//        label.layer.masksToBounds = true
//        label.autoresizesSubviews = true
//        label.contentMode = .scaleAspectFill
        participient.text = user.username
//        addSubview(participient)
        
//        label.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: self.leftAnchor, paddingTop: 0, paddingLeft: 18, paddingBottom: 0, paddingRight: 6, width: 50, height: 50)

    }
}
