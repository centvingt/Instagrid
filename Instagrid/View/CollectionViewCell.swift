//
//  CollectionViewCell.swift
//  Instagrid
//
//  Created by Vincent Caronnet on 06/04/2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    override func layoutSubviews() {
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
    }
}
