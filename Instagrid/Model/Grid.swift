//
//  Grid.swift
//  Instagrid
//
//  Created by Vincent Caronnet on 06/04/2021.
//

import UIKit

struct Grid {
    var images: [UIImage?] = [nil, nil, nil, nil]

    func isComplete(_ layout: Layout) -> Bool {
        if layout == .layout2 {
            return !images.contains(nil)
        }
        return !images[0...1].contains(nil)
    }
}
