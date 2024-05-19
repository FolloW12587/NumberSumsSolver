//
//  BoardInputView.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct BoardInputView: View {
    @StateObject var solver: Solver
    let dismiss: () -> ()
    
    
    init(rows: Int, columns: Int, dismiss: @escaping () -> ()) {
        _solver = StateObject(wrappedValue: Solver(dimensions: (rows, columns)))
        self.dismiss = dismiss
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Button("", systemImage: "chevron.left", action: dismiss)
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            
            VStack {
                GeometryReader { proxy in
                    let maxCellSize = min(proxy.size.width / CGFloat(solver.dimensions.columns + 1), proxy.size.height / CGFloat(solver.dimensions.rows + 1))
                    let cellSize = min(50, maxCellSize)
                    let sumCellSize = cellSize * 0.8
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                            ForEach(0..<solver.dimensions.columns, id: \.self) { i in
                                SumCellView(isRow: false, num: i, viewModel: solver)
                                    .frame(width: sumCellSize, height: sumCellSize)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke()
                                    }
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                        
                        ForEach(0..<solver.dimensions.rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                SumCellView(isRow: true, num: row, viewModel: solver)
                                    .frame(width: sumCellSize, height: sumCellSize)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke()
                                    }
                                    .frame(width: cellSize, height: cellSize)
                                
                                ForEach(0..<solver.dimensions.columns, id: \.self) { column in
                                    CellView(row: row, column: column, viewModel: solver)
                                        .frame(width: cellSize, height: cellSize)
                                        .background {
                                            Rectangle()
                                                .stroke()
                                        }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                }
                
                Button(action: solver.solve){
                    Text("Find solution")
                }
                .padding()
                .frame(minWidth: 200)
                .foregroundColor(.white)
                .background(.blue)
                .clipShape(Capsule())
                .padding(.top, 50)
                .disabled(solver.isSolving)
            }
            .padding()
            
            if solver.isSolving {
                Color.gray.opacity(0.75)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                    
                    Text("Solving")
                }
            }
        }
    }
}

#Preview {
    BoardInputView(rows: 2, columns: 2) {}
}
