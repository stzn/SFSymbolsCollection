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
                        CategoryFavoriteSymbolsView(
                            category: section,
                            symbols: self.symbols[section, default: []],
                            selectedFavoriteSymbols: self.$selectedSymbols,
                            onDelete: self.delete
                        )
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

    private func delete(_ symbols: FavoriteSymbols) {
        store.delete(self.selectedSymbols) { _ in
            self.selectedSymbols = [:]
            self.mode?.wrappedValue = .inactive
            self.reloadData()
        }
    }

    private var navigationBarItems: some View {
        HStack(spacing: 16) {
            if mode?.wrappedValue == .active {
                Button(action: {
                    self.delete(self.selectedSymbols)
                }) {
                    Image(systemName: "trash")
                }
                Button(action: {
                    self.selectedSymbols = [:]
                    self.mode?.wrappedValue = .inactive
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
    @Environment(\.editMode) var mode
    let category: FavoriteSymbolKey
    let symbols: [SFSymbolCategory.Symbol]
    @Binding var selectedFavoriteSymbols: FavoriteSymbols
    private var selectedCategoryFavoriteSymbols: [SFSymbolCategory.Symbol] {
        selectedFavoriteSymbols[category, default: []]
    }
    var onDelete: (FavoriteSymbols) -> Void

    var body: some View {
        VStack {
            ForEach(self.symbols, id: \.name) { symbol in
                Button(action: {
                    self.configureSelect(symbol)
                }) {
                    CategoryFavoriteSymbolView(
                        symbol: symbol,
                        isSelected: self.selectedCategoryFavoriteSymbols.contains(symbol))
                }
            }
            // this works if you change VStack to List, but it comes not to work multi selection on Edit Mode.
            .onDelete(perform: self.delete(at:))
        }
        .frame(height: self.height)
    }

    private func configureSelect(_ symbol: SFSymbolCategory.Symbol) {
        guard self.mode?.wrappedValue == .active else {
            return
        }
        if self.selectedFavoriteSymbols[self.category]?.contains(symbol) ?? false {
            self.selectedFavoriteSymbols[self.category]?.removeAll(where: { $0 == symbol })
        } else {
            self.selectedFavoriteSymbols[self.category, default: []].append(symbol)
        }
    }

    private func delete(at offsets: IndexSet) {
        onDelete([category: offsets.map { self.symbols[$0] }])
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
            if self.mode?.wrappedValue != .active {
                EmptyView()
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .environment(\.imageScale, .large)
                    .padding(.trailing, 16)
            } else {
                Image(systemName: "circle")
                    .environment(\.imageScale, .large)
                    .padding(.trailing, 16)
            }
            Image(systemName: symbol.name)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
            Text(symbol.name)
                .font(.title)
                .foregroundColor(Color.black)
                .padding(.leading, 16)
            Spacer()
        }
        .frame(height: rowHeight)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = InMemoryFavoriteSymbolStore()
        store.save(
            FavoriteSymbolKey(iconName: "mic", categoryName: "mic"),
            symbol: .init(name: "mic", isFavorite: true)
        ) { _ in }
        store.save(
            FavoriteSymbolKey(iconName: "mic", categoryName: "mic"),
            symbol: .init(name: "mic", isFavorite: true)
        ) { _ in }
        return FavoritesView(store: store)
    }
}
