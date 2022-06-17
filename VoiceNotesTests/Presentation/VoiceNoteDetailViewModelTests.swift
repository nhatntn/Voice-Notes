//
//  VoiceNoteDetailViewModelTests.swift
//  VoiceNotesTests
//
//  Created by nhatnt on 30/05/2022.
//

import XCTest
import googleapis

class VoiceNoteDetailViewModelTests: XCTestCase {
    let expectedVoiceNote = VoiceNote(name: "1", content: "test1", createdAt: Date())

    func test_sendTextToTTS_thenReceiveAudioData() {
        // given
        let textToSpeechRepository = TextToSpeechRepositoryMock()
        textToSpeechRepository.expectation = self.expectation(description: "transcript from text to speech")
        let expectedAudioData = Data()
        textToSpeechRepository.audioData = expectedAudioData

        let viewModel = DefaultVoiceNoteDetailViewModel(voiceNote: expectedVoiceNote,
                                                        speechRepository: textToSpeechRepository)
        textToSpeechRepository.validateInput = { (text: String) in
            XCTAssertEqual(text, self.expectedVoiceNote.content)
        }
        
        // when
        viewModel.sendTextToTTS()
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(viewModel.data.value, expectedAudioData)
    }

}
