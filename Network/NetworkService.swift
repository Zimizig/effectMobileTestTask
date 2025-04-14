//
//  NetworkService.swift
//  effectMobileTestTask
//
//  Created by Роман on 09.04.2025.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = URL(string: "https://dummyjson.com")!
    
    func fetchTasks() async throws -> [TodoNetworkModel] {
        let endpoint = baseURL.appendingPathComponent("todos")
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(TaskResponse.self, from: data)
        return decoded.todos
    }
}

struct TaskResponse: Decodable {
    let todos: [TodoNetworkModel]
}

struct TodoNetworkModel: Decodable, Identifiable {
    let id: Int
    let todo: String
    let completed: Bool
}
