# MicroColorQuantizer

[![Swift](https://github.com/rbruinier/SwiftMicroColorQuantizer/actions/workflows/swift.yml/badge.svg)](https://github.com/rbruinier/SwiftMicroColorQuantizer/actions/workflows/swift.yml)

This package currently offers a very simple color quantizer for bitmap. It can be used to reduce the number
of unique colors used in an image.

It does not rely on any frameworks and should work on all Swift supported platforms.

## Example usage

```swift
let width = 256
let height = 256

var imageData: [UInt32] = .init(repeating: 0, count: width * height)

var index = 0
for y: UInt32 in 0 ..< 256 {
    for x: UInt32 in 0 ..< 256 {
        imageData[index] = 0xFF000000 | (x << 16) | (y << 8) | (255 - y)

        index += 1
    }
}

let quantizer = MicroColorQuantizer()

let quantizedImageData = quantizer.quantize(bitmap: testImageData, width: width, height: height, maximumNumberOfColors: 256)
```
