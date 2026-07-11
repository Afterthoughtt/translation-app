import Foundation
import Testing
@testable import Interpreter

struct RuntimeConfigurationTests {
    @Test
    func acceptsHTTPSDeploymentURL() throws {
        let configuration = try RuntimeConfiguration.load(from: [
            RuntimeConfiguration.tokenServiceBaseURLKey: "https://tokens.example.com",
        ])

        #expect(configuration.tokenServiceBaseURL == URL(string: "https://tokens.example.com"))
    }

    @Test
    func acceptsLoopbackHTTPForSimulatorDevelopment() throws {
        let configuration = try RuntimeConfiguration.load(from: [
            RuntimeConfiguration.tokenServiceBaseURLKey: "http://127.0.0.1:8787",
        ])

        #expect(configuration.tokenServiceBaseURL == URL(string: "http://127.0.0.1:8787"))
    }

    @Test
    func rejectsRemotePlaintextHTTP() {
        #expect(throws: RuntimeConfigurationError.insecureTokenServiceBaseURL) {
            try RuntimeConfiguration.load(from: [
                RuntimeConfiguration.tokenServiceBaseURLKey: "http://tokens.example.com",
            ])
        }
    }
}
