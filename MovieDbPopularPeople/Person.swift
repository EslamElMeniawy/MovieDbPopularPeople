//
//  Person.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/3/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import Foundation

struct Person {
    let id: Int
    let name: String
    let profilePath: String
    
    init(id: Int, name: String, profilePath: String) {
        self.id = id
        self.name = name
        self.profilePath = profilePath
    }
}
