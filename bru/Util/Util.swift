//
//  Util.swift
//  bru
//
//  Created by Huateng Ma on 4/13/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation

let LOG_TAG = "BruDebug";
let BASE_API_URL = "http://moyersoftware.com/bru/";
let DEBUG_MAX_LENGTH = 500;
let PREF_PROFILE = "Profile";
let PREF_NOTIFICATIONS = "Notifications";
let PREF_TUTORIAL_SHOWN = "TutorialShown";

/**
 * Checks if user is logged in.
 */
func isLoggedIn() -> Bool {
    return getUser().id != nil
}

/**
 * Saves the profile of the logged in user in preferences.
 */
func setUser(user: BRUUser) {
    var userDictionary: [String: Any] = [:]
    userDictionary["id"] = user.id
    userDictionary["name"] = user.name
    if (user.photo != nil) {
        userDictionary["photo"] = user.photo
    }
    userDictionary["email"] = user.email
    if (user.location != nil) {
        userDictionary["location"] = user.location
    }
    userDictionary["token"] = user.token
    UserDefaults.standard.set(userDictionary, forKey: PREF_PROFILE)
}

/**
 * Retrieves the profile of the logged in user from preferences.
 */
func getUser() -> BRUUser {
    return BRUUser.init(fromJSONDictionary: UserDefaults.standard.object(forKey: PREF_PROFILE) as? [String : Any])
}

/**
 * Remove the profile of the logged in user from preferences.
 */
func logout() {
    UserDefaults.standard.removeObject(forKey: PREF_PROFILE)
    UserDefaults.standard.removeObject(forKey: "LocalProfileImage")
}

func notificationsEnabled() -> Bool {
    if UserDefaults.standard.object(forKey: PREF_NOTIFICATIONS) == nil {
        return true
    }
    return UserDefaults.standard.bool(forKey: PREF_NOTIFICATIONS)
}

func setNotificationsEnabled(enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: PREF_NOTIFICATIONS)
}

func setTutorialShown() {
    UserDefaults.standard.set(true, forKey: PREF_TUTORIAL_SHOWN)
}

func isTutorialShown() -> Bool {
    return UserDefaults.standard.bool(forKey: PREF_TUTORIAL_SHOWN)
}
