//
//  BottomDock.swift
//  SeeItLikeMe
//
//  Created by student on 10/02/26.
//


//
//  BottomDock.swift
//  SeeItLikeMe
//
//  Created by Teacher on 10/02/2026.
//


import SwiftUI

struct BottomDock: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        HStack(spacing: 0) {
            // Context Indicator
            HStack(spacing: 6) {
                Image(systemName: currentIcon)
                    .font(.body)
                Text(currentLabel)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(.secondary)
            .padding(.leading, 20)
            
            Spacer(minLength: 0)
            
            // Visual Progress
            HStack(spacing: 4) {
                ForEach(0..<ExperienceKind.allCases.count, id: \.self) { i in
                    Circle()
                        .fill(i < store.completedExperiences.count ? Color.primary : Color.primary.opacity(0.1))
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 0)
             
            // Reflect Button & Shift Perspective
            HStack(spacing: 16) {
                Button(action: {
                    if case .immersed(let kind) = store.hubState {
                        store.triggerReflection(kind)
                    }
                }) {
                    Text("Reflect")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.primary.opacity(isReflectEnabled ? 0.1 : 0.05)))
                        .foregroundColor(isReflectEnabled ? .primary : .secondary.opacity(0.3))
                }
                .disabled(!isReflectEnabled)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        store.showMenu.toggle()
                    }
                }) {
                    Image(systemName: "circle.hexagongrid")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 20)
        }
        .frame(height: 56)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    private var currentIcon: String {
        switch store.flow {
        case .hub: return "square.grid.2x2"
        case .journey(let kind): return kind.icon
        case .synthesis: return "sparkles"
        default: return "circle"
        }
    }
    
    private var currentLabel: String {
        switch store.flow {
        case .hub: return "The Hub"
        case .journey(let kind): return kind.rawValue
        case .synthesis: return "Synthesis"
        default: return ""
        }
    }
    
    private var isReflectEnabled: Bool {
        if case .immersed = store.hubState { return true }
        return false
    }
}