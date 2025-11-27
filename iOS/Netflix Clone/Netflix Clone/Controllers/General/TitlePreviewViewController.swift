//
//  TitlePreviewViewController.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/25.
//

import UIKit

class TitlePreviewViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var videoPlayerViewController: CustomVideoPlayerViewController = {
        let vc = CustomVideoPlayerViewController()
        return vc
    }()

    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(videoContainerView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(downloadButton)

        setupVideoPlayer()
        configureConstraints()
        setupOrientationObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Force back to portrait when leaving
        if isLandscape() {
            if let windowScene = view.window?.windowScene {
                let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                windowScene.requestGeometryUpdate(geometryPreferences)
            }
        }

        // Show navigation bar and tab bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.updateUIForOrientation()
        }
    }

    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func orientationDidChange() {
        updateUIForOrientation()
    }

    private func updateUIForOrientation() {
        let isLandscape = isLandscape()

        if isLandscape {
            // Landscape: Video fills entire screen
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)

            // Hide navigation bar and tab bar
            navigationController?.setNavigationBarHidden(true, animated: true)
            tabBarController?.tabBar.isHidden = true

            UIView.animate(withDuration: 0.3) {
                self.titleLabel.alpha = 0
                self.overviewLabel.alpha = 0
                self.downloadButton.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            // Portrait: Normal layout
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)

            // Show navigation bar and tab bar
            navigationController?.setNavigationBarHidden(false, animated: true)
            tabBarController?.tabBar.isHidden = false

            UIView.animate(withDuration: 0.3) {
                self.titleLabel.alpha = 1
                self.overviewLabel.alpha = 1
                self.downloadButton.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }

    private func isLandscape() -> Bool {
        if let windowScene = view.window?.windowScene {
            let orientation = windowScene.interfaceOrientation
            return orientation.isLandscape
        }
        return false
    }

    private func setupVideoPlayer() {
        addChild(videoPlayerViewController)
        videoContainerView.addSubview(videoPlayerViewController.view)
        videoPlayerViewController.view.frame = videoContainerView.bounds
        videoPlayerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoPlayerViewController.didMove(toParent: self)
    }

    private func configureConstraints() {
        // Portrait constraints
        portraitConstraints = [
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            downloadButton.widthAnchor.constraint(equalToConstant: 140),
            downloadButton.heightAnchor.constraint(equalToConstant: 40),
        ]

        // Landscape constraints - video fills entire screen
        landscapeConstraints = [
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]

        // Activate portrait constraints by default
        NSLayoutConstraint.activate(portraitConstraints)
    }
    
    func config(with model: TitlePreviewViewModel) {
        titleLabel.text = model.title
        overviewLabel.text = model.titleOverview

        // Search for video based on movie title
        Task {
            let movieTitle = model.title

            // Check cache first
            if let cachedURL = VideoCacheManager.shared.getCachedVideoURL(for: movieTitle) {
                print("✅ Using cached video URL for: \(movieTitle)")
                await MainActor.run {
                    videoPlayerViewController.configure(with: cachedURL)
                }
                return
            }

            // No cache, fetch from API
            do {
                var videoURL: String?

                // First, try searching with the exact title
                var response = try await PexelsAPIManager.shared.searchVideos(query: movieTitle, perPage: 1)

                if let video = response.videos.first {
                    videoURL = PexelsAPIManager.shared.getBestQualityVideoURL(from: video)
                } else {
                    // If no results, try generic search terms
                    let fallbackQueries = ["movie", "cinema", "film", "trailer"]

                    for query in fallbackQueries {
                        response = try await PexelsAPIManager.shared.searchVideos(query: query, perPage: 1)
                        if let video = response.videos.first {
                            videoURL = PexelsAPIManager.shared.getBestQualityVideoURL(from: video)
                            break
                        }
                    }
                }

                // Last resort: get popular videos
                if videoURL == nil {
                    let popularResponse = try await PexelsAPIManager.shared.getPopularVideos(perPage: 1)
                    if let video = popularResponse.videos.first {
                        videoURL = PexelsAPIManager.shared.getBestQualityVideoURL(from: video)
                    }
                }

                guard let finalVideoURL = videoURL else {
                    print("No video found")
                    return
                }

                // Cache the video URL
                VideoCacheManager.shared.cacheVideoURL(finalVideoURL, for: movieTitle)
                print("💾 Cached video URL for: \(movieTitle)")

                await MainActor.run {
                    videoPlayerViewController.configure(with: finalVideoURL)
                }
            } catch {
                print("Failed to fetch video: \(error)")
            }
        }
    }
}
