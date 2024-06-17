//
//  ContentView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewStateManager: ViewStateManager
//    @StateObject var
    
    var body: some View {
        switch viewStateManager.viewState {
        case .splash:
            SplashView()
        case .onboarding:
            Text("onboarding")
        case .home:
            Text("home")
        }
    }
}
