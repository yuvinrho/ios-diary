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
    func toDomain() -> Weather {
        return weather[0]
    }
}

struct Weather: Hashable, Decodable {
    let description: String
    let icon: String

    init(main: String, icon: String) {
        self.description = main
        self.icon = icon
    }

    enum CodingKeys: String, CodingKey {
        case description = "main"
        case icon
    }
}
