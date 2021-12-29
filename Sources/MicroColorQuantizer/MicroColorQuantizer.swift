public final class MicroColorQuantizer {
    public init() {
    }

    /**
     Provide a bitmap as an array of ARGB (32 bits per pixel) values. Alpha will be ignored but retained in the result.
     */
    public func quantize(bitmap: [UInt32], width: Int, height: Int, maximumNumberOfColors: Int) -> [UInt32] {
        let octree = Octree()

        for color in bitmap {
            octree.addColor(color)
        }

        octree.reduceColors(withMaximumNumberOfColors: maximumNumberOfColors)
        octree.averageAllColors()

        return bitmap.map {
            octree.mapColor($0)
        }
    }
}

extension MicroColorQuantizer {
    fileprivate final class Octree {
        private var rootNode: Node = Node(index: -1, level: -1)

        private var nodesPerLevel: [Node?] = Array(repeating: nil, count: 8)

        private var numberOfNodes: Int = 0
        private var numberOfLeafs: Int = 0

        // Adds a color to the tree.
        func addColor(_ color: UInt32) {
            let red = Int((color >> 16) & 0xFF)
            let green = Int((color >> 8) & 0xFF)
            let blue = Int(color & 0xFF)

            var currentNode = rootNode

            for level in (0 ... 7).reversed() {
                let index = Self.indexForColorComponents(red: red, green: green, blue: blue, level: level)

                var newNode = false

                let childNode: Node!

                if currentNode.childNodes[index] == nil {
                    childNode = Node(index: index, level: level, parent: currentNode)

                    currentNode.childNodes[index] = childNode

                    numberOfNodes += 1
                    newNode = true
                } else {
                    childNode = currentNode.childNodes[index]
                }

                if level > 0 {
                    currentNode = childNode

                    if newNode {
                        if nodesPerLevel[level] == nil {
                            nodesPerLevel[level] = childNode
                        } else {
                            childNode.nextNode = nodesPerLevel[level]

                            nodesPerLevel[level] = childNode
                        }
                    }
                } else {
                    childNode.red += red
                    childNode.green += green
                    childNode.blue += blue
                    childNode.numberOfPixels += 1

                    if newNode {
                        numberOfLeafs += 1
                    }

                    childNode.isLeaf = true
                }
            }
        }

        /**
         This will reduce colors until the number of colors remeaning is lower that the maximum allowed colors.
         */
        func reduceColors(withMaximumNumberOfColors maximumNumberOfColors: Int) {
            while numberOfLeafs > maximumNumberOfColors {
                guard let leastRelevantNode = findLeastRelevantNode() else {
                    break
                }

                reduceNode(leastRelevantNode)
            }
        }

        /**
         This should be called after color reduction. It will average the leafs.
         */
        func averageAllColors() {
            rootNode.averageColors()
        }

        /**
         After reducing & averaging of colors this function can be used to map original colors to quantized colors
         */
        func mapColor(_ color: UInt32) -> UInt32 {
            let red = Int((color >> 16) & 0xFF)
            let green = Int((color >> 8) & 0xFF)
            let blue = Int(color & 0xFF)

            var currentNode = rootNode

            for level in (0 ... 7).reversed() {
                let index = Self.indexForColorComponents(red: red, green: green, blue: blue, level: level)

                let childNode = currentNode.childNodes[index]!

                if childNode.isLeaf {
                    return (color & 0xFF000000) | UInt32((childNode.red << 16) | (childNode.green << 8) | childNode.blue)
                } else {
                    currentNode = childNode
                }
            }

            return 0
        }

        private func findLeastRelevantNode() -> Node? {
            var currentLevel = 0

            while nodesPerLevel[currentLevel] == nil {
                currentLevel += 1

                guard currentLevel < 8 else {
                    return nil
                }
            }

            return nodesPerLevel[currentLevel]
        }

        private func reduceNode(_ node: Node) {
            for i in 0 ..< 8 {
                guard let childNode = node.childNodes[i] else {
                    continue
                }

                node.numberOfPixels += childNode.numberOfPixels

                node.red += childNode.red
                node.green += childNode.green
                node.blue += childNode.blue

                numberOfLeafs -= 1
                numberOfNodes -= 1

                node.childNodes[i] = nil
            }

            node.isLeaf = true

            numberOfLeafs += 1

            nodesPerLevel[node.level] = node.nextNode
        }

        private static func indexForColorComponents(red: Int, green: Int, blue: Int, level: Int) -> Int {
            let r = (red >> level) & 1
            let g = (green >> level) & 1
            let b = (blue >> level) & 1

            return (r << 2) | (g << 1) | b
        }
    }
}

extension MicroColorQuantizer.Octree {
    private final class Node {
        weak var parent: Node?

        var childNodes: [Node?] = Array(repeating: nil, count: 8)

        var nextNode: Node? = nil

        var numberOfPixels: Int = 0

        var isLeaf: Bool = false

        var green: Int = 0
        var blue: Int = 0
        var red: Int = 0

        let index: Int
        let level: Int

        init(index: Int, level: Int, parent: Node? = nil) {
            self.index = index
            self.level = level
            self.parent = parent
        }

        func averageColors() {
            if isLeaf {
                guard numberOfPixels != 0 else {
                    return
                }

                red /= numberOfPixels
                green /= numberOfPixels
                blue /= numberOfPixels
            } else {
                for childNode in childNodes.compactMap({ $0 }) {
                    childNode.averageColors()
                }
            }
        }
    }
}
