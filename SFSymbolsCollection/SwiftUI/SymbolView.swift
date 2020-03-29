//
//  SymbolView.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    private let addToFavorite = "Add to Favorite"
    private let removeFromFavorite = "Remove from Favorite"

    let category: FavoriteSymbolKey
    let symbol: SFSymbolCategory.Symbol
    let store: FavoriteSymbolStore
    @State private var isFavorite = false

    init(category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, store: FavoriteSymbolStore) {
        self.category = category
        self.symbol = symbol
        self.store = store
        self.isFavorite = symbol.isFavorite
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: self.symbol.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: proxy.size.width * 0.2)
                Text(self.symbol.name).font(.title)
                self.favoriteToggleButton
            }
        }
    }

    private var favoriteToggleButton: some View {
        Button(action: {
            if self.isFavorite {
                self.store.delete(self.category, symbol: self.symbol) { _ in
                    self.isFavorite.toggle()
                }
            } else {
                self.store.save(self.category, symbol: self.symbol) { _ in
                    self.isFavorite.toggle()
                }
            }
        }) {
            Text(self.isFavorite ? removeFromFavorite: addToFavorite)
                .foregroundColor(.white)
                .padding(8)
        }
        .background(Color.blue)
        .cornerRadius(8)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(category: FavoriteSymbolKey(iconName: "", categoryName: ""),
                   symbol: SFSymbolCategory.Symbol(name: "name", isFavorite: false),
                   store: InMemoryFavoriteSymbolStore())
    }
}
