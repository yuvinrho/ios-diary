//
//  Diary - DiaryListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class DiaryListViewController: UIViewController {
    typealias DiaryDataSource = UITableViewDiffableDataSource<Int, Diary>
    typealias DiarySnapShot = NSDiffableDataSourceSnapshot<Int, Diary>
    
    private lazy var addDiaryButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(addDiary))
        return button
    }()
    
    private lazy var diaryListTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DiaryListCell.self, forCellReuseIdentifier: DiaryListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        
        return tableView
    }()
    
    private var dataSource: DiaryDataSource!
    private var snapshot = DiarySnapShot()
    private var sampleDiaryList: [Diary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureHierarchy()
        configureDataSource()
        configureSnapshot()
    }
}

extension DiaryListViewController {
    @objc private func addDiary() {
        let newDiaryViewController = UINavigationController(rootViewController: NewDiaryViewController())
        
        newDiaryViewController.modalPresentationStyle = .fullScreen
        present(newDiaryViewController, animated: true)
    }
    
    private func configureNavigation() {
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryListCell.reuseIdentifier,
                                                           for: indexPath) as? DiaryListCell else {
                return DiaryListCell()
            }
            cell.titleLabel.text = diary.title
            cell.subtitleLabel.attributedText = self.configureSubtitleText(diary.createdDate, diary.body)
            
            return cell
        })
    }
    
    private func configureSubtitleText(_ date: Date, _ body: String) -> NSMutableAttributedString {
        let text: String = "\(date.localeFormattedText)  \(body)"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([.font: UIFont.preferredFont(forTextStyle: .callout)],
                                       range: (text as NSString).range(of: "\(date.localeFormattedText)  "))
        return attributedString
    }
    
    private func configureSnapshot() {
        let jsonDecoder = JSONDecoder()
        guard let data = NSDataAsset.init(name: "sample")?.data,
              let items = try? jsonDecoder.decode([Diary].self, from: data) else {
                  return
              }
        sampleDiaryList = items
        
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot)
    }
}

extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDiary = sampleDiaryList[indexPath.row]
        let diaryViewController = DiaryViewController(diary: selectedDiary)
        
        navigationController?.pushViewController(diaryViewController, animated: true)
    }
}
