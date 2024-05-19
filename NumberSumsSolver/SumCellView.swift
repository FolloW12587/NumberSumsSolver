//
//  SumCellView.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct SumCellView: View {
    let num: Int
    
    @ObservedObject var viewModel: Solver
    @State private var int: Int?
    private let keyPath: ReferenceWritableKeyPath<Solver, [Int?]>
    
    init(isRow: Bool, num: Int, viewModel: Solver) {
        self.num = num
        self.viewModel = viewModel
        keyPath = isRow ? \Solver.sums.rows : \Solver.sums.columns
        let value = viewModel[keyPath: keyPath][num]
        _int = State(wrappedValue: value)
    }
    
    var body: some View {
        PositiveIntegerTextField(int: $int)
            .onChange(of: int) { newValue in
                if viewModel[keyPath: keyPath][num] != newValue {
                    viewModel[keyPath: keyPath][num] = newValue
                }
            }
            .onChange(of: viewModel[keyPath: keyPath][num]) { newValue in
                if int != newValue {
                    int = newValue
                }
            }
    }
}

#Preview {
    SumCellView(isRow: true, num: 3, viewModel: Solver(dimensions: (5, 5)))
}
