//
//  NetworkManager.swift
//  Diary
//
//  Created by Aaron, Gundy, Rhovin on 2023/01/03.
//

import Foundation

enum NetworkError: LocalizedError {
    case responseError
    case invalidData
    case invalidURL
    case decodingError
    case unknownError

    var errorDescription: String {
        switch self {
        case .responseError:
            return "서버 응답이 없습니다."
        case .invalidData:
            return "유효하지 않은 데이터입니다."
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .decodingError:
            return "JSON 디코딩 실패 했습니다."
        case .unknownError:
            return "알 수 없는 에러입니다."
        }
    }
}
// Networkable을 채택하면 뭐하나~ 다른 게 없는데~
final class NetworkManager: Networkable {
    // 싱글톤 패턴은 안티 패턴이라고 부르는 사람도 있다.
    static let shared = NetworkManager()
    // 싱글톤을 편의만을 위해서 사용하는 것은 좋지 않다.
    private init() {}

    func fetchData(url: URL?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }

        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.unknownError))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.responseError))
                return
            }
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(data))
        }
        dataTask.resume()
    }
}
