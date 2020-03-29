//
//  SectionHeader.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
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
                    .padding(.leading, 12)
                    .padding(.trailing, 4)
                Text(category.name)
                    .bold()
                    .font(.system(size: 40))
            }
            .padding([.top], 16)
            .padding([.bottom], 8)
            Divider()
                .background(Color.black)
                .padding([.leading, .trailing], 8)
        }
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(category: SFSymbolCategory(iconName: "", name: "", symbols: []))
    }
}
