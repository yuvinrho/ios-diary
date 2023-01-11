//
//  WeatherAPIProvider.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2023/01/10.
//

import Foundation
// NetworkManager를 갖고 decoding까지 하는 것이 좋은지? -> 그것이 일반적
enum WeatherAPIProvider: APIProvidable { // enum이라면 역할군을 더 생각
    case weatherData(coordinate: Coordinate)
    case weatherIcon(icon: String)
    // apiKey는 네트워킹에 필수적이라고 생각한다면 갖고 있게 한다. 아니라면 분리. 이것은 생각의 차이.
    private var apiKey: String? {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            // 뉘앙스는 precondition이 더 적절하다. Info에 확실히 있으리라고 생각하는데 터지면 잘못적은거니까.
            // 앱을 뜯어보면 리소스 파일이 그대로 있기 때문에 api key 보안에 약하다...
            // 유료 서비스가 있는 경우 탈취당하면 골치아프다.
            // 코드가 나을지도 모르지만...방지하는 방법은 또 찾아봐야한다.
            preconditionFailure("plist를 찾을 수 없습니다.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "Open Weather API KEY") as? String else {
            preconditionFailure("Open Weather API KEY를 찾을 수 없습니다.")
        }

        return value
    }
    // 중요한 것은 논리. 네트워킹 타입 등을 공부해볼 때 Moya(알라모파이어 윗단)의 작동방식을 관찰해보면 좋다.
    var url: URL? {
        switch self {
        case .weatherData(let coordinate):
            var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
            guard let apiKey = apiKey else {
                return nil
            }
            let latitude = URLQueryItem(name: "lat", value: coordinate.latitude.description)
            let longitude = URLQueryItem(name: "lon", value: coordinate.longitude.description)
            let appID = URLQueryItem(name: "appid", value: "\(apiKey)")
            components?.queryItems = [latitude, longitude, appID]

            return components?.url
        case .weatherIcon(let icon):
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }
    }
}
