//
//  Diary - DiaryListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation
// 이번에 역할 쪼개기 연습을 했다.
final class DiaryListViewController: UIViewController {
    typealias DiaryDataSource = UITableViewDiffableDataSource<Int, Diary>
    typealias DiarySnapShot = NSDiffableDataSourceSnapshot<Int, Diary>

    private let networkManager: Networkable = NetworkManager.shared

    private lazy var presentNewDiaryViewAction = UIAction { _ in
        let newDiary = Diary(title: "", body: "", createdAt: Date())
        let diaryViewController = DiaryViewController(diary: newDiary,
                                                      isAuthorizationAllow: self.locationManager.isAuthorized)

        self.navigationController?.pushViewController(diaryViewController, animated: true)
    }

    private lazy var addDiaryButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .add,
                                     primaryAction: presentNewDiaryViewAction)

        return button
    }()

    private lazy var diaryListTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DiaryListCell.self, forCellReuseIdentifier: DiaryListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self

        return tableView
    }()

    private var dataSource: DiaryDataSource?
    private var diaryList: [Diary] = []
    private let locationManager = CLLocationManager()

    // init에서 networkManager 주입

    override func viewDidLoad() {
        super.viewDidLoad()

        requestLocationAuthorization()
        configureNavigationBar()
        configureHierarchy()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureSnapshot()
    }
}

extension DiaryListViewController {
    private func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func configureNavigationBar() {
        navigationItem.title = "일기장"
        navigationItem.rightBarButtonItem = addDiaryButton
    }

    private func configureHierarchy() {
        view.addSubview(diaryListTableView)

        NSLayoutConstraint.activate([
            diaryListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            diaryListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            diaryListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            diaryListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func configureDataSource() {
        dataSource = DiaryDataSource(tableView: diaryListTableView, cellProvider: { tableView, indexPath, diary in
            let cell = tableView.dequeueReusableCell(cellType: DiaryListCell.self, for: indexPath)

            self.configureCell(cell, with: diary)

            return cell
        })
    }

    private func configureCell(_ cell: DiaryListCell, with diary: Diary) {
        cell.titleLabel.text = diary.title.isEmpty ? "제목 없음" : diary.title
        cell.creationDateLabel.text = diary.createdAt.localeFormattedText
        cell.bodyPreviewLabel.text = diary.body

        if let weather = diary.weather {
            self.configureWeatherIconImage(weather.icon) { image in
                DispatchQueue.main.async {
                    cell.weatherIconImageView.image = image
                }
            }
        }
    }

    private func configureWeatherIconImage(_ icon: String, _ completion: @escaping (UIImage) -> Void) {
        let url = WeatherAPIProvider.weatherIcon(icon: icon).url

        networkManager.fetchData(url: url) { result in
            switch result {
            case .success(let data):
                guard let weatherIconImage = UIImage(data: data) else {
                    return
                }
                completion(weatherIconImage)
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }

    private func fetchDiaryList() -> [Diary] {
        let fetchResults = CoreDataManager.shared.readDiaryEntity()
        let diaryList: [Diary] = fetchResults.map { $0.toDomain() }

        return diaryList
    }

    private func configureSnapshot() {
        var snapshot = DiarySnapShot()
        let sortedByLatestItems: [Diary] = fetchDiaryList().reversed()

        snapshot.appendSections([0])
        snapshot.appendItems(sortedByLatestItems)

        dataSource?.apply(snapshot)
        diaryList = sortedByLatestItems
    }
}

extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDiary = diaryList[indexPath.row]
        let diaryViewController = DiaryViewController(diary: selectedDiary)
        if let cell = tableView.cellForRow(at: indexPath) as? DiaryListCell {
            diaryViewController.weatherIconImageView.image = cell.weatherIconImageView.image
        }

        navigationController?.pushViewController(diaryViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: nil) { (_, _, success) in
            self.showActivityViewController(diary: self.diaryList[indexPath.row])
            success(true)
        }
        shareAction.backgroundColor = .systemBlue
        shareAction.image = UIImage(systemName: "square.and.arrow.up")

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in
            self.showDeleteActionAlert(diary: self.diaryList[indexPath.row]) {
                self.configureSnapshot()
            }
            success(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        swipeActionConfiguration.performsFirstActionWithFullSwipe = false

        return swipeActionConfiguration
    }
}

extension DiaryListViewController: DiaryPresentable {}
