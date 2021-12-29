import XCTest
import Foundation
import MicroColorQuantizer
import MicroPNG

final class MicroQuantizeTests: XCTestCase {
    func testRGBUncompressedEncoder() throws {
        var testImageData: [UInt32] = Array(repeating: 0, count: 256 * 256)

        var index = 0
        for y: UInt32 in 0 ..< 256 {
            for x: UInt32 in 0 ..< 256 {
                testImageData[index] = 0xFF000000 | (x << 16) | (y << 8) | (255 - y)

                index += 1
            }
        }

        let quantizer = MicroColorQuantizer()

        let testSet: [Int] = [
            4,
            8,
            16,
            32,
            33,
            64,
            128,
            256,
            427,
            512,
            743,
            1024
        ]

        let pngEncoder = MicroPNG()

        for testMaximumNumberOfColors in testSet {
            let quantizedData = quantizer.quantize(bitmap: testImageData, width: 256, height: 256, maximumNumberOfColors: testMaximumNumberOfColors)

            let pngData = try! pngEncoder.encodeARGBUncompressed(data: quantizedData, width: 256, height: 256)

            let testData = try Data(contentsOf: Bundle.module.url(forResource: "Data/quantizedTo\(testMaximumNumberOfColors)", withExtension: "png")!)

            XCTAssertEqual(pngData, [UInt8](testData))
        }
    }
}
