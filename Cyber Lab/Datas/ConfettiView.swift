//
//  ConfettiView.swift
//  Cyber Lab
//
//  Created by Jiajun Jiang on 9/2/26.
//  Celebration firework effects
//

import SwiftUI

struct DualCornerConfettiView: View {
    @Binding var isActive: Bool
    var duration: TimeInterval = 5.0

    @State private var particles: [ConfettiParticle] = []

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .white]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiShape(kind: particle.kind)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                        .animation(.linear(duration: 0.016), value: particle.position)
                }
            }
            .onChange(of: isActive) { oldValue, newValue in
                if newValue {
                    emit(in: geo.size)
                } else {
                    // fade out particles
                    withAnimation(.easeOut(duration: 0.5)) {
                        particles.removeAll()
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func emit(in size: CGSize) {
        particles.removeAll()
        let countPerSide = 40
        let leftOrigin = CGPoint(x: 24, y: size.height - 24)
        let rightOrigin = CGPoint(x: size.width - 24, y: size.height - 24)

        var newParticles: [ConfettiParticle] = []
        for i in 0..<countPerSide {
            newParticles.append(randomParticle(from: leftOrigin, size: size, isLeft: true, index: i))
            newParticles.append(randomParticle(from: rightOrigin, size: size, isLeft: false, index: i))
        }
        particles = newParticles

        // animate particles
        for idx in particles.indices {
            let travel = randomTravelVector(isLeft: particles[idx].isLeft)
            let end = CGPoint(x: particles[idx].position.x + travel.dx, y: particles[idx].position.y + travel.dy)
            let rotation = Double.random(in: (-180)...180)
            let delay = Double.random(in: 0...0.2)

            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[idx].position = end
                particles[idx].rotation += rotation
                particles[idx].opacity = 0
            }
        }
    }

    private func randomParticle(from origin: CGPoint, size: CGSize, isLeft: Bool, index: Int) -> ConfettiParticle {
        let kind: ConfettiShape.Kind = [ .circle, .rectangle, .triangle ].randomElement()!
        let color = colors.randomElement()!
        let pSize = CGFloat.random(in: 6...14)
        let particle = ConfettiParticle(
            id: UUID(),
            position: origin,
            color: color,
            size: pSize,
            rotation: Double.random(in: -20...20),
            opacity: 1,
            isLeft: isLeft,
            kind: kind
        )
        return particle
    }

    private func randomTravelVector(isLeft: Bool) -> CGVector {
        // shoot towards up-center from corners
        let dx = CGFloat.random(in: 120...220) * (isLeft ? 1 : -1)
        let dy = CGFloat.random(in: (-280)...(-180))
        return CGVector(dx: dx, dy: dy)
    }
}

private struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var rotation: Double
    var opacity: Double
    let isLeft: Bool
    let kind: ConfettiShape.Kind
}

private struct ConfettiShape: Shape {
    enum Kind { case circle, rectangle, triangle }
    let kind: Kind

    func path(in rect: CGRect) -> Path {
        switch kind {
        case .circle:
            return Path(ellipseIn: rect)
        case .rectangle:
            return Path(rect)
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}


