//
//  PictureCell.swift
//  testPryaniky
//
//  Created by Petr Gusakov on 14.10.2020.
//

import UIKit

class PictureCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var iView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
