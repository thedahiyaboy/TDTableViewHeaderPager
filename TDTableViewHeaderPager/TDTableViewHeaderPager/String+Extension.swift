//
//  String+Extension.swift
//  TDTableViewHeaderPager
//
//  Created by Tinu Dahiya on 01/09/18.
//  Copyright © 2018 dahiyaboy. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}


