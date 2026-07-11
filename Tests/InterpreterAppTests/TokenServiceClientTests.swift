import Foundation
import InterpreterCore
import Testing
@testable import Interpreter

@Suite(.serialized)
struct TokenServiceClientTests {
    @Test
    func fetchesStrictlyDecodedClientSecret() async throws {
        let expiration = Date(timeIntervalSince1970: 2_000_000_000)
        let client = try makeClient(statusCode: 200, body: """
        {"clientSecret":"ek_test-secret","expiresAt":2000000000}
        """)

        let secret = try await client.fetchClientSecret(
            noiseReduction: .farField,
            deviceID: "device-identifier-123"
        )

        #expect(secret == TranslationClientSecret(
            value: "ek_test-secret",
            expiresAt: expiration
        ))
        let request = try #require(URLProtocolStub.lastRequest)
        #expect(request.url?.absoluteString == "https://tokens.example.com/api/translation-token")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer pilot-token")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let requestBody = try #require(URLProtocolStub.lastRequestBody)
        let object = try #require(JSONSerialization.jsonObject(with: requestBody) as? [String: String])
        #expect(object == [
            "noiseReduction": "far_field",
            "deviceId": "device-identifier-123",
        ])
    }

    @Test
    func rejectsUnknownResponseFields() async throws {
        let client = try makeClient(statusCode: 200, body: """
        {"clientSecret":"ek_test-secret","expiresAt":2000000000,"session":"unexpected"}
        """)

        await #expect(throws: TokenServiceClientError.invalidResponse) {
            try await client.fetchClientSecret(
                noiseReduction: .nearField,
                deviceID: "device-identifier-123"
            )
        }
    }

    @Test
    func mapsUnauthorizedWithoutDecodingProviderBody() async throws {
        let client = try makeClient(statusCode: 401, body: "not-json", contentType: "text/plain")

        await #expect(throws: TokenServiceClientError.unauthorized) {
            try await client.fetchClientSecret(
                noiseReduction: .farField,
                deviceID: "device-identifier-123"
            )
        }
    }

    private func makeClient(
        statusCode: Int,
        body: String,
        contentType: String = "application/json"
    ) throws -> TokenServiceClient {
        URLProtocolStub.statusCode = statusCode
        URLProtocolStub.responseBody = Data(body.utf8)
        URLProtocolStub.contentType = contentType
        URLProtocolStub.lastRequest = nil
        URLProtocolStub.lastRequestBody = nil

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return try TokenServiceClient(
            baseURL: URL(string: "https://tokens.example.com")!,
            session: URLSession(configuration: configuration),
            accessTokenProvider: TestAccessTokenProvider(),
            now: { Date(timeIntervalSince1970: 1_900_000_000) }
        )
    }
}

private struct TestAccessTokenProvider: AccessTokenProviding {
    func accessToken() async throws -> String {
        "pilot-token"
    }
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var statusCode = 200
    nonisolated(unsafe) static var responseBody = Data()
    nonisolated(unsafe) static var contentType = "application/json"
    nonisolated(unsafe) static var lastRequest: URLRequest?
    nonisolated(unsafe) static var lastRequestBody: Data?

    override class func canInit(with _: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        Self.lastRequestBody = request.httpBody ?? request.httpBodyStream.flatMap(Self.read)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": Self.contentType]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseBody)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func read(_ stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1_024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
