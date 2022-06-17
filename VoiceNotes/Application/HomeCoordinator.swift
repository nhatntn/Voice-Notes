//
//  HomeCoordinator.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import Foundation

class HomeCoordinator: Coordinator {
    private lazy var appConfiguration = AppConfiguration()
    fileprivate let navigator: UINavigationController
    
    init(navigator: UINavigationController) {
        self.navigator = navigator
    }
    
    func start() {
        let homeVC = HomeViewController.create(with: makeHomeViewModel())
        homeVC.delegate = self
        navigator.pushViewController(homeVC, animated: true)
    }
    
    // MARK: - Persistent Storage
    private lazy var voiceNotesStorage: VoiceNotesStorage = CoreDataVoiceNotesStorage()
    
    // MARK: - Services
    private lazy var audioService = AudioService.sharedInstance
    private lazy var speechToTextService: SpeechToTextService = {
        let config = RecognitionServiceConfig(baseURL: appConfiguration.speechBaseURL,
                                              apiKey: appConfiguration.apiKey)
        return SpeechToTextService(config: config)
    }()
    private lazy var textToSpeechService: TextToSpeechService = {
        let config = RecognitionServiceConfig(baseURL: appConfiguration.textToSpeechBaseURL,
                                              apiKey: appConfiguration.apiKey)
        return TextToSpeechService(config: config)
    }()
    
    // MARK: - Repositories
    func makeSpeechToTextRepository() -> SpeechToTextRepository {
        let dependencies = DefaultSpeechToTextRepository.Dependencies(speechToTextService: speechToTextService,
                                                                      voiceNotesStorage: voiceNotesStorage)
        return DefaultSpeechToTextRepository(dependencies: dependencies)
    }
    
    func makeTextToSpeechRepository() -> TextToSpeechRepository {
        let dependencies = DefaultTextToSpeechRepository.Dependencies(textToSpeechService: textToSpeechService)
        return DefaultTextToSpeechRepository(dependencies: dependencies)
    }
    
    func makeAudioRepository() -> AudioRepository {
        let dependencies = DefaultAudioRepository.Dependencies(audioService: audioService)
        return DefaultAudioRepository(dependencies: dependencies)
    }
    
    // MARK: - Home
    func makeHomeViewModel() -> HomeViewModel {
        let speechToTextRepository = makeSpeechToTextRepository()
        let actions = HomeViewModelActions(showDetails: navigateVoiceNoteDetail)
        return DefaultHomeViewModel(speechRepository: speechToTextRepository,
                                    actions: actions)
    }
    
    // MARK: - Speech To Text
    func makeSpeechToTextViewModel() -> SpeechToTextViewModel {
        let speechToTextRepository = makeSpeechToTextRepository()
        return DefaultSpeechToTextViewModel(speechRepository: speechToTextRepository)
    }
    
    // MARK: - Voice Note Detail
    func makeVoiceNoteDetailViewModel(voiceNote: VoiceNote) -> VoiceNoteDetailViewModel {
        let textToSpeechRepository = makeTextToSpeechRepository()
        return DefaultVoiceNoteDetailViewModel(voiceNote: voiceNote, speechRepository: textToSpeechRepository)
    }
}

extension HomeCoordinator: HomeVCNavigationDelegate {
    func navigateSpeechToText() {
        let speechToTextVC = SpeechToTextViewController.create(with: makeSpeechToTextViewModel(),
                                                               audioRepository: makeAudioRepository())
        navigator.pushViewController(speechToTextVC, animated: true)
    }
    
    func navigateVoiceNoteDetail(voiceNote: VoiceNote) {
        let speechToTextVC = VoiceNoteDetailViewController.create(with: makeVoiceNoteDetailViewModel(voiceNote: voiceNote))
        navigator.pushViewController(speechToTextVC, animated: true)
    }
}
