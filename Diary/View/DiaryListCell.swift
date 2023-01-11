//
//  DiaryListCell.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2022/12/20.
//

import UIKit

final class DiaryListCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)

        return label
    }()

    let creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)

        return label
    }()

    let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.required, for: .horizontal)

        return imageView
    }()

    let bodyPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return label
    }()

    lazy var subtitleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [creationDateLabel, weatherIconImageView, bodyPreviewLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4

        return stackView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
        configureHierarchy()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.accessoryType = .disclosureIndicator
    }

    private func configureHierarchy() {
        contentView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            weatherIconImageView.heightAnchor.constraint(lessThanOrEqualTo: creationDateLabel.heightAnchor),
            weatherIconImageView.widthAnchor.constraint(equalTo: weatherIconImageView.heightAnchor)
        ])
    }
}

extension DiaryListCell: ReusableCell { }
