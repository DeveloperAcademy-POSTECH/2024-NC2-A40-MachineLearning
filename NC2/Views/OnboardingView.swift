//
//  OnboardingView.swift
//  NC2
//
//  Created by DevJonny on 2024/6/17.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewStateManager: ViewStateManager
    @AppStorage("doneOnboard") private var doneOnboard: Bool = false
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer().frame(width: 10)
                Image(.icon)
                    .resizable()
                    .frame(width: 70, height: 70)
                Spacer()
            }
            Spacer()
//            VStack (alignment: .leading) {
//                HStack (spacing: 0) {
//                    Text("커스텀 ").font(.SemiBold16)
//                    Text("액션 버튼").font(.SemiBold16)
//                        .foregroundStyle(.blue)
//                    Text("을 눌러서").font(.Light16)
//                }
//                Text("가계 내역을 기록할 수 있어요!").font(.Light16)
//            }
//            ZStack {
//                Image(.onboardingActionButton)
//                Circle()
//                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
//                    .foregroundStyle(.blue)
//                    .frame(width: 56, height: 56)
//                    .background(Color.clear)
//                    .offset(x: -80, y: 24)
//                HStack {
//                    Spacer()
//                    Text("*iPhone 15 Pro 이상 기종부터 가능.").font(.Light6)
//                        .foregroundStyle(Color(hexColor: "929292"))
//                }
//                .padding(.horizontal, 20)
//                .offset(y: 90)
//            }
//            Divider()
//                .padding(.horizontal, 20)
//                .padding(.bottom, 60)
            
            VStack (alignment: .center) {
                HStack (spacing: 0) {
                    Text("잠금화면의 ").font(.SemiBold16)
                    Text("위젯").font(.SemiBold16)
                        .foregroundStyle(.blue)
                    Text("으로 빠르게").font(.Light16)
                }
                Text("가계 내역을 기록할 수 있어요!").font(.Light16)
            }
            .padding(.bottom, 40)
            ZStack {
                Image(.widgetOnboarding)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.blue)
                    .frame(width: 100, height: 100)
                    .background(Color.clear)
                    .offset(x: -75, y: -92)
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.blue)
                    .frame(width: 70, height: 70)
                    .background(Color.clear)
                    .offset(x: 80, y: -92)
            }
            .padding(.bottom, 30)
            Spacer()
            Button(action: {
                doneOnboard = true
                withAnimation (.easeInOut(duration: 0.3)) {
                    viewStateManager.viewState = .home
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("시작하기")
                        .font(.SemiBold16)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            })
        }
    }
}

#Preview {
    OnboardingView()
}
