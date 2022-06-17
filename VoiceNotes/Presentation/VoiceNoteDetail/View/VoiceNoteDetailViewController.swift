//
//  VoiceNoteDetailViewController.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation
import UIKit
import AVFoundation

class VoiceNoteDetailViewController: UIViewController, StoryboardInstantiable {
    private var viewModel: VoiceNoteDetailViewModel!
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBAction func didTapPlay(_ sender: Any) {
        isPlaying = !isPlaying
        if isPlaying {
            self.audioPlayer?.play()
            self.buttonPlay.setImage(UIImage(named: "pause-button"), for: .normal)
            return
        }
        self.audioPlayer?.pause()
        self.buttonPlay.setImage(UIImage(named: "play-button"), for: .normal)
    }
    
    // MARK: - Lifecycle
    static func create(with viewModel: VoiceNoteDetailViewModel) -> VoiceNoteDetailViewController {
        let view = VoiceNoteDetailViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.sendTextToTTS()
        bind(to: viewModel)
        setupViews()
    }
    
    // MARK: - Private
    private func setupViews() {
        setupPlayButton()
        setupTextViews()
    }
    
    private func setupPlayButton() {
        self.buttonPlay.setImage(UIImage(named: "play-button"), for: .normal)
    }
    
    private func setupTextViews() {
        self.textView.isEditable = false
        self.textView.backgroundColor = .clear
    }
    
    private func bind(to viewModel: VoiceNoteDetailViewModel) {
        viewModel.data.observe(on: self) { [weak self] data in
            guard let data = data else {
                return
            }
            self?.loadAudioData(with: data)
        }
        viewModel.voiceNoteData.observe(on: self) { [weak self] data in
            guard let data = data else {
                return
            }
            self?.textView.text = data.content
        }
    }
    
    private func loadAudioData(with audioData: Data) {
        DispatchQueue.main.async {
            do {
                self.audioPlayer = try AVAudioPlayer(data: audioData)
                self.audioPlayer?.delegate = self
            } catch let error {
                self.showError("Error occurred while playing audio: \(error.localizedDescription)")
            }
        }
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        let alert = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension VoiceNoteDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.audioPlayer?.stop()
            self.buttonPlay.setImage(UIImage(named: "play-button"), for: .normal)
            self.isPlaying = false
        }
    }
}
