//
//  HomeViewController.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/10/26.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTV
    case Popular
    case UpcomingMovies
    case TopRated
}

class HomeViewController: UIViewController {
    
    let sectionTitles: [String] = ["Trending Movies", "Trending TV", "Popular", "Upcoming Movies", "Top Rated"]
    
    // Cache data for each section
    private var sectionData: [Int: [Title]] = [:]
    
    private let homeFeedTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.dataSource = self
        homeFeedTable.delegate = self
        
        configureNavbar()
        
        let headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
        
        // Load all section data
        loadAllSections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        homeFeedTable.frame = view.bounds
    }
    
    private func configureNavbar() {
        var image = UIImage(named: "netflix_logo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .plain, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        appearance.buttonAppearance = buttonAppearance
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // MARK: - Networking
    
    private func loadAllSections() {
        Task {
            // Load all sections concurrently
            async let trendingMovies = APICaller.shared.getTrendingMovies()
            async let trendingTVs = APICaller.shared.getTrendingTVs()
            async let popularMovies = APICaller.shared.getPopularMovies()
            async let upcomingMovies = APICaller.shared.getUpcomingMovies()
            async let topRatedMovies = APICaller.shared.getTopRatedMovies()
            
            do {
                let results = try await (
                    trendingMovies,
                    trendingTVs,
                    popularMovies,
                    upcomingMovies,
                    topRatedMovies
                )
                
                // Update on main thread
                await MainActor.run {
                    self.sectionData[Sections.TrendingMovies.rawValue] = results.0
                    self.sectionData[Sections.TrendingTV.rawValue] = results.1
                    self.sectionData[Sections.Popular.rawValue] = results.2
                    self.sectionData[Sections.UpcomingMovies.rawValue] = results.3
                    self.sectionData[Sections.TopRated.rawValue] = results.4
                    
                    self.homeFeedTable.reloadData()
                }
                
                print("✅ Successfully loaded all sections")
            } catch {
                print("❌ Error loading sections: \(error)")
            }
        }
    }
    
    private func fetchTrendingMovies() {
        Task {
            do {
                let movies = try await APICaller.shared.getTrendingMovies()
                print("✅ Successfully fetched \(movies.count) trending movies")
            } catch {
                print("❌ Error fetching trending movies: \(error)")
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        // Use cached data if available
        if let titles = sectionData[indexPath.section] {
            cell.configure(with: titles)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}
