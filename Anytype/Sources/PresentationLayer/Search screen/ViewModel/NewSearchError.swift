//
//  NewSearchError.swift
//  Anytype
//
//  Created by Konstantin Mordan on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct NewSearchError: Error {
    
    let title: String
    let subtitle: String?
    
}

extension NewSearchError {
    
    static func noObjectError(searchText: String) -> NewSearchError {
        NewSearchError(
            title: "\("There is no object named".localized) \"\(searchText)\"",
            subtitle: "Try to create a new one or search for something else".localized
        )
    }
    
}
