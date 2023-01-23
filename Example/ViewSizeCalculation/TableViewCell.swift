//
//  TableViewCell.swift
//  ViewSizeCalculation_Example
//
//  Created by strayRed on 2023/1/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.numberOfLines = 0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
