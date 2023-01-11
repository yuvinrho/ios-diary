//
//  Weather.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2023/01/03.
//

import Foundation

struct WeatherResponseDTO: Decodable {
    let weather: [Weather]
}

extension WeatherResponseDTO {
    // 응답 모양, 커뮤니케이션 비용을 줄인다. 네이밍만으로는 모두 설명할 수 없다.
    func toDomain() -> Weather {
        // JSON 파일이 배열로 넘어오나, 하나의 요소만 있다.
        return weather[0]
    }
}

struct Weather: Hashable, Decodable {
    // name 추천
    let description: String // 네이밍이 어렵당...description은 이미 쓰이고 있을 수 있다. main보다는 나은 편
    let icon: String

    init(description: String, icon: String) {
        self.description = description
        self.icon = icon
    }

    enum CodingKeys: String, CodingKey {
        case description = "main"
        case icon
    }
}
