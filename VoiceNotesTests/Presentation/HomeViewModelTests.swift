//
//  HomeViewModelTests.swift
//  VoiceNotesTests
//
//  Created by nhatnt on 30/05/2022.
//

import Foundation
import XCTest
import googleapis

class HomeViewModelTests: XCTestCase {
    private enum SpeechToTextRepositoryError: Error {
        case someError
    }
    
    let expectedVoiceNotes = [VoiceNote(name: "1", content: "test1", createdAt: Date()),
                              VoiceNote(name: "2", content: "test2", createdAt: Date()),
                              VoiceNote(name: "3", content: "test3", createdAt: Date())]
    
    func test_whenFetchDataSuccessfully_thenViewModelGetAllItems() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        speechToTextRepository.expectation = self.expectation(description: "Fetched data")
        speechToTextRepository.voiceNotes = expectedVoiceNotes
        
        let viewModel = DefaultHomeViewModel(speechRepository: speechToTextRepository)
        
        // when
        viewModel.fetchData()
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(viewModel.items.value.count == expectedVoiceNotes.count)
        let items = expectedVoiceNotes.map(HomeItemViewModel.init)
        for i in 0..<items.count {
            XCTAssertEqual(viewModel.items.value[i], items[i])
        }
    }

    func test_whenFetchDataError_thenViewModelGetError() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        speechToTextRepository.expectation = self.expectation(description: "Fetched Data")
        speechToTextRepository.error = SpeechToTextRepositoryError.someError
        
        let viewModel = DefaultHomeViewModel(speechRepository: speechToTextRepository)
        
        // when
        viewModel.fetchData()
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(viewModel.items.value.count == 0)
    }
    
    func test_whenSelectItem_thenViewModelDoSomeActions() {
        // given
        let speechToTextRepository = SpeechToTextRepositoryMock()
        speechToTextRepository.voiceNotes = expectedVoiceNotes
        let expectedSelectIndex = 0
        let expectation = self.expectation(description: "did selected item and show details with")
        let viewModel = DefaultHomeViewModel(speechRepository: speechToTextRepository,
                                             actions: HomeViewModelActions(showDetails: { [weak self] (voiceNote) in
                                                XCTAssertEqual(voiceNote, self?.expectedVoiceNotes[expectedSelectIndex])
                                                expectation.fulfill()
                                             }))
        
        // when
        viewModel.fetchData()
        viewModel.didSelectItem(at: expectedSelectIndex)
        
        // then
        waitForExpectations(timeout: 2, handler: nil)
    }
}
