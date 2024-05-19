//
//  IntegerTextField.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct IntegerTextField: View {
    @Binding var int: Int?
    @State private var text: String
    
    init(int: Binding<Int?>) {
        self._int = int
        let wrappedValue = int.wrappedValue == nil ? "" : String(int.wrappedValue!)
        
        self._text = State(wrappedValue: wrappedValue)
    }
    
    var body: some View {
        TextField("", text: $text)
            .multilineTextAlignment(.center)
            .onChange(of: text) { newValue in
                int = Int(newValue)
                text = int == nil ? "" : String(int!)
            }
            .onChange(of: int) { newValue in
                text = int == nil ? "" : String(int!)
            }
    }
}

private struct IntegerTextFieldDemo: View {
    @State var int: Int? = nil
    
    var body: some View {
        IntegerTextField(int: $int)
            .frame(width: 50, height: 50)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
            }
        
    }
}

#Preview {
    IntegerTextFieldDemo()
}
