//
//  TableCell.swift
//  TDTableViewHeaderPager
//
//  Created by Tinu Dahiya on 30/08/18.
//  Copyright © 2018 dahiyaboy. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
