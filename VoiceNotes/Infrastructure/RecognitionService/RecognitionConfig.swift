//
//  RecognitionConfig.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation

protocol RecognitionConfigurable {
    var baseURL: String { get }
    var apiKey: String { get }
}

public struct RecognitionServiceConfig: RecognitionConfigurable {
    public let baseURL: String
    public let apiKey: String
    
     public init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}
