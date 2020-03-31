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
    @Environment(\.editMode) var mode
    @State private var symbols: FavoriteSymbols = [:]
    @State private var selectedSymbols: FavoriteSymbols = [:]

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
                        CategoryFavoriteSymbolsView(category: section, symbols: self.symbols[section, default: []],
                                                    selectedFavoriteSymbols: self.$selectedSymbols)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    }
                }
                Spacer()
            }
            .navigationBarItems(trailing: self.navigationBarItems)
            .onAppear {
                self.reloadData()
            }
        }
    }

    private var navigationBarItems: some View {
        HStack(spacing: 16) {
            if mode?.wrappedValue == .active {
                Button(action: {
                    self.store.delete(self.selectedSymbols) { _ in
                        self.selectedSymbols = [:]
                        self.mode?.wrappedValue = .inactive
                        self.reloadData()
                    }
                }) {
                    Image(systemName: "trash")
                }
                Button(action: {
                    self.mode?.animation().wrappedValue = .inactive
                }) {
                    Image(systemName: "xmark")
                }
            } else if symbols.count > 0 {
                Spacer()
                EditButton()
            }
        }
    }
}

struct CategoryFavoriteSymbolsView: View {
    let category: FavoriteSymbolKey
    let symbols: [SFSymbolCategory.Symbol]
    @Binding var selectedFavoriteSymbols: FavoriteSymbols
    private var selectedCategoryFavoriteSymbols: [SFSymbolCategory.Symbol] {
        selectedFavoriteSymbols[category, default: []]
    }

    var body: some View {
        VStack {
            ForEach(self.symbols, id: \.name) { symbol in
                Button(action: {
                    if self.selectedFavoriteSymbols[self.category]?.contains(symbol) ?? false {
                        self.selectedFavoriteSymbols[self.category]?.removeAll(where: { $0 == symbol })
                    } else {
                        self.selectedFavoriteSymbols[self.category, default: []].append(symbol)
                    }
                }) {
                    CategoryFavoriteSymbolView(symbol: symbol,
                                               isSelected: self.selectedCategoryFavoriteSymbols.contains(symbol))
                }
            }
        }
        .frame(height: self.height)
    }

    private var height: CGFloat {
        CGFloat(rowHeight) * CGFloat(symbols.count)
    }
}

struct CategoryFavoriteSymbolView: View {
    @Environment(\.editMode) var mode

    let symbol: SFSymbolCategory.Symbol
    var isSelected: Bool
    var body: some View {
        HStack {
            Image(systemName: symbol.name)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
            Text(symbol.name)
                .font(.title)
                .foregroundColor(Color.black)
                .padding(.leading, 16)
            Spacer()
            if self.mode?.wrappedValue != .active {
                EmptyView()
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .environment(\.imageScale, .large)
            } else {
                Image(systemName: "checkmark.circle")
                    .environment(\.imageScale, .large)
            }
        }
        .frame(height: rowHeight)
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
