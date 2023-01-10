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

        guard let main = weatherDescription,
              let icon = weatherIcon else {
            return diary
        }
        diary.weather = Weather(main: main, icon: icon)

        return diary
    }
}
