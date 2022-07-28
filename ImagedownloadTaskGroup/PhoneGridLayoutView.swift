//
//  PhoneGridLayoutView.swift
//  ImagedownloadTaskGroup
//
//  Created by Vegesna, Vijay Varma on 7/24/22.
//

import SwiftUI

struct PhoneGridLayoutView<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(alignment: .top) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(self.getItemPosition(row: row, column: column))
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
    
    private func getItemPosition(row: Int, column: Int) -> Int {
        var index = 0
        index = row * self.columns + column
        return index
    }
}

struct PhoneGridLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneGridLayoutView(rows: 5, columns: 3) { position in
            Text("Darling really long! \(position)")
        }
    }
}
