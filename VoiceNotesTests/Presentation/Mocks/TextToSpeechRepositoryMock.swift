//
//  TextToSpeechRepositoryMock.swift
//  VoiceNotesTests
//
//  Created by nhatnt on 30/05/2022.
//

import Foundation
import XCTest

class TextToSpeechRepositoryMock: TextToSpeechRepository {
    var expectation: XCTestExpectation?
    var error: Error?
    var audioData = Data()
    var validateInput: ((String) -> Void)?
    
    func textToSpeech(text: String, completionHandler: @escaping (_ audioData: Data) -> Void) {
        validateInput?(text)
        completionHandler(audioData)
        expectation?.fulfill()
        return
    }
}
