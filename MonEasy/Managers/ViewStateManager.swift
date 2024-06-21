//
//  ViewStateManager.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

class ViewStateManager: ObservableObject {
    @Published var viewState: ViewState = .splash
}

enum ViewState {
    case splash
    case onboarding
    case home
}
