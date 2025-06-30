//
//  ContentView.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MascotViewModel()
    
    var body: some View {
        MascotView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
} 