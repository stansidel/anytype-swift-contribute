//
//  AudioBlockContentView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels
import AnytypeCore


final class AudioBlockContentView: UIView, UIContentView {
    private var currentConfiguration: AudioBlockContentConfiguration
    var configuration: UIContentConfiguration {
        get {
            self.currentConfiguration
        }
        set {
            guard let configuration = newValue as? AudioBlockContentConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }

            self.currentConfiguration = configuration
            apply(configuration: configuration)
        }
    }

    // MARK: - Views
    let audioPlayerView: AudioPlayerView
    let backgroundView = UIView()

    // MARK: - Lifecycle

    init(configuration: AudioBlockContentConfiguration) {
        self.currentConfiguration = configuration
        self.audioPlayerView = AudioPlayerView(audioId: configuration.audioId)

        super.init(frame: .zero)

        setup()
        setupLayout()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
    }

    private func setupLayout() {
        addSubview(backgroundView) {
            $0.pinToSuperview(insets: Layout.blockBackgroundPadding)
        }

        addSubview(audioPlayerView) {
            $0.pinToSuperview(insets: Layout.blockContentPadding)
        }
    }

    private func apply(configuration: AudioBlockContentConfiguration) {
        audioPlayerView.playerItem = configuration.playerItem
        audioPlayerView.trackNameLabel.setText(configuration.file.metadata.name)
        audioPlayerView.trackNameLabel.textColor = .textPrimary
        audioPlayerView.updateAudioInformation()
    }
}

private extension AudioBlockContentView {
    enum Layout {
        static let blockContentPadding: UIEdgeInsets = .init(top: 10, left: 20, bottom: -10, right: -10)
        static let blockBackgroundPadding: UIEdgeInsets = .init(top: 10, left: 0, bottom: -10, right: 0)
    }
}
