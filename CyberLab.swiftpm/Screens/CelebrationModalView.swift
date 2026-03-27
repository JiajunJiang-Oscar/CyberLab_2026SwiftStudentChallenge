//
//  CelebrationModalView.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//
//  This pop-up window is used to inform the user that the current part has been completed. The "little robot" icon in the pop-up comes from Gemini's re-creation of free resources from Canva.
//

import SwiftUI

public struct CelebrationPopup: View {
    @Binding public var isPresented: Bool
    public var message: String
    public var primaryActionTitle: String = "Start Next Chapter"
    public var primaryAction: () -> Void

    public init(isPresented: Binding<Bool>, message: String, primaryActionTitle: String = "Start Next Chapter", primaryAction: @escaping () -> Void) {
        self._isPresented = isPresented
        self.message = message
        self.primaryActionTitle = primaryActionTitle
        self.primaryAction = primaryAction
    }

    public var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                ZStack {
                    VStack(spacing: 14) {
                        Image("Assistant1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 144, height: 144)
                            .foregroundColor(.yellow)

                        Text("Congratulations!")
                            .font(.title)
                            .bold()

                        Text(message)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            primaryAction()
                            isPresented = false
                        }) {
                            Text(primaryActionTitle)
                                .font(.headline)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top, 4)
                    }
                    .padding(28)
                    .frame(maxWidth: 460)
                #if os(macOS)
                    .background(Color(NSColor.windowBackgroundColor))
                #else
                    .background(Color(UIColor.systemBackground))
                #endif
                    .cornerRadius(20)
                    .shadow(radius: 16)

                    ConfettiOverlay()
                        .allowsHitTesting(false)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: isPresented)
        }
    }
}

private struct ConfettiOverlay: View {
    @State private var particles: [Particle] = []

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .white]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear

                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(p.position)
                        .opacity(p.opacity)
                }
            }
            .onAppear {
                emit(in: geo.size)
                withAnimation(.easeOut(duration: 1.2)) {
                    for i in particles.indices {
                        particles[i].position.y -= CGFloat.random(in: 80...120)
                        particles[i].position.x += CGFloat.random(in: -60...60)
                        particles[i].opacity = 0
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func emit(in size: CGSize) {
        particles.removeAll()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for _ in 0..<40 {
            let color = colors.randomElement()!
            let sz = CGFloat.random(in: 6...12)
            let jitterX = CGFloat.random(in: -80...80)
            let jitterY = CGFloat.random(in: -20...20)
            particles.append(Particle(id: UUID(), position: CGPoint(x: center.x + jitterX, y: center.y + jitterY), color: color, size: sz, opacity: 1))
        }
    }

    private struct Particle: Identifiable {
        let id: UUID
        var position: CGPoint
        let color: Color
        let size: CGFloat
        var opacity: Double
    }
}
