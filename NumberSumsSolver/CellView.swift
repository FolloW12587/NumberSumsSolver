//
//  CellView.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct CellView: View {
    let row: Int
    let column: Int
    
    @ObservedObject var viewModel: Solver
    @State private var int: Int?
    
    init(row: Int, column: Int, viewModel: Solver) {
        self.row = row
        self.column = column
        self.viewModel = viewModel
        self._int = State(wrappedValue: viewModel.board[row][column])
    }
    
    var body: some View {
        PositiveIntegerTextField(int: $int)
            .onChange(of: int) { newValue in
                if viewModel.board[row][column] != newValue {
                    viewModel.board[row][column] = newValue
                }
            }
            .onChange(of: viewModel.board[row][column]) { newValue in
                if int != newValue {
                    int = newValue
                }
            }
    }
}

#Preview {
    CellView(row: 3, column: 3, viewModel: Solver(dimensions: (5, 5)))
}
