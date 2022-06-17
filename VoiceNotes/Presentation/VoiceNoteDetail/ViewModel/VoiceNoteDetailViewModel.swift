//
//  VoiceNoteDetailViewModel.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation

protocol VoiceNoteDetailViewModelInput {
    func sendTextToTTS()
}

protocol VoiceNoteDetailViewModelOutput {
    var data: Observable<Data?> { get }
    var voiceNoteData: Observable<VoiceNote?> { get }
}

protocol VoiceNoteDetailViewModel: VoiceNoteDetailViewModelInput, VoiceNoteDetailViewModelOutput {}

class DefaultVoiceNoteDetailViewModel: VoiceNoteDetailViewModel {
    private let textToSpeechRepository: TextToSpeechRepository
    private let voiceNote: VoiceNote
    
    // MARK: - OUTPUT
    let data: Observable<Data?> = Observable(nil)
    let voiceNoteData: Observable<VoiceNote?> = Observable(nil)
    
    // MARK: - INPUT. View event methods
    
    init(voiceNote: VoiceNote, speechRepository: TextToSpeechRepository) {
        self.textToSpeechRepository = speechRepository
        self.voiceNote = voiceNote
        self.voiceNoteData.value = voiceNote
    }

    func sendTextToTTS() {
        self.textToSpeechRepository.textToSpeech(text: self.voiceNote.content) { (data) in
            self.data.value =  data
        }
    }
}
