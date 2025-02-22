//
//  WebSocketRepo.swift
//  CryptoMonitor
//
//  Created by Kim Nguyen on 25.02.24.
//

import Foundation

public protocol DataEncodable {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public protocol DataDecodable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONEncoder: DataEncodable {}
extension JSONDecoder: DataDecodable {}

open class WebSocketRepo<Body: Encodable, Response: Decodable>: ObservableObject {
    
    public enum WebSocketError: Error {
        case decodingFailed(Error)
        case encodingFailed(Error)
        case connectionError(Error)
        case disconnected
        case unknown
    }

    public enum Message {
        case text(String)
        case body(Body)
    }
    
    private let encoder: DataEncodable
    private let decoder: DataDecodable
    private var webSocketTask: URLSessionWebSocketTask?
    private var webSocketURL: URL
    private let urlSession: URLSession
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 5.0

    @Published public var response: Response?

    public init(url: URL, encoder: DataEncodable = JSONEncoder(), decoder: DataDecodable = JSONDecoder(), session: URLSession = .shared) {
        self.webSocketURL = url
        self.encoder = encoder
        self.decoder = decoder
        self.urlSession = session
        initializeWebSocket()
    }

    deinit {
        disconnect()
    }
    
    public func setURL(_ newURL: URL) {
        disconnect()
        self.webSocketURL = newURL
        initializeWebSocket()
    }

    private func initializeWebSocket() {
        webSocketTask = urlSession.webSocketTask(with: webSocketURL)
    }

    public func connect(autoReconnect: Bool = true) {
        guard let webSocketTask else {
            return
        }

        webSocketTask.resume()
        reconnectAttempts = 0
        
        Task {
            for try await response in receiveMessage(autoReconnect: autoReconnect) {
                await handleResponse(response)
            }
        }
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    public func sendMessage(_ message: Message) async throws {
        guard let webSocketTask else {
            throw WebSocketError.disconnected
        }
        
        do {
            switch message {
            case .text(let text):
                try await webSocketTask.send(.string(text))
            case .body(let body):
                let data = try encoder.encode(body)
                try await webSocketTask.send(.data(data))
            }
        } catch let encodingError as EncodingError {
            throw WebSocketError.encodingFailed(encodingError)
        } catch {
            throw WebSocketError.connectionError(error)
        }
    }

    @MainActor
    private func handleResponse(_ response: Response) {
        self.response = response
    }

    private func receiveMessage(autoReconnect: Bool) -> AsyncThrowingStream<Response, Error> {
        AsyncThrowingStream { continuation in
            Task {
                while let task = webSocketTask {
                    if Task.isCancelled {
                        continuation.finish(throwing: WebSocketError.disconnected)
                        return
                    }
                    
                    do {
                        let result = try await task.receive()
                        let response: Response

                        switch result {
                        case .data(let data):
                            response = try decoder.decode(Response.self, from: data)
                        case .string(let text):
                            let data = Data(text.utf8)
                            response = try decoder.decode(Response.self, from: data)
                        @unknown default:
                            throw WebSocketError.unknown
                        }
                        
                        continuation.yield(response)
                    } catch let decodingError as DecodingError {
                        continuation.yield(with: .failure(WebSocketError.decodingFailed(decodingError)))

                        if autoReconnect {
                            await reconnect()
                        }
                        break
                    } catch {
                        continuation.finish(throwing: error)
                        
                        if autoReconnect {
                            await reconnect()
                        }
                        break
                    }
                }
            }
        }
    }

    private func reconnect(after seconds: Int = 5) async {
        guard reconnectAttempts < maxReconnectAttempts else {
            return
        }

        try? await Task.sleep(for: .seconds(seconds))
        
        initializeWebSocket()
        connect()
        reconnectAttempts += 1
    }
}
