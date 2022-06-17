//
//  HomeItemViewModel.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation

struct HomeItemViewModel: Equatable {
    let title: String
    let description: String
    let createdAt: Date
}

extension HomeItemViewModel {
    init(voiceNote: VoiceNote) {
        self.title = voiceNote.name
        self.description = voiceNote.content
        self.createdAt = voiceNote.createdAt
    }
}
