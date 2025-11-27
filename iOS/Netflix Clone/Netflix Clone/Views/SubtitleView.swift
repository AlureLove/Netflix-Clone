//
//  SubtitleView.swift
//  Netflix Clone
//
//  Created by Jethro on 2025/11/27.
//

import UIKit

// MARK: - Subtitle Model
struct Subtitle {
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
}

// MARK: - Subtitle View
class SubtitleView: UIView {

    // MARK: - Properties
    private var subtitles: [Subtitle] = []
    private var currentSubtitle: Subtitle?
    private var isEnabled = true

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)

        // Add background for better readability
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 4

        // Optional: semi-transparent background
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true

        return label
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(subtitleLabel)
        isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
        ])

        subtitleLabel.alpha = 0
    }

    // MARK: - Public Methods

    /// Load subtitles from an array
    func loadSubtitles(_ subtitles: [Subtitle]) {
        self.subtitles = subtitles
    }

    /// Load subtitles from SRT file (simplified)
    func loadSubtitlesFromSRT(fileURL: URL) throws {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let parsedSubtitles = parseSRT(content: content)
        self.subtitles = parsedSubtitles
    }

    /// Update subtitle display based on current playback time
    func updateTime(_ currentTime: TimeInterval) {
        guard isEnabled else {
            hideSubtitle()
            return
        }

        // Find subtitle for current time
        if let subtitle = subtitles.first(where: { $0.startTime <= currentTime && $0.endTime >= currentTime }) {
            if currentSubtitle?.text != subtitle.text {
                showSubtitle(subtitle)
            }
        } else {
            if currentSubtitle != nil {
                hideSubtitle()
            }
        }
    }

    /// Enable or disable subtitles
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            hideSubtitle()
        }
    }

    /// Clear all subtitles
    func clearSubtitles() {
        subtitles.removeAll()
        hideSubtitle()
    }

    // MARK: - Private Methods

    private func showSubtitle(_ subtitle: Subtitle) {
        currentSubtitle = subtitle
        subtitleLabel.text = subtitle.text

        UIView.animate(withDuration: 0.2) {
            self.subtitleLabel.alpha = 1
        }
    }

    private func hideSubtitle() {
        currentSubtitle = nil

        UIView.animate(withDuration: 0.2) {
            self.subtitleLabel.alpha = 0
        }
    }

    // MARK: - SRT Parser (Simplified)
    private func parseSRT(content: String) -> [Subtitle] {
        var subtitles: [Subtitle] = []
        let blocks = content.components(separatedBy: "\n\n")

        for block in blocks {
            let lines = block.components(separatedBy: "\n")
            guard lines.count >= 3 else { continue }

            // Parse time line (format: 00:00:10,500 --> 00:00:13,000)
            let timeLine = lines[1]
            let timeComponents = timeLine.components(separatedBy: " --> ")
            guard timeComponents.count == 2 else { continue }

            let startTime = parseTime(timeComponents[0])
            let endTime = parseTime(timeComponents[1])

            // Get subtitle text (remaining lines)
            let text = lines[2..<lines.count].joined(separator: "\n")

            let subtitle = Subtitle(startTime: startTime, endTime: endTime, text: text)
            subtitles.append(subtitle)
        }

        return subtitles
    }

    private func parseTime(_ timeString: String) -> TimeInterval {
        // Format: 00:00:10,500
        let components = timeString.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".").components(separatedBy: ":")
        guard components.count == 3 else { return 0 }

        let hours = Double(components[0]) ?? 0
        let minutes = Double(components[1]) ?? 0
        let seconds = Double(components[2]) ?? 0

        return hours * 3600 + minutes * 60 + seconds
    }
}

// MARK: - Sample Subtitles Generator (for testing)
extension SubtitleView {
    static func generateSampleSubtitles() -> [Subtitle] {
        return [
            Subtitle(startTime: 5, endTime: 8, text: "Welcome to the video player"),
            Subtitle(startTime: 10, endTime: 13, text: "This is a subtitle example"),
            Subtitle(startTime: 15, endTime: 18, text: "Enjoy your video!"),
            Subtitle(startTime: 20, endTime: 23, text: "画中画功能已启用"),
            Subtitle(startTime: 25, endTime: 28, text: "支持多种倍速播放"),
        ]
    }
}
