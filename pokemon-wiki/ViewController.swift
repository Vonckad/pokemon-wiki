//
//  ViewController.swift
//  pokemon-wiki
//
//  Created by Vlad Ralovich on 14.08.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var model: [ResultsModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filterModel: [ResultsModel] = []
    private var isSearchEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchEmpty
    }
    
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Pokemons"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        setLayout()
        loadPokemons()
    }

    private func loadPokemons() {
        activityView.startAnimating()
        Network.loadPokemons("https://pokeapi.co/api/v2/pokemon?limit=1000&offset=0") { model in
            self.model = model.results.sorted(by: {$0.name < $1.name})
            self.activityView.stopAnimating()
        }
    }
    
    private func filterForSearch(_ searchText: String) {
        filterModel = model.filter { $0.name.lowercased().contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    private func setLayout() {
        activityView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filterModel.count : model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = isFiltering ? filterModel[indexPath.row] : model[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pokemon = isFiltering ? filterModel[indexPath.row] : model[indexPath.row]
        let alert = UIAlertController(title: "This is \(pokemon.name)", message: "\n\n\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clouse", style: .destructive, handler: nil))
        
        Network.loadImage(pokemon.url) { image in
            let image = UIImageView(image: image)
            alert.view.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                image.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                image.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
                image.widthAnchor.constraint(equalToConstant: 64),
                image.heightAnchor.constraint(equalToConstant: 64)])
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterForSearch(text)
    }
}
