//
//  SymbolView.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    @State private var isFavorite = false
    @State private var showCopyDoneAlert = false
    @Environment(\.colorScheme) var colorScheme

    private let addToFavorite = "Add to Favorite"
    private let removeFromFavorite = "Remove from Favorite"

    let category: FavoriteSymbolKey
    let symbol: SFSymbolCategory.Symbol
    let store: FavoriteSymbolStore

    private var imageCode: String {
        "Image(systemName: \"\(symbol.name)\")"
    }

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
                    .scaledToFit()
                    .frame(height: proxy.size.height * 0.5)
                    .padding(.top, 30)
                    .padding(.bottom, 48)
                Text(self.symbol.name).font(.title)
                self.codeView
                self.favoriteToggleButton
                    .frame(width: proxy.size.width * 0.8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }.alert(isPresented: self.$showCopyDoneAlert) {
                Alert(
                    title: Text(""), message: Text("Copy Done!"),
                    dismissButton: .default(Text("OK")) { self.showCopyDoneAlert = false })
            }
        }
    }

    private var codeView: some View {
        HStack {
            Text(imageCode)
                .padding(.vertical)
                .padding(.leading)
            Button(action: {
                UIPasteboard.general.string = self.imageCode
                self.showCopyDoneAlert = true
            }) {
                Text("Copy")
                    .foregroundColor(Color.blue)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .padding(.vertical)
            .padding(.trailing)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorScheme == .light ? Color.black : Color.white, lineWidth: 1)
        )
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
            Text(self.isFavorite ? self.removeFromFavorite : self.addToFavorite)
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(
            category: FavoriteSymbolKey(iconName: "mic", categoryName: "mic"),
            symbol: SFSymbolCategory.Symbol(name: "mic", isFavorite: false),
            store: InMemoryFavoriteSymbolStore())
    }
}
