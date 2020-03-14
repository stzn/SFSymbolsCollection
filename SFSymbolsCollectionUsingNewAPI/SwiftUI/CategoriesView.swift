//
//  CategoriesView.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/14.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct SectionHeader: View {
    let category: SFSymbolCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.categoryIconName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 8)
                Text(category.name)
                    .bold()
                    .font(.system(size: 40))

            }
            Divider()
                .background(Color.gray)
                .padding([.top, .leading, .trailing], 8)
        }
    }
}

struct CategoriesView: View {
    private let columnCount: Int = 4
    private let symbols = SFSymbolCategory.loadJSONFile()

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.symbols, id: \.name) { category in
                    self.createSFSymbolCategorySection(for: geometry, with: category)
                }.listRowInsets(EdgeInsets())
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }
        }
    }

    private func createSFSymbolCategorySection(for geometry: GeometryProxy, with category: SFSymbolCategory) -> some View {
        let size = self.size(for: geometry)
        return VStack {
            SectionHeader(category: category)
                .frame(width: geometry.size.width)
            ForEach(self.dataCollection(size: size, with: category)) { rowModel in
                self.createRow(for: size, with: rowModel)
            }
            .frame(width: geometry.size.width, height: 88, alignment: .leading)
        }
        .padding([.bottom, .top])
    }

    private func createRow(for size: CGSize, with rowModel: RowModel) -> some View {
        return HStack {
            ForEach(rowModel.items, id: \.self) { iconName in
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .leading, .trailing], 4)
                    .padding([.bottom], 8)
            }.frame(width: size.width, height: size.height)
        }
    }

    private func size(for geometry: GeometryProxy) -> CGSize {
        let size = (geometry.size.width - 24) / CGFloat(columnCount)
        return CGSize(width: size, height: size)
    }

    private func dataCollection(size: CGSize, with category: SFSymbolCategory) -> [RowModel] {
        guard size != .zero else {
            return []
        }
        let iconNames = category.iconNames
        let strideSize = columnCount
        let rowModels = stride(from: iconNames.startIndex, to: iconNames.endIndex, by: strideSize)
            .map { index -> RowModel in
                let range = index..<min(index + strideSize, iconNames.endIndex)
                let subItems = iconNames[range]
                return RowModel(items: Array(subItems))
        }
        return rowModels
    }

    private struct RowModel: Identifiable {
        let id: String
        let items: [SymbolName]
        init(items: [SymbolName]) {
            self.id = UUID().uuidString
            self.items = items
        }
    }
}
