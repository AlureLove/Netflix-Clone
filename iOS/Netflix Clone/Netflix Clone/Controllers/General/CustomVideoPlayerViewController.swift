//
//  CustomVideoPlayerViewController.swift
//  Netflix Clone
//
//  Created by Jethro on 2025/11/27.
//

import UIKit
import AVFoundation
import AVKit

class CustomVideoPlayerViewController: UIViewController {

    // MARK: - Properties
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    var isPlaying = false
    var currentPlaybackRate: Float = 1.0
    private var videoURL: String?

    // Fullscreen properties
    weak var parentContainerView: UIView?
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    // Picture in Picture
    private var pipController: AVPictureInPictureController?
    private var pipPossibleObservation: NSKeyValueObservation?

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private let controlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        return slider
    }()

    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "00:00"
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "00:00"
        return label
    }()

    private let playbackRateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("1.0x", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 4
        return button
    }()

    private let fullscreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.alpha = 0
        return button
    }()

    private let danmakuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        button.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let pipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        button.setImage(UIImage(systemName: "pip.enter", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.alpha = 0.5  // Show but dimmed by default
        return button
    }()

    private lazy var danmakuView: DanmakuView = {
        let view = DanmakuView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var danmakuInputView: DanmakuInputView = {
        let view = DanmakuInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    private lazy var subtitleView: SubtitleView = {
        let view = SubtitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        button.setImage(UIImage(systemName: "captions.bubble", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()

    // Gesture indicators
    private let brightnessIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 8
        view.alpha = 0
        return view
    }()

    private let brightnessLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let volumeIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 8
        view.alpha = 0
        return view
    }()

    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Gesture Properties
    private var brightnessGestureStartLocation: CGFloat = 0
    private var volumeGestureStartLocation: CGFloat = 0
    private var controlsTimer: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupActions()
        setupOrientationObserver()
        setupAudioSession()
        setupBackgroundObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = containerView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        removePeriodicTimeObserver()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.updateUIForOrientation()
        }
    }

    deinit {
        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool {
        return isLandscape()
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(containerView)
        view.addSubview(subtitleView)
        view.addSubview(danmakuView)
        view.addSubview(controlsContainerView)
        view.addSubview(loadingIndicator)
        view.addSubview(danmakuInputView)

        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(progressSlider)
        controlsContainerView.addSubview(currentTimeLabel)
        controlsContainerView.addSubview(durationLabel)
        controlsContainerView.addSubview(playbackRateButton)
        controlsContainerView.addSubview(fullscreenButton)
        controlsContainerView.addSubview(subtitleButton)
        controlsContainerView.addSubview(danmakuButton)
        controlsContainerView.addSubview(pipButton)
        controlsContainerView.addSubview(closeButton)

        view.addSubview(brightnessIndicator)
        brightnessIndicator.addSubview(brightnessLabel)

        view.addSubview(volumeIndicator)
        volumeIndicator.addSubview(volumeLabel)

        danmakuInputView.onSend = { [weak self] text in
            let danmaku = Danmaku(text: text)
            self?.danmakuView.send(danmaku)
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Controls Container
            controlsContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            controlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Play/Pause Button
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),

            // Progress Slider
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 10),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -10),
            progressSlider.bottomAnchor.constraint(equalTo: controlsContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Current Time Label
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 15),
            currentTimeLabel.centerYAnchor.constraint(equalTo: progressSlider.centerYAnchor),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50),

            // Duration Label
            durationLabel.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -15),
            durationLabel.centerYAnchor.constraint(equalTo: progressSlider.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 50),

            // Playback Rate Button
            playbackRateButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 15),
            playbackRateButton.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -15),
            playbackRateButton.widthAnchor.constraint(equalToConstant: 50),
            playbackRateButton.heightAnchor.constraint(equalToConstant: 30),

            // Fullscreen Button
            fullscreenButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -15),
            fullscreenButton.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -15),
            fullscreenButton.widthAnchor.constraint(equalToConstant: 40),
            fullscreenButton.heightAnchor.constraint(equalToConstant: 40),

            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Brightness Indicator
            brightnessIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            brightnessIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            brightnessIndicator.widthAnchor.constraint(equalToConstant: 100),
            brightnessIndicator.heightAnchor.constraint(equalToConstant: 60),

            brightnessLabel.centerXAnchor.constraint(equalTo: brightnessIndicator.centerXAnchor),
            brightnessLabel.centerYAnchor.constraint(equalTo: brightnessIndicator.centerYAnchor),

            // Volume Indicator
            volumeIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            volumeIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            volumeIndicator.widthAnchor.constraint(equalToConstant: 100),
            volumeIndicator.heightAnchor.constraint(equalToConstant: 60),

            volumeLabel.centerXAnchor.constraint(equalTo: volumeIndicator.centerXAnchor),
            volumeLabel.centerYAnchor.constraint(equalTo: volumeIndicator.centerYAnchor),

            // Danmaku View
            danmakuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            danmakuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmakuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmakuView.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -60),

            // PIP Button
            pipButton.trailingAnchor.constraint(equalTo: fullscreenButton.leadingAnchor, constant: -15),
            pipButton.centerYAnchor.constraint(equalTo: fullscreenButton.centerYAnchor),
            pipButton.widthAnchor.constraint(equalToConstant: 40),
            pipButton.heightAnchor.constraint(equalToConstant: 40),

            // Subtitle Button
            subtitleButton.trailingAnchor.constraint(equalTo: pipButton.leadingAnchor, constant: -15),
            subtitleButton.centerYAnchor.constraint(equalTo: fullscreenButton.centerYAnchor),
            subtitleButton.widthAnchor.constraint(equalToConstant: 40),
            subtitleButton.heightAnchor.constraint(equalToConstant: 40),

            // Danmaku Button
            danmakuButton.trailingAnchor.constraint(equalTo: subtitleButton.leadingAnchor, constant: -15),
            danmakuButton.centerYAnchor.constraint(equalTo: fullscreenButton.centerYAnchor),
            danmakuButton.widthAnchor.constraint(equalToConstant: 40),
            danmakuButton.heightAnchor.constraint(equalToConstant: 40),

            // Subtitle View
            subtitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subtitleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subtitleView.topAnchor.constraint(equalTo: view.topAnchor),

            // Danmaku Input View
            danmakuInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            danmakuInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            danmakuInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            danmakuInputView.heightAnchor.constraint(equalToConstant: 60),

            // Close Button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setupGestures() {
        // Tap gesture to show/hide controls
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)

        // Pan gesture for brightness and volume
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
        playbackRateButton.addTarget(self, action: #selector(playbackRateTapped), for: .touchUpInside)
        fullscreenButton.addTarget(self, action: #selector(fullscreenTapped), for: .touchUpInside)
        subtitleButton.addTarget(self, action: #selector(subtitleTapped), for: .touchUpInside)
        danmakuButton.addTarget(self, action: #selector(danmakuTapped), for: .touchUpInside)
        pipButton.addTarget(self, action: #selector(pipTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured for background playback")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }

    private func setupBackgroundObserver() {
        // Listen for app entering background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // Listen for app becoming active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        // Automatically start PIP if video is playing
        guard isPlaying,
              let pipController = pipController,
              pipController.isPictureInPicturePossible,
              !pipController.isPictureInPictureActive else {
            return
        }

        print("📱 App entering background - starting PIP automatically")
        pipController.startPictureInPicture()
    }

    @objc private func appWillEnterForeground() {
        print("📱 App entering foreground")
        // PIP will automatically stop when user returns to app
    }

    @objc private func orientationDidChange() {
        updateUIForOrientation()
    }

    private func updateUIForOrientation() {
        let isLandscape = isLandscape()

        UIView.animate(withDuration: 0.3) {
            // Toggle fullscreen/close button
            self.fullscreenButton.alpha = isLandscape ? 0 : 1
            self.closeButton.alpha = isLandscape ? 1 : 0

            // Update status bar
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    private func isLandscape() -> Bool {
        if let windowScene = view.window?.windowScene {
            let orientation = windowScene.interfaceOrientation
            return orientation.isLandscape
        }
        return false
    }

    // MARK: - Public Methods
    func configure(with urlString: String) {
        self.videoURL = urlString

        guard let url = URL(string: urlString) else { return }

        loadingIndicator.startAnimating()

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = containerView.bounds

        if let playerLayer = playerLayer {
            containerView.layer.addSublayer(playerLayer)
        }

        setupPlayerObservers()
        addPeriodicTimeObserver()
        setupPictureInPicture()

        // Load sample subtitles for demonstration
        let sampleSubtitles = SubtitleView.generateSampleSubtitles()
        subtitleView.loadSubtitles(sampleSubtitles)

        // Update UI based on current orientation
        updateUIForOrientation()
    }

    private func setupPictureInPicture() {
        guard AVPictureInPictureController.isPictureInPictureSupported(),
              let playerLayer = playerLayer else {
            print("❌ PIP not supported on this device")
            pipButton.alpha = 0.3
            pipButton.isEnabled = false
            return
        }

        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self

        // Observe PIP availability
        pipPossibleObservation = pipController?.observe(
            \AVPictureInPictureController.isPictureInPicturePossible,
            options: [.new, .initial]
        ) { [weak self] _, change in
            DispatchQueue.main.async {
                let isPossible = change.newValue ?? false
                self?.pipButton.alpha = isPossible ? 1.0 : 0.3
                self?.pipButton.isEnabled = isPossible
                print("✅ PIP is \(isPossible ? "available" : "not available")")
            }
        }
    }

    // MARK: - Player Observers
    private func setupPlayerObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.currentItem?.addObserver(
            self,
            forKeyPath: "status",
            options: [.new, .initial],
            context: nil
        )

        player?.currentItem?.addObserver(
            self,
            forKeyPath: "playbackBufferEmpty",
            options: .new,
            context: nil
        )

        player?.currentItem?.addObserver(
            self,
            forKeyPath: "playbackLikelyToKeepUp",
            options: .new,
            context: nil
        )
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.currentItem?.status == .readyToPlay {
                loadingIndicator.stopAnimating()
                if let duration = player?.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    if !seconds.isNaN && !seconds.isInfinite {
                        durationLabel.text = formatTime(seconds)
                        progressSlider.maximumValue = Float(seconds)
                    }
                }

                // Auto-play when ready
                if !isPlaying {
                    player?.play()
                    player?.rate = currentPlaybackRate
                    isPlaying = true
                    let config = UIImage.SymbolConfiguration(pointSize: 50)
                    playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
                    print("▶️ Auto-playing video")
                }
            } else if player?.currentItem?.status == .failed {
                loadingIndicator.stopAnimating()
                showError("播放失败")
            }
        } else if keyPath == "playbackBufferEmpty" {
            loadingIndicator.startAnimating()
        } else if keyPath == "playbackLikelyToKeepUp" {
            loadingIndicator.stopAnimating()
        }
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            if !currentTime.isNaN && !currentTime.isInfinite {
                self.currentTimeLabel.text = self.formatTime(currentTime)
                self.progressSlider.value = Float(currentTime)

                // Update subtitles based on current time
                self.subtitleView.updateTime(currentTime)
            }
        }
    }

    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    // MARK: - Actions
    @objc private func playPauseTapped() {
        if isPlaying {
            player?.pause()
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        } else {
            player?.play()
            player?.rate = currentPlaybackRate
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
        }
        isPlaying.toggle()
        showControlsTemporarily()
    }

    @objc private func sliderValueChanged(_ slider: UISlider) {
        let seconds = Double(slider.value)
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        currentTimeLabel.text = formatTime(seconds)
    }

    @objc private func sliderTouchBegan() {
        player?.pause()
        removePeriodicTimeObserver()
    }

    @objc private func sliderTouchEnded() {
        let seconds = Double(progressSlider.value)
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time) { [weak self] _ in
            guard let self = self else { return }
            if self.isPlaying {
                self.player?.play()
                self.player?.rate = self.currentPlaybackRate
            }
            self.addPeriodicTimeObserver()
        }
    }

    @objc private func playbackRateTapped() {
        let rates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
        if let currentIndex = rates.firstIndex(of: currentPlaybackRate) {
            let nextIndex = (currentIndex + 1) % rates.count
            currentPlaybackRate = rates[nextIndex]
        } else {
            currentPlaybackRate = 1.0
        }

        player?.rate = isPlaying ? currentPlaybackRate : 0
        playbackRateButton.setTitle("\(currentPlaybackRate)x", for: .normal)
        showControlsTemporarily()
    }

    @objc private func fullscreenTapped() {
        // Rotate to landscape
        rotateToLandscape()
    }

    @objc private func closeTapped() {
        // Rotate to portrait
        rotateToPortrait()
    }

    private func rotateToLandscape() {
        if let windowScene = view.window?.windowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("Geometry update error: \(error)")
            }
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    private func rotateToPortrait() {
        if let windowScene = view.window?.windowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                print("Geometry update error: \(error)")
            }
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    @objc private func danmakuTapped() {
        // Toggle danmaku input view
        let isVisible = danmakuInputView.alpha > 0
        UIView.animate(withDuration: 0.3) {
            self.danmakuInputView.alpha = isVisible ? 0 : 1
        }

        // Show demo danmaku for testing
        if !isVisible {
            showControlsTemporarily()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let danmaku = Danmaku(text: "欢迎使用弹幕功能！", color: .cyan)
                self.danmakuView.send(danmaku)
            }
        }
    }

    @objc private func pipTapped() {
        guard let pipController = pipController else { return }

        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }

    @objc private func subtitleTapped() {
        // Toggle subtitles on/off
        let isEnabled = subtitleView.alpha > 0
        subtitleView.setEnabled(!isEnabled)

        // Update button appearance
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let imageName = isEnabled ? "captions.bubble" : "captions.bubble.fill"
        subtitleButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)

        showControlsTemporarily()
    }

    @objc private func handleTap() {
        if controlsContainerView.alpha == 0 {
            showControlsTemporarily()
        } else {
            hideControls()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let translation = gesture.translation(in: view)

        let screenWidth = view.bounds.width
        let isLeftSide = location.x < screenWidth / 2

        switch gesture.state {
        case .began:
            if isLeftSide {
                brightnessGestureStartLocation = location.y
            } else {
                volumeGestureStartLocation = location.y
            }

        case .changed:
            if isLeftSide {
                // Adjust brightness
                let delta = (brightnessGestureStartLocation - location.y) / 200
                var brightness = UIScreen.main.brightness + delta
                brightness = max(0, min(1, brightness))
                UIScreen.main.brightness = brightness
                brightnessGestureStartLocation = location.y

                showBrightnessIndicator(brightness: brightness)
            } else {
                // Adjust volume
                let delta = (volumeGestureStartLocation - location.y) / 200
                var volume = AVAudioSession.sharedInstance().outputVolume + Float(delta)
                volume = max(0, min(1, volume))
                volumeGestureStartLocation = location.y

                // Note: Direct volume control requires MPVolumeView
                showVolumeIndicator(volume: volume)
            }

        case .ended, .cancelled:
            hideBrightnessIndicator()
            hideVolumeIndicator()

        default:
            break
        }
    }

    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        isPlaying = false
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        showControls()
    }

    // MARK: - Helper Methods
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func showControls() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 1
        }
    }

    private func hideControls() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 0
        }
    }

    private func showControlsTemporarily() {
        showControls()
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.hideControls()
        }
    }

    private func showBrightnessIndicator(brightness: CGFloat) {
        brightnessLabel.text = "亮度 \(Int(brightness * 100))%"
        UIView.animate(withDuration: 0.2) {
            self.brightnessIndicator.alpha = 1
        }
    }

    private func hideBrightnessIndicator() {
        UIView.animate(withDuration: 0.3, delay: 0.5, options: []) {
            self.brightnessIndicator.alpha = 0
        }
    }

    private func showVolumeIndicator(volume: Float) {
        volumeLabel.text = "音量 \(Int(volume * 100))%"
        UIView.animate(withDuration: 0.2) {
            self.volumeIndicator.alpha = 1
        }
    }

    private func hideVolumeIndicator() {
        UIView.animate(withDuration: 0.3, delay: 0.5, options: []) {
            self.volumeIndicator.alpha = 0
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension CustomVideoPlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP will start")
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP did start")
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP will stop")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP did stop")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PIP failed to start: \(error.localizedDescription)")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore the player UI when returning from PIP
        completionHandler(true)
    }
}
