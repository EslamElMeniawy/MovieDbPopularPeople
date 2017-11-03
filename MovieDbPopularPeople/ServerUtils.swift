//
//  ServerUtils.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/3/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit

struct ServerUtils {
    static let API_URL = "https://api.themoviedb.org/3/"
    static let API_KEY = "084f18e0d3ad3bd4f99dd98a07422acf"
    
    //
    // Full API urls functions.
    //
    
    static func getConfigurationUrl() -> String {
        return "\(API_URL)configuration?api_key=\(API_KEY)"
    }
    
    static func getPopularPeopleUrl(page: Int) -> String {
        return "\(API_URL)person/popular?api_key=\(API_KEY)&language=en-US&page=\(page)"
    }
    
    static func getSearchPeopleUrl(query: String, page: Int) -> String {
        return "\(API_URL)search/person?api_key=\(API_KEY)&language=en-US&query=\(query)&page=\(page)&include_adult=true"
    }
    
    static func getPersonDetailsUrl(id: Int) -> String {
        return "\(API_URL)person/\(id)?api_key=\(API_KEY)&language=en-US&append_to_response=images"
    }
    
    static func getImageUrl(fileSize: String, filePath: String) -> String {
        return "\(PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_BASE_URL) as? String ?? "")\(fileSize)\(filePath)"
    }
}
