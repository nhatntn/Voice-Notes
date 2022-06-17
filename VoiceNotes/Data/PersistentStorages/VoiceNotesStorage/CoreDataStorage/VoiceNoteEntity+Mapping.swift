//
//  VoiceNoteEntity+Mapping.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation
import CoreData

extension VoiceNoteEntity {
    convenience init(voiceNote: VoiceNote, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        name = voiceNote.name
        content = voiceNote.content
        createdAt = voiceNote.createdAt
    }
}

extension VoiceNoteEntity {
    func toDomain() -> VoiceNote {
        return .init(name: self.name ?? "",
                     content: self.content ?? "",
                     createdAt: self.createdAt ?? Date())
    }
}
