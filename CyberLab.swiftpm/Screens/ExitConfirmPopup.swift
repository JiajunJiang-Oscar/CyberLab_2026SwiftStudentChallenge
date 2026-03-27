//
//  ExitConfirmPopup.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  This popup window is used to inform users that quitting the game halfway will not save their progress.
//

import SwiftUI

struct ExitConfirmPopup: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("AssistantExit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text(exitConfirmationMessage)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text(exitButtonNotNow)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        isPresented = false
                        onConfirm()
                    }) {
                        Text(exitButtonSure)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            #if os(macOS)
            .background(Color(nsColor: .windowBackgroundColor))
            #else
            .background(Color(uiColor: .systemBackground))
            #endif
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 50)
        }
    }
}

#Preview {
    ExitConfirmPopup(isPresented: .constant(true)) {
        print("Confirmed exit")
    }
}
