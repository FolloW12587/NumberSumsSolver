//
//  ContentView.swift
//  NumberSumsSolver
//
//  Created by Сергей Дубовой on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    @State var showDimensionsPicker = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Button {
                withAnimation {
                    showDimensionsPicker = true
                }
            } label: {
                Text("Start")
            }
            .padding()
            .frame(minWidth: 100)
            .foregroundColor(.white)
            .background(.blue)
            .clipShape(Capsule())
            
            if showDimensionsPicker {
                DimensionsPickerView(presentMyself: $showDimensionsPicker)
            }
        }
    }
    
    
}

#Preview {
    ContentView()
}
