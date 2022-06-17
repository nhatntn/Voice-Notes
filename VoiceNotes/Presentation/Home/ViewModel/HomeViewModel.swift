//
//  HomeViewModel.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation

struct HomeViewModelActions {
    let showDetails: (VoiceNote) -> Void
}

protocol HomeViewModelInput {
    func fetchData()
    func didSelectItem(at index: Int)
}

protocol HomeViewModelOutput {
    var items: Observable<[HomeItemViewModel]> { get }
    var error: Observable<String> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
    private let spechToTextRepository: SpeechToTextRepository
    private let actions: HomeViewModelActions?
    
    init(speechRepository: SpeechToTextRepository, actions: HomeViewModelActions? = nil) {
        self.spechToTextRepository = speechRepository
        self.actions = actions
    }
    
    // MARK: - Private
    private func handle(error: Error) {
        self.error.value = error.localizedDescription
    }
    
    // MARK: - OUTPUT
    let items: Observable<[HomeItemViewModel]> = Observable([])
    let error: Observable<String> = Observable("")
    
    // MARK: - INPUT. View event methods
    func fetchData() {
        self.spechToTextRepository.fetch { (result) in
            switch result {
            case .success(let items):
                self.items.value = items.compactMap(HomeItemViewModel.init)
            case .failure(let error):
                self.handle(error: error)
            }
        }
    }
    
    func didSelectItem(at index: Int) {
        let item = self.items.value[index]
        let voiceNote = VoiceNote(name: item.title,
                                  content: item.description,
                                  createdAt: item.createdAt)
        actions?.showDetails(voiceNote)
    }
}
