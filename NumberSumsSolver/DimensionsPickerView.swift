//
//  DimensionsPickerView.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct DimensionsPickerView: View {
    @Binding var presentMyself: Bool
    
    @State var rows: Int? = nil
    @State var columns: Int? = nil
    
    @State private var showNext = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Button("", systemImage: "chevron.left", action: dismiss)
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            
            VStack() {
                HStack {
                    Text("Rows:")
                    PositiveIntegerTextField(int: $rows)
                        .frame(width: 50, height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(rows == nil ? .red : .black)
                        }
                }
                HStack {
                    Text("Columns:")
                    PositiveIntegerTextField(int: $columns)
                        .frame(width: 50, height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(columns == nil ? .red : .black)
                        }
                }
                
                Button(action: next){
                    Text("Next")
                }
                .padding()
                .frame(minWidth: 100)
                .foregroundColor(.white)
                .background(.blue)
                .clipShape(Capsule())
                .padding(.top, 50)
                .disabled(rows == nil || columns == nil)
                
            }
            
            if showNext, let rows = rows, let columns = columns {
                BoardInputView(rows: rows, columns: columns, dismiss: dismiss)
            }
        }
    }
    
    func dismiss() {
        withAnimation {
            presentMyself = false
        }
    }
    
    func next() {
        guard rows != nil, columns != nil else { return }
        withAnimation {
            showNext = true
        }
    }
}

#Preview {
    DimensionsPickerView(presentMyself: .constant(true))
}
