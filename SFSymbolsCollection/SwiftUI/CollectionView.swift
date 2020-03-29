//
//  CollectionView.swift
//  DogCollection
//
//  Created by Shinzan Takata on 2020/03/08.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct FlowLayout {
    let spacing: UIOffset
    let containerSize: CGSize

    init(containerSize: CGSize, spacing: UIOffset = .zero) {
        self.spacing = spacing
        self.containerSize = containerSize
    }

    var currentX = 0 as CGFloat
    var currentY = 0 as CGFloat
    var lineHeight = 0 as CGFloat

    mutating func add(element size: CGSize) -> CGRect {
        if currentX + size.width > containerSize.width {
            currentX = 0
            currentY += lineHeight + spacing.vertical
            lineHeight = 0
        }
        defer {
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing.horizontal
        }
        return CGRect(origin: CGPoint(x: currentX, y: currentY), size: size)
    }

    var size: CGSize {
        return CGSize(width: containerSize.width, height: currentY + lineHeight)
    }
}

func flowLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize] where Elements: RandomAccessCollection, Elements.Element: Identifiable {
    var state = FlowLayout(containerSize: containerSize)
    var result: [Elements.Element.ID: CGSize] = [:]
    for element in elements {
        let rect = state.add(element: sizes[element.id] ?? .zero)
        result[element.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
    }
    return result
}

struct CollectionView<Elements, Content>: View where Elements: RandomAccessCollection, Content: View, Elements.Element: Identifiable {
    var data: Elements
    var layout: (Elements, CGSize, [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize]
    let elementSize: CGSize
    var content: (Elements.Element) -> Content
    @State private var sizes: [Elements.Element.ID: CGSize] = [:]

    private func bodyHelper(containerSize: CGSize, offsets: [Elements.Element.ID: CGSize]) -> some View {
        ScrollView(.vertical) {
            ZStack(alignment: .topLeading) {
                ForEach(data) {
                    PropagateSize(content: self.content($0), id: $0.id)
                        .offset(offsets[$0.id] ?? .zero)
                        .animation(.none)
                }
                Color.clear
                    .frame(width: containerSize.width,
                           height: self.height(containerSize: containerSize, elementCount: offsets.count))
                    .fixedSize(horizontal: true, vertical: false)
            }
        }.onPreferenceChange(CollectionViewSizeKey.self) {
            self.sizes = $0
        }
    }

    private func height(containerSize: CGSize, elementCount: Int) -> CGFloat {
        let columnCount = self.columnCount(for: containerSize)
        let addition = (elementCount % columnCount == 0) ? 0 : elementSize.height
        return CGFloat(elementCount) * elementSize.height / CGFloat(columnCount) + addition
    }

    private func columnCount(for size: CGSize) -> Int {
        Int(floor(size.width / elementSize.width))
    }

    var body: some View {
        GeometryReader { proxy in
            self.bodyHelper(containerSize: proxy.size, offsets: self.layout(self.data, proxy.size, self.sizes))
        }
    }
}

struct CollectionViewSizeKey<ID: Hashable>: PreferenceKey {
    typealias Value = [ID: CGSize]

    static var defaultValue: [ID : CGSize] { [:] }
    static func reduce(value: inout [ID : CGSize], nextValue: () -> [ID : CGSize]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct ScrollViewContentSizeKey: PreferenceKey {
    typealias Value = CGSize

    static var defaultValue: CGSize { .zero }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct PropagateSize<V: View, ID: Hashable>: View {
    var content: V
    var id: ID
    var body: some View {
        content.background(GeometryReader { proxy in
            Color.clear.preference(key: CollectionViewSizeKey<ID>.self, value: [self.id: proxy.size])
        })
    }
}
