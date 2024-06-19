//
//  SplashView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewStateManager: ViewStateManager
    
    var body: some View {
        VStack (spacing: 20) {
            Image("icon")
                .resizable()
                .frame(width: 200, height: 200)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("asdf")
                    }
                }
            VStack (alignment: .leading, spacing: 12) {
                Text("음성과").font(.Medium18)
                Text("사진으로").font(.Medium18)
                ZStack {
                    HStack (spacing: 0) {
                        Text("간편하게 기록").font(.SemiBold18).foregroundStyle(Color.blue)
                        Text("하는 가계부").font(.Medium18)
                    }
                    Image(systemName: "waveform").font(.system(size: 18)).foregroundColor(.customBlue).offset(y: -70)
                    Image(systemName: "bolt.fill").font(.system(size: 18)).foregroundColor(.customBlue).offset(y: -35)
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
