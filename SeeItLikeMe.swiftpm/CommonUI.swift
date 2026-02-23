//
//  CommonUI.swift
//  SeeItLikeMe
//
//  Created by student on 10/02/26.
//


//
//  AmbientBackground.swift
//  SeeItLikeMe
//
//  Created by Teacher on 10/02/2026.
//


import SwiftUI

struct AmbientBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .secondarySystemBackground),
                    Color(uiColor: .systemBackground).opacity(0.8)
                ],
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 25.0).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
            
            // Subtle floating blobs
            GeometryReader { geo in
                ZStack {
                    Blob(color: .blue.opacity(0.05), size: 400)
                        .offset(x: animate ? 100 : -100, y: animate ? -50 : 50)
                    Blob(color: .purple.opacity(0.05), size: 300)
                        .offset(x: animate ? -150 : 150, y: animate ? 100 : -100)
                }
                .blur(radius: 80)
            }
        }
    }
}

struct Blob: View {
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

extension View {
    func calmTransition() -> some View {
        self.transition(.opacity.combined(with: .scale(scale: 0.98)).animation(.easeInOut(duration: 1.0)))
    }
}

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .padding(.leading, 20)
        .padding(.top, 20)
    }
}

// MARK: - Calm Glow Modifier
struct CalmGlowModifier: ViewModifier {
    let color: Color
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.05 : 1.0)
            .shadow(color: isActive ? color : .clear, radius: isActive ? 20 : 0)
            .animation(reduceMotion ? nil : .easeInOut(duration: isActive ? 0.4 : 0.7), value: isActive)
    }
}

extension View {
    func calmGlow(color: Color, isActive: Bool) -> some View {
        self.modifier(CalmGlowModifier(color: color, isActive: isActive))
    }
}

// MARK: - Calm Menu Overlay
struct CalmMenuOverlay: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Dimmed Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    closeMenu()
                }
            
            // Menu Content
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("See It Like Me")
                        .font(.headline)
                        .opacity(0.5)
                    Spacer()
                    Button(action: { closeMenu() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .opacity(0.8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)
                
                // About
                MenuSection(title: "About") {
                    Text("An exploration of visual processing differences. This experience is designed to foster empathy, not to simulate medical conditions perfectly.")
                }
                
                // Guide
                MenuSection(title: "Guide") {
                    Text("Take your time. There is no winning or losing. Simply observe how the world changes through different lenses.")
                }
                
                // Settings
                MenuSection(title: "Settings") {
                    HStack {
                        Image(systemName: reduceMotion ? "checkmark.circle.fill" : "circle")
                        Text(reduceMotion ? "Motion Reduced (System)" : "Motion Standard")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("v1.0 • Designed for calmness")
                    .font(.caption2)
                    .opacity(0.3)
            }
            .padding(40)
            .frame(maxWidth: 400, maxHeight: 600)
            .background(.regularMaterial)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 30, y: 10)
            .padding(20)
        }
        .transition(.opacity)
        .zIndex(100)
    }
    
    private func closeMenu() {
        withAnimation(.easeInOut(duration: 0.4)) {
            store.showMenu = false
        }
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            content
                .font(.body)
                .foregroundColor(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
