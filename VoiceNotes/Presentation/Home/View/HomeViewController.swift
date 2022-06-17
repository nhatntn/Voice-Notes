//
//  HomeViewController.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import Foundation

protocol HomeVCNavigationDelegate: class {
    func navigateSpeechToText()
    func navigateVoiceNoteDetail(voiceNote: VoiceNote)
}

class HomeViewController: UIViewController, StoryboardInstantiable {
    @IBOutlet weak var speechToTextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func didTapSpeechToText(_ sender: Any) {
        delegate?.navigateSpeechToText()
    }
    
    var delegate: HomeVCNavigationDelegate?
    
    // MARK: - Lifecycle
    static func create(with viewModel: HomeViewModel) -> HomeViewController {
        let view = HomeViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData()
    }
    
    // MARK: - Private
    private var viewModel: HomeViewModel!
    
    private func bind(to viewModel: HomeViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
    }
    
    func setupViews() {
        title = "Voice Notes"
        setupTableViews()
    }
    
    private func setupTableViews() {
        tableView.estimatedRowHeight = HomeListItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateItems() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeListItemCell.reuseIdentifier,
                                                       for: indexPath) as? HomeListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(HomeListItemCell.self) with reuseIdentifier: \(HomeListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }

        cell.fill(with: viewModel.items.value[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
