//
//  AppConfiguration.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import Foundation

final class AppConfiguration {
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String else {
            fatalError("APIKey must not be empty in plist")
        }
        return apiKey
    }()
    lazy var speechBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "SpeechToTextAPIBaseURL") as? String else {
            fatalError("SpeechToTextApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
    lazy var textToSpeechBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "TextToSpeechAPIBaseURL") as? String else {
            fatalError("TextToSpeechAPIBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
}
