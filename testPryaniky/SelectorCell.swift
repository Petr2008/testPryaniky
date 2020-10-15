//
//  SelectorCell.swift
//  testPryaniky
//
//  Created by Petr Gusakov on 15.10.2020.
//

import UIKit

class SelectorCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
