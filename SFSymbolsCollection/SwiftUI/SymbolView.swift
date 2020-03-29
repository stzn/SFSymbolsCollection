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
                    .frame(height: proxy.size.height * 0.5)
                    .padding(.top, 30)
                    .padding(.bottom, 48)
                Text(self.symbol.name).font(.title)
                self.favoriteToggleButton
                    .frame(width: proxy.size.width * 0.8)
                    .background(Color.blue)
                    .cornerRadius(8)
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
            Text(self.isFavorite ? self.removeFromFavorite: self.addToFavorite)
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(category: FavoriteSymbolKey(iconName: "", categoryName: ""),
                   symbol: SFSymbolCategory.Symbol(name: "name", isFavorite: false),
                   store: InMemoryFavoriteSymbolStore())
    }
}
