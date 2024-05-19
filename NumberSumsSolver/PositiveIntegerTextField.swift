//
//  PositiveIntegerTextField.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct PositiveIntegerTextField: View {
    @Binding var int: Int?
    
    var body: some View {
        IntegerTextField(int: $int)
            .onChange(of: int) { newValue in
                guard let int = int else { return }
                if int <= 0 { self.int = nil }
            }
    }
}

private struct PositiveIntegerTextFieldDemo: View {
    @State var int: Int? = nil
    
    var body: some View {
        PositiveIntegerTextField(int: $int)
            .frame(width: 50, height: 50)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
            }
        
    }
}

#Preview {
    PositiveIntegerTextFieldDemo()
}
