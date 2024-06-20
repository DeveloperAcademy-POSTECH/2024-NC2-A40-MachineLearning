//
//  AdaptsToKeyboard.swift
//  NC2
//
//  Created by DevJonny on 2024/6/19.
//

import SwiftUI
import Combine

struct DontAdaptsToKeyboard: ViewModifier {
    @State var keyboardVisible: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onAppear(perform: {
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                        .map { _ in
                            true
                        }
                        .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardVisible))
                    
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                        .map { _ in
                            false
                        }
                        .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardVisible))
                })
        }
    }
}

extension View {
    func dontAdaptsToKeyboard() -> some View {
        return modifier(DontAdaptsToKeyboard())
    }
}
