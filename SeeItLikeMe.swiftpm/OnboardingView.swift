//
//  OnboardingView.swift
//  SeeItLikeMe
//
//  Created by student on 10/02/26.
//


//
//  OnboardingView.swift
//  SeeItLikeMe
//
//  Created by Teacher on 10/02/2026.
//


import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var currentPage = 1
    @State private var showButton = false
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                if currentPage == 1 {
                    pageOne
                        .calmTransition()
                } else if currentPage == 2 {
                    pageTwo
                        .calmTransition()
                } else if currentPage == 3 {
                    pageThree
                        .calmTransition()
                }
                
                Spacer()
                
                if currentPage < 3 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 60)
                    .opacity(textOpacity)
                } else if showButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            store.flow = .hub
                        }
                    }) {
                        Text("Begin the Journey")
                            .font(.title3.weight(.medium))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 18)
                            .background(Capsule().fill(Color.primary.opacity(0.1)))
                            .overlay(Capsule().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))
                    }
                    .padding(.bottom, 60)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2.0).delay(0.5)) {
                textOpacity = 1.0
            }
        }
    }
    
    private var pageOne: some View {
        VStack(spacing: 20) {
            Text("See It Like Me")
                .font(.system(size: 44, weight: .thin, design: .serif))
                .italic()
            
            Text("Interface design is more than pixels.\nIt is the lens through which we experience the world.")
                .font(.title3.weight(.light))
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .padding(.horizontal, 40)
        }
    }
    
    private var pageTwo: some View {
        VStack(spacing: 24) {
            Text("Perspective")
                .font(.title.weight(.light))
            
            Text("These experiences may feel subtle, or even uncomfortable. There is no right or wrong way to perceive.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                .opacity(0.7)
        }
    }
    
    private var pageThree: some View {
        VStack(spacing: 24) {
            Text("An Invitation")
                .font(.title.weight(.light))
            
            Text("Step into a series of living environments designed to shift your focus and challenge your interaction.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                .opacity(0.7)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showButton = true
                }
            }
        }
    }
}