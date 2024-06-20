//
//  SplashView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewStateManager: ViewStateManager
    @AppStorage("doneOnboard") private var doneOnboard: Bool = false
    
    var body: some View {
        VStack (spacing: 20) {
            Image("icon")
                .resizable()
                .frame(width: 200, height: 200)
                .onAppear {
                    if !doneOnboard {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation (.easeInOut(duration: 0.3)) {
                                viewStateManager.viewState = .onboarding
                            }
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation (.easeInOut(duration: 0.3)) {
                                viewStateManager.viewState = .home
                            }
                        }
                        
                    }
                }
            VStack (alignment: .leading, spacing: 12) {
                Text("음성으로").font(.Medium18)
                ZStack {
                    HStack (spacing: 0) {
                        Text("간편하게 기록").font(.SemiBold18).foregroundStyle(Color.blue)
                        Text("하는 가계부").font(.Medium18)
                    }
                    Image(systemName: "waveform").font(.system(size: 18)).foregroundColor(.customBlue).offset(y: -35)
                }
            }
            .padding(.bottom, 80)
        }
    }
}

//#Preview {
//    SplashView()
//}
