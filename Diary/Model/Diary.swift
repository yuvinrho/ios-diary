//
//  diary.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2022/12/20.
//

import Foundation

struct DiaryResponseDTO: Decodable {
    let title: String
    let body: String
    let createdAt: Double
    let weather: WeatherResponseDTO

    enum CodingKeys: String, CodingKey {
        case title
        case body
        case createdAt = "created_at"
        case weather
    }
}

extension DiaryResponseDTO {
    func toDomain() -> Diary {
        let diary = Diary(title: title,
                          body: body,
                          createdAt: Date(timeIntervalSince1970: createdAt),
                          weather: weather.toDomain())

        return diary
    }
}

struct Diary: Hashable {
    let title: String
    let body: String
    let createdAt: Date
    let uuid: UUID
    var weather: Weather?

    init(title: String, body: String, createdAt: Date, uuid: UUID = UUID(), weather: Weather? = nil) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.uuid = uuid
        self.weather = weather
    }
}

extension DiaryEntity {
    func toDomain() -> Diary {
        var diary = Diary(title: title ?? "",
                          body: body ?? "",
                          createdAt: createdAt ?? Date(),
                          uuid: uuid ?? UUID())

        guard let description = weatherDescription,
              let icon = weatherIcon else {
            return diary
        }
        diary.weather = Weather(description: description, icon: icon)

        return diary
    }
}
// M븨븨M 테스트하기에만 좋은 구조인 느낌...변경에는 강하나 이해하기 어렵다.
// 변경 될 것인가? 자주 될 것인가? 변경되지 않는데 유연하면 낭비.
// ⭐️ 유연한 구조는 필요할 때 만드는 것이 좋다. ⭐️ 리팩터링이라는 좋은 방법이 있다.
