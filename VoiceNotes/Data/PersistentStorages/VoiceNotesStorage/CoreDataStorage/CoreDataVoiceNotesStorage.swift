//
//  CoreDataVoiceNotesStorage.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation
import CoreData

final class CoreDataVoiceNotesStorage {
    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }
}

extension CoreDataVoiceNotesStorage: VoiceNotesStorage {
    func fetchAll(completion: @escaping (Result<[VoiceNote], Error>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let request: NSFetchRequest = VoiceNoteEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(VoiceNoteEntity.createdAt),
                                                            ascending: false)]
                let result = try context.fetch(request).map { $0.toDomain() }

                completion(.success(result))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func save(with voiceNote: VoiceNote, completion: @escaping (Result<VoiceNote, Error>) -> Void) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                try self.removeDuplicates(for: voiceNote, inContext: context)
                let entity = VoiceNoteEntity(voiceNote: voiceNote, insertInto: context)
                try context.save()

                completion(.success(entity.toDomain()))
            } catch {
                completion(.failure(CoreDataStorageError.saveError(error)))
            }
        }
    }
}

// MARK: - Private
extension CoreDataVoiceNotesStorage {
    private func removeDuplicates(for voiceNote: VoiceNote, inContext context: NSManagedObjectContext) throws {
        let request: NSFetchRequest = VoiceNoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(VoiceNoteEntity.createdAt),
                                                    ascending: false)]
        let result = try context.fetch(request)
        result.filter { $0.createdAt == voiceNote.createdAt }
            .forEach { context.delete($0) }
    }
}
