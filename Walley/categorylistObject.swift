//
//  categorylistObject.swift
//  Walley
//
//  Created by Milan Patel on 15/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import Foundation
import RSSelectionMenu

class categorylistObject: NSObject, UniquePropertyDelegate {
    
    // MARK: - Properties
    let id: String
    let Name: String

    init(id: String, Name: String) {
        self.id = id
        self.Name = Name
       
    }
    
    
    // MARK: - UniquePropertyDelegate
    func getUniquePropertyName() -> String {
        return "id"
    }
}
