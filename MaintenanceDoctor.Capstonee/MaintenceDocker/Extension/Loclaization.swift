//
//  Loclaization.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 21/01/2022.
//

import Foundation


extension String {
  var localized: String {
        NSLocalizedString(self, comment: " ")
    }
}
