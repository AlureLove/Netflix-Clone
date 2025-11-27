//
//  DanmakuView.swift
//  Netflix Clone
//
//  Created by Jethro on 2025/11/27.
//

import UIKit

// MARK: - Danmaku Model
struct Danmaku {
    let text: String
    let color: UIColor
    let fontSize: CGFloat
    let speed: TimeInterval

    init(text: String, color: UIColor = .white, fontSize: CGFloat = 16, speed: TimeInterval = 8.0) {
        self.text = text
        self.color = color
        self.fontSize = fontSize
        self.speed = speed
    }
}

// MARK: - Danmaku View
class DanmakuView: UIView {

    // MARK: - Properties
    private var danmakuLanes: [DanmakuLane] = []
    private let numberOfLanes = 6
    private var isEnabled = true

    // MARK: - Lane Model
    private class DanmakuLane {
        var isAvailable = true
        var lastDanmakuEndTime: Date?
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLanes()
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLanes()
        isUserInteractionEnabled = false
    }

    private func setupLanes() {
        for _ in 0..<numberOfLanes {
            danmakuLanes.append(DanmakuLane())
        }
    }

    // MARK: - Public Methods
    func send(_ danmaku: Danmaku) {
        guard isEnabled else { return }

        // Find available lane
        guard let laneIndex = findAvailableLane() else {
            // All lanes busy, try again later or drop
            return
        }

        let lane = danmakuLanes[laneIndex]
        lane.isAvailable = false

        // Create danmaku label
        let label = createDanmakuLabel(danmaku: danmaku, laneIndex: laneIndex)
        addSubview(label)

        // Animate
        animateDanmaku(label: label, danmaku: danmaku, lane: lane)
    }

    func enable() {
        isEnabled = true
    }

    func disable() {
        isEnabled = false
        clearAllDanmaku()
    }

    func clearAllDanmaku() {
        subviews.forEach { $0.removeFromSuperview() }
        danmakuLanes.forEach { lane in
            lane.isAvailable = true
            lane.lastDanmakuEndTime = nil
        }
    }

    // MARK: - Private Methods
    private func findAvailableLane() -> Int? {
        let now = Date()

        // First try to find a completely available lane
        if let index = danmakuLanes.firstIndex(where: { $0.isAvailable }) {
            return index
        }

        // Find lane where last danmaku has moved enough
        for (index, lane) in danmakuLanes.enumerated() {
            if let endTime = lane.lastDanmakuEndTime, now.timeIntervalSince(endTime) > 1.0 {
                lane.isAvailable = true
                return index
            }
        }

        return nil
    }

    private func createDanmakuLabel(danmaku: Danmaku, laneIndex: Int) -> UILabel {
        let label = UILabel()
        label.text = danmaku.text
        label.textColor = danmaku.color
        label.font = .systemFont(ofSize: danmaku.fontSize, weight: .medium)
        label.sizeToFit()

        // Add shadow for better visibility
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 1

        // Position at the right edge, vertically in the lane
        let laneHeight = bounds.height / CGFloat(numberOfLanes)
        let yPosition = laneHeight * CGFloat(laneIndex) + (laneHeight - label.bounds.height) / 2

        label.frame.origin = CGPoint(x: bounds.width, y: yPosition)

        return label
    }

    private func animateDanmaku(label: UILabel, danmaku: Danmaku, lane: DanmakuLane) {
        let distance = bounds.width + label.bounds.width

        UIView.animate(
            withDuration: danmaku.speed,
            delay: 0,
            options: [.curveLinear],
            animations: {
                label.frame.origin.x = -label.bounds.width
            },
            completion: { [weak self, weak lane] _ in
                label.removeFromSuperview()
                lane?.isAvailable = true
                lane?.lastDanmakuEndTime = Date()
            }
        )

        // Mark lane as busy for initial period
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            lane.lastDanmakuEndTime = Date()
        }
    }
}

// MARK: - Danmaku Input View
class DanmakuInputView: UIView {

    // MARK: - Properties
    var onSend: ((String) -> Void)?

    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "发送弹幕..."
        field.textColor = .white
        field.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        field.layer.cornerRadius = 20
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.rightViewMode = .always
        field.returnKeyType = .send
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .white
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        return button
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
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(textField)
        addSubview(sendButton)

        textField.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func sendTapped() {
        sendDanmaku()
    }

    private func sendDanmaku() {
        guard let text = textField.text, !text.isEmpty else { return }
        onSend?(text)
        textField.text = ""
        textField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension DanmakuInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendDanmaku()
        return true
    }
}
