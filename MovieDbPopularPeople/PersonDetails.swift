//
//  PersonDetails.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/3/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import Foundation

struct PersonDetails {
    let gender: Int
    let name: String
    let profilePath: String
    let birthday: String
    let placeOfBirth: String
    let deathday: String
    let homepage: String
    let alsoKnownAs: [String]
    let biography: String
    let images: [String]
    
    init(gender: Int, name: String, profilePath: String, birthday: String, placeOfBirth: String, deathday: String, homepage: String, alsoKnownAs: [String], biography: String, images: [String]) {
        self.gender = gender
        self.name = name
        self.profilePath = profilePath
        self.birthday = birthday
        self.placeOfBirth = placeOfBirth
        self.deathday = deathday
        self.homepage = homepage
        self.alsoKnownAs = alsoKnownAs
        self.biography = biography
        self.images = images
    }
}
