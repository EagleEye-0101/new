//
//  SynthesisView.swift
//  SeeItLikeMe
//
//  Created by student on 10/02/26.
//


//
//  SynthesisView.swift
//  SeeItLikeMe
//
//  Created by Teacher on 10/02/2026.
//


import SwiftUI

struct SynthesisView: View {
    @EnvironmentObject var store: AppStore
    @State private var showText = false
    
    var body: some View {
        VStack(spacing: 48) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("Reflection complete")
                    .font(.system(size: 32, weight: .thin, design: .serif))
                    .italic()
                
                Text("You have journeyed through multiple perspectives. Each one a reminder that design is never neutral—it either invites or excludes.")
                    .font(.title3.weight(.light))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showText ? 0.8 : 0)
            }
            
            VStack(spacing: 12) {
                Text("Thank you for your awareness.")
                    .font(.subheadline.weight(.medium))
                    .opacity(showText ? 0.6 : 0)
                
                Text("This experience is for awareness only and does not represent medical advice or diagnosis.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .opacity(showText ? 0.4 : 0)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 1.5)) {
                    store.flow = .hub
                    store.completedExperiences = []
                    store.hubState = .idle
                }
            }) {
                Text("Begin Again")
                    .font(.caption.weight(.bold))
                    .kerning(2)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().stroke(Color.primary.opacity(0.2), lineWidth: 1))
            }
            .opacity(showText ? 1.0 : 0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 3.0).delay(1.0)) {
                showText = true
            }
        }
    }
}