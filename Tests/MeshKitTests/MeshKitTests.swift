@testable import MeshKit
import XCTest

final class MeshKitTests: XCTestCase {
    func testExportMesh() {
        measure(metrics: [XCTMemoryMetric()]) {
            let exp = expectation(description: "Finished")
            Task {
                let mesh = MeshKit.generate(
                    palette: .randomPalette(),
                    luminosity: .bright,
                    size: .init(width: 5, height: 5)
                )
                do {
                    let url = try await mesh.export(
                        size: .init(width: 720, height: 720),
                        colorSpace: .init(name: CGColorSpace.displayP3)
                    )
                    print(url.path)
                } catch {
                    print(error)
                }

                exp.fulfill()
            }

            wait(for: [exp], timeout: 200.0)
        }
    }
}
