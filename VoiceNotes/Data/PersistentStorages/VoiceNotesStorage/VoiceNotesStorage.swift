//
//  VoiceNotesStorage.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation


protocol VoiceNotesStorage {
    func fetchAll(completion: @escaping (Result<[VoiceNote], Error>) -> Void)
    func save(with voiceNote: VoiceNote, completion: @escaping (Result<VoiceNote, Error>) -> Void)
}
