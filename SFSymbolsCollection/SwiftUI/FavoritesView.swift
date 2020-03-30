//
//  FavoritesView.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

private let rowHeight: CGFloat = 88

struct FavoritesView: View {
    @State private var symbols: FavoriteSymbols = [:]
    private var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }
    private let store: FavoriteSymbolStore

    init(store: FavoriteSymbolStore) {
        self.store = store
    }

    func reloadData() {
        store.get { result in
            if let symbols = try? result.get() {
                self.symbols = symbols
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                ForEach(self.sections, id: \.categoryName) { section in
                    VStack {
                        SectionHeader(category: section.toSFSymbolCategory())
                        CategoryFavoriteSymbolsView(symbols: self.symbols[section, default: []])
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                    }
                }
                Spacer()
            }.onAppear {
                self.reloadData()
            }
        }
    }
}

struct CategoryFavoriteSymbolsView: View {
    let symbols: [SFSymbolCategory.Symbol]
    var body: some View {
        VStack {
            ForEach(self.symbols, id: \.name) { symbol in
                HStack {
                    Image(systemName: symbol.name)
                        .resizable()
                        .scaledToFit()
                    Text(symbol.name)
                        .font(.title)
                        .padding(.leading, 16)
                    Spacer()
                }
                .frame(height: rowHeight)
            }
        }
        .frame(height: self.height)
    }

    private var height: CGFloat {
        CGFloat(rowHeight) * CGFloat(symbols.count)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = InMemoryFavoriteSymbolStore()
        store.save(FavoriteSymbolKey(iconName: "mic", categoryName: "mic"), symbol: .init(name: "mic", isFavorite: true)) {_ in}
        store.save(FavoriteSymbolKey(iconName: "mic", categoryName: "mic"), symbol: .init(name: "mic", isFavorite: true)) {_ in}
        return FavoritesView(store: store)
    }
}
