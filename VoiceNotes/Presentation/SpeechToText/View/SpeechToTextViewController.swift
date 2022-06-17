//
//  SpeechToText.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import UIKit
import AVFoundation

class SpeechToTextViewController: UIViewController, StoryboardInstantiable {
    @IBOutlet weak var textView: UITextView!
    
    private var viewModel: SpeechToTextViewModel!
    private var audioRepository: AudioRepository!
    
    // MARK: - Lifecycle
    static func create(with viewModel: SpeechToTextViewModel,
                       audioRepository: AudioRepository) -> SpeechToTextViewController {
        let view = SpeechToTextViewController.instantiateViewController()
        view.audioRepository = audioRepository
        view.audioRepository.delegate = view
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        setupTextView()
    }
    
    // MARK: - Private
    private func bind(to viewModel: SpeechToTextViewModel) {
        viewModel.data.observe(on: self) { [weak self] data in self?.updateView(with: data) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }
    
    private func setupTextView() {
        self.textView.delegate = self
    }
    
    @IBAction private func holdDownToRecord(_ sender: Any) {
        self.startVoiceNoting()
    }
    
    @IBAction private func holdReleaseToStopRecord(_ sender: Any) {
        self.stopVoiceNoting()
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        self.saveVoiceNote()
    }
    
    @IBAction func didTapClear(_ sender: Any) {
        self.clearVoiceNote()
    }
    
    private func startVoiceNoting() {
        print("Noting....")
        self.audioRepository?.start()
        self.viewModel.startVoiceNoting()
    }
    
    private func stopVoiceNoting() {
        print("Stop noting...")
        self.audioRepository?.stop()
        self.viewModel.stopVoiceNoting()
    }
    
    private func saveVoiceNote() {
        self.viewModel.didSaveVoiceNote(content: self.textView.text)
    }
    
    private func clearVoiceNote() {
        self.viewModel.didClearVoiceNote()
    }
    
    private func updateView(with data: String) {
        self.textView.text = data
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        let alert = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SpeechToTextViewController: AudioServiceDelegate {
    func processSampleData(_ data: Data) {
        viewModel.isVoiceNoting(with: data)
    }
}

extension SpeechToTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.viewModel.data.value = textView.text
    }
}
