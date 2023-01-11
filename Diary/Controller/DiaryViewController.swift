//
//  DiaryViewController.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2022/12/21.
//

import UIKit
import CoreLocation
// 변경의 이유는 단 하나여야한다. 여러개면 잘못된 것 -> 즉 응집도가 낮은 것.
final class DiaryViewController: UIViewController {
    private var diary: Diary
    private let networkManager: Networkable = NetworkManager.shared
    private let locationManager = CLLocationManager()
    private var weatherAPI: APIProvidable?

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().localeFormattedText

        return label
    }()

    let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()

        return imageView
    }()

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [weatherIconImageView, dateLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill

        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true

        return scrollView
    }()

    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .title3)

        return textView
    }()

    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)

        return textView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleTextView, bodyTextView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    // Bool은 확장성이 좋지 않다. 겉에 완충재 하나 달기? -> 변경으로부터 보호
    init(diary: Diary, isAuthorizationAllow: Bool = false) {
        self.diary = diary
        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCoreDataIfNeeded),
                                               name: UIScene.willDeactivateNotification,
                                               object: nil)
        // iPhone 13 mini 시뮬레이터로는 잡을 수 없다. 시행착오의 문서화가 필요하다면 노션 등...
        // 불필요한 주석은 달지않아야 하지만 주석을 꼭 배제해야하는 것은 아니다.
        guard let coordinate = locationManager.coordinate else {
            return
        }
        weatherAPI = WeatherAPIProvider.weatherData(coordinate: Coordinate(latitude: coordinate.latitude,
                                                                           longitude: coordinate.longitude))
        fetchWeather(isAuthorizationAllowed: isAuthorizationAllow)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureHierarchy()
        configureView(with: diary)
        configureLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showKeyboardIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateCoreDataIfNeeded()
    }

    private func showKeyboardIfNeeded() {
        if !titleTextView.hasText {
            titleTextView.becomeFirstResponder()
        } else if !bodyTextView.hasText {
            bodyTextView.becomeFirstResponder()
        }
    }
    // 딱 봐도 긴 메서드(가령 100줄)는 중간에 주석을 다는 것 보다 메서드를 분리해서 기능을 네이밍으로 설명하는 편이 좋다.
    // private func는 주석과 같은 효과가 있다.
    private func fetchWeather(isAuthorizationAllowed: Bool) {
        // guard -> 조기탈출, 권한이 없으면 떠난다가 의미상으로도 낫고 들여쓰기도 덜하니 가독성 Up
        guard isAuthorizationAllowed else {
            return
        }
        guard let weatherAPI = weatherAPI else {
            return
        }
        let url = weatherAPI.url

        networkManager.fetchData(url: url) { result in
            switch result {
            case .success(let data):
                // decode는 UI단의 업무가 아니다. 쪼개면 변경에 더 유연하다? 하지만 유연성은 필요할 때 주자
                guard let weatherResponseDTO = try? JSONDecoder().decode(WeatherResponseDTO.self, from: data) else {
                    return
                }
                let weather = weatherResponseDTO.toDomain()
                // 잘 쪼개면서도 찾기 쉬운, 폴더 단위...같이 일하는 놈들(협력관계), 모듈화, 내 도메인만 빌드하자
                // Feature grouping
                self.diary.weather = weather
                self.configureWeatherIconImage(weather.icon) { image in
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = image
                    }
                }
            case .failure(let error):
                print(error.errorDescription)
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

    private func configureHierarchy() {
        scrollView.addSubview(containerStackView)
        view.addSubview(scrollView)
        titleTextView.delegate = self
        bodyTextView.delegate = self
    }

    private func makeEllipsisMenu() -> UIMenu {
        let diary = diary
        let shareAction = UIAction(title: "공유",
                                   image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            self?.showActivityViewController(diary: diary)
        }
        let deleteAction = UIAction(title: "삭제",
                                    image: UIImage(systemName: "trash"),
                                    attributes: .destructive) { [weak self] _ in
            self?.showDeleteActionAlert(diary: diary) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        let cancelAction = UIAction(title: "취소",
                                    image: UIImage(systemName: "xmark")) { _ in }
        let menu = UIMenu(identifier: nil,
                          options: .displayInline,
                          children: [shareAction, deleteAction, cancelAction])

        return menu
    }

    private func configureNavigationBar() {
        navigationItem.titleView = navigationStackView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                                            menu: makeEllipsisMenu())
    }

    private func configureView(with diary: Diary) {
        titleTextView.text = diary.title
        bodyTextView.text = diary.body
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            containerStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            weatherIconImageView.widthAnchor.constraint(equalTo: weatherIconImageView.heightAnchor)
        ])
    }

    private func generateDiary() -> Diary {
        return Diary(title: titleTextView.text,
                     body: bodyTextView.text,
                     createdAt: diary.createdAt,
                     uuid: diary.uuid,
                     weather: diary.weather)
    }

    @objc
    private func updateCoreDataIfNeeded() {
        if diary.title != titleTextView.text || diary.body != bodyTextView.text {
            diary = generateDiary()
            CoreDataManager.shared.update(diary: diary)
        }
    }
}

extension DiaryViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n", textView == titleTextView, bodyTextView.text.isEmpty {
            bodyTextView.becomeFirstResponder()
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updateCoreDataIfNeeded()
    }
}

extension DiaryViewController: DiaryPresentable {}
