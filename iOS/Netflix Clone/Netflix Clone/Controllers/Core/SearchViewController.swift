//
//  SearchViewController.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/10/26.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titles: [Title] = [Title]()
    
    private let discoverTable: UITableView = {
        let tableView = UITableView()
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchBar.placeholder = "Search for a Movie or TV Show"
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.tintColor = .white
        
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        discoverTable.frame = view.bounds
    }
    
    private func fetchDiscoverMovies() {
        Task { [weak self] in
            do {
                let titles = try await APICaller.shared.getDiscoverMovies()
                self?.titles = titles
                await MainActor.run {
                    self?.discoverTable.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
        
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_name ?? title.original_title ?? "unknown", posterURL: title.poster_path ?? "https://picsum.photos/200")
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        
        Task { [weak self] in
            do {
                let videoElement = try await APICaller.shared.getYoutubeTrailer(with: titleName + "trailer")
                
                await MainActor.run {
                    let vc = TitlePreviewViewController()
                    vc.config(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? "No overview available"))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
        !query.trimmingCharacters(in: .whitespaces).isEmpty,
        query.trimmingCharacters(in: .whitespaces).count >= 3,
        let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        resultsController.delegate = self
        
        Task {
            do {
                let titles = try await APICaller.shared.search(with: query)
                await MainActor.run {
                    resultsController.titles = titles
                    resultsController.searchResultsCollectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.config(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
