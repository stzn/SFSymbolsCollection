//
//  CategoriesView.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/14.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct SectionHeader: View {
    static let height: CGFloat = 88
    let category: SFSymbolCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.iconName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 8)
                Text(category.name)
                    .bold()
                    .font(.system(size: 40))

            }.padding(.top, 16)
            Divider()
                .background(Color.gray)
                .padding([.leading, .trailing], 8)
        }
    }
}

struct CategoriesView: View {
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
            }
        }.navigationBarItems(trailing:
            Button(action: {
            }) {
                Text("Favorite")
            }
        )
    }

    private func height(elementSize: CGSize, elementCount: Int) -> CGFloat {
        let rows = ceil(Double(elementCount) / Double(columnCount))
        return elementSize.height * CGFloat(rows) + SectionHeader.height
    }

    private func createSFSymbolCategorySection(for geometry: GeometryProxy, with category: SFSymbolCategory) -> some View {
        let size = self.size(for: geometry)
        return VStack {
            SectionHeader(category: category)
            CollectionView(data: category.symbols, layout: flowLayout, elementSize: size) { symbol in
                NavigationLink(destination: self.createSymbolView(category: category, symbol: symbol)) {
                    Image(systemName: symbol.name)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                }.frame(width: size.width, height: size.height)
            }
        }.frame(width: geometry.size.width,
                height: height(elementSize: size, elementCount: category.symbols.count))
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
