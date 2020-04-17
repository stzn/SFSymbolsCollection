//
//  CategoriesView.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/14.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private let store: FavoriteSymbolStore
    private let columnCount: Int = 4
    private let categories = SFSymbolCategory.loadJSONFile()

    init(store: FavoriteSymbolStore) {
        self.store = store
    }

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.categories, id: \.name) { category in
                    self.createSFSymbolCategorySection(for: geometry, with: category)
                }.listRowInsets(EdgeInsets())
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }.navigationBarItems(trailing:
                NavigationLink(destination: FavoritesView(store: self.store)) {
                    Text("Favorite")
                }
            )
        }
    }

    private func createSFSymbolCategorySection(for geometry: GeometryProxy, with category: SFSymbolCategory) -> some View {
        VStack {
            SectionHeader(category: category)
            createSymbolsRow(size: size(for: geometry), from: category)
            // Change if want grid style layout
//            createGrid(for: geometry, from: category)
        }
    }

    private func createSymbolsRow(size: CGSize, from category: SFSymbolCategory) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(category.symbols) { symbol in
                    NavigationLink(destination: self.createSymbolView(category: category, symbol: symbol)) {
                        Image(systemName: symbol.name)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 12)
                            .frame(width: size.width, height: size.height)
                    }
                }
            }
        }
    }

    private func createGrid(size: CGSize, from category: SFSymbolCategory) -> some View {
        Grid(category.symbols) { symbol in
            NavigationLink(destination: self.createSymbolView(category: category, symbol: symbol)) {
                Image(systemName: symbol.name)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                    .frame(width: size.width, height: size.height)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height(elementSize: size,
                              elementCount: category.symbols.count))
    }

    private func height(elementSize: CGSize, elementCount: Int) -> CGFloat {
        let rows = ceil(Double(elementCount) / Double(columnCount))
        return elementSize.height * CGFloat(rows)
    }

    private func createSymbolView(category: SFSymbolCategory, symbol: SFSymbolCategory.Symbol) -> some View {
        SymbolView(category: FavoriteSymbolKey(iconName: category.iconName, categoryName: category.name),
                   symbol: symbol, store: self.store)
    }

    private func size(for geometry: GeometryProxy) -> CGSize {
        let size = floor(geometry.size.width / CGFloat(columnCount))
        return CGSize(width: size, height: size)
    }
}
