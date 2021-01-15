//
//  FilterButton.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 24.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import UIKit

class FilterButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addTarget(self, action: #selector(selectButton), for: .primaryActionTriggered)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectButton() {
        self.isHighlighted = true
    }
    
    override var isSelected: Bool {
        didSet {
            if oldValue {
                self.backgroundColor = .superLightGray
            }
            else {
                self.backgroundColor = .secondPrimary
            }
        }
    }
    
}
