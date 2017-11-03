//
//  PreferencesUtils.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/3/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit

struct PreferencesUtils {
    private static let BUNDLE_IDENTIFIER = "io.github.eslamelmeniawy.MovieDbPopularPeople"
    
    //
    // Preferences keys.
    //
    
    static let PREF_KEY_FIRST_RUN = "\(BUNDLE_IDENTIFIER).FirstRun"
    static let PREF_KEY_BASE_URL = "\(BUNDLE_IDENTIFIER).BaseUrl"
    static let PREF_KEY_PROFILE_SIZES = "\(BUNDLE_IDENTIFIER).ProfileSizes"
    
    //
    // User preferences.
    //
    
    static let preferences = UserDefaults.standard
    
    /**
     * Read value from user preferences.
     */
    static func readFromPreferences(key: String) -> Any? {
        return preferences.value(forKey: key)
    }

    
    /**
     * Write value to user preferences.
     */
    static func writeToPreferences(key: String, value: Any) -> Bool {
        preferences.set(value, forKey: key)
        return preferences.synchronize()
    }
}
