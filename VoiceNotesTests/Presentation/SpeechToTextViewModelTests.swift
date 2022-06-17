//
//  SpeechToTextViewModelTests.swift
//  VoiceNotesTests
//
//  Created by nhatnt on 30/05/2022.
//

import XCTest

class SpeechToTextViewModelTests: XCTestCase {
    let expectedVoiceNote = VoiceNote(name: "1", content: "test1", createdAt: Date())
    
    func test_whenSaveEmptyVoiceNoting_thenGetError() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        let viewModel = DefaultSpeechToTextViewModel(speechRepository: speechToTextRepository)
        
        // when
        viewModel.didSaveVoiceNote(content: "")
        
        // then
        XCTAssertTrue(viewModel.error.value.count > 0)
    }
    
    func test_whenSaveVoiceNoting_thenSaveToStorage() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        speechToTextRepository.expectation = self.expectation(description: "save voice note")
        let viewModel = DefaultSpeechToTextViewModel(speechRepository: speechToTextRepository)
        
        // when
        viewModel.didSaveVoiceNote(content: expectedVoiceNote.content)
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_whenStopVoiceNoting() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        speechToTextRepository.expectation = self.expectation(description: "Stop voice noting")
        let viewModel = DefaultSpeechToTextViewModel(speechRepository: speechToTextRepository)
        
        // when
        viewModel.stopVoiceNoting()
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
    }
}
