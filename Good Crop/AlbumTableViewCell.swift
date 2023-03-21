//
//  AlbumTableViewCell.swift
//  Containers
//
//  Created by Haluk Isik on 8/1/15.
//  Copyright (c) 2015 Haluk Isik. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumImageCountLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
