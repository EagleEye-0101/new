//
//  ExperienceViews.swift
//  SeeItLikeMe
//
//  Created by student on 10/02/26.
//



//
//  JourneyPhase.swift
//  SeeItLikeMe
//
//  Created by Teacher on 10/02/2026.
//


import SwiftUI

enum JourneyPhase {
    case orientation
    case shift
    case immersive
    case integration
}

struct ExperienceJourneyWrapper: View {
    let kind: ExperienceKind
    @EnvironmentObject var store: AppStore
    
    // Derived state for cleaner view logic
    var isIntro: Bool {
        if case .focused = store.hubState { return true }
        return false
    }
    
    var isReflecting: Bool {
        if case .integrating = store.hubState { return true }
        return false
    }
    
    var body: some View {
        ZStack {
            // LAYER 1: Active Experience (Always visible once started, reduced during intro/reflection)
            if !isIntro {
                ExperienceContent(kind: kind, isReflecting: isReflecting)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
                    .blur(radius: isReflecting ? 15 : 0) // Blur during reflection
                    .saturation(isReflecting ? 0.5 : 1.0)
            }
            
            // LAYER 2: Intro Overlay
            if isIntro {
                ExperienceIntroView(kind: kind)
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
                    .zIndex(2)
            }
            
            // LAYER 3: Reflection Overlay
            if isReflecting {
                ExperienceReflectionView(kind: kind)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(3)
            }
            
            // Back Button (Top Left)
            // Available in all states, exits gracefully
            VStack {
                HStack {
                    BackButton {
                        // Clean exit logic handled by Models based on current state
                        if isReflecting {
                           store.finishJourney(kind)
                        } else {
                           // If active/intro, just leave
                           withAnimation(.easeInOut) {
                               store.flow = .hub
                               store.hubState = .idle
                           }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .zIndex(100)
        }
    }
}

// MARK: - Intro View
struct ExperienceIntroView: View {
    let kind: ExperienceKind
    @EnvironmentObject var store: AppStore
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: kind.icon)
                    .font(.system(size: 60, weight: .thin))
                    .foregroundColor(.primary.opacity(0.8))
                    .scaleEffect(appear ? 1.0 : 0.8)
                    .opacity(appear ? 1.0 : 0)
                
                VStack(spacing: 16) {
                    Text(kind.rawValue)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(introText)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .foregroundColor(.secondary)
                }
                .offset(y: appear ? 0 : 20)
                .opacity(appear ? 1.0 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                appear = true
            }
            // Auto-advance to active after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                store.startActiveExperience(kind)
            }
        }
    }
    
    private var introText: String {
        switch kind {
        case .visualStrain: return "Read the text as the environment changes."
        case .colorPerception: return "Tap the color that looks different."
        case .focusTunnel: return "Keep watching the center context."
        case .readingStability: return "Try to read the moving text."
        case .memoryLoad: return "Remember the pattern, then find it again."
        case .focusDistraction: return "Ignore the shapes. Focus on the message."
        case .cognitiveLoad: return "Clear the tasks as they appear."
        case .interactionPrecision: return "Tap the target as often as you can."
        }
    }
}

// MARK: - Reflection View
struct ExperienceReflectionView: View {
    let kind: ExperienceKind
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: Tap outside to close? 
                    // No, keeping it explicit with the button.
                }
            
            VStack(spacing: 30) {
                Text(kind.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(reflectionText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    store.finishJourney(kind)
                }) {
                    Text("Complete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.blue))
                }
            }
            .padding(40)
            .background(.regularMaterial)
            .cornerRadius(24)
            .shadow(radius: 20)
            .padding(20)
        }
    }
    
    private var reflectionText: String {
        switch kind {
        case .visualStrain: 
            return "When the environment lacks stability, your visual system compensates quietly. Tiny fluctuations in contrast, spacing, and alignment force the eyes and brain into a state of continuous adjustment. This invisible effort compounds, transforming a simple reading task into a source of quiet fatigue."
        case .colorPerception:
            return "When color sensitivity is reduced, distinguishing elements becomes a guessing game. Reliance on color alone excludes."
        case .focusTunnel:
            return "Peripheral vision provides critical context. When it's lost, we lose the ability to anticipate and orient ourselves."
        case .readingStability:
            return "Reading requires the eyes to anchor. When that anchor moves (like in nystagmus), comprehension drops while effort spikes."
        case .memoryLoad:
            return "Working memory is fragile. A single interruption can wipe it clean, forcing a complete restart of the task."
        case .focusDistraction:
            return "Motion captures attention involuntarily. Trying to ignore it is an active, exhausting cognitive process."
        case .cognitiveLoad:
            return "When demands overlap and accumulate, the mind loses the quiet space needed to process them. The feeling of being overwhelmed isn't about the difficulty of a single task; it’s about the impossibility of managing them all at once."
        case .interactionPrecision:
            return "When interaction reliability changes subtly over time, routine actions begin to require conscious effort. The growing frustration comes entirely from the unpredictability of the environment, not a lack of ability."
        }
    }
}

struct ExperienceContent: View {
    let kind: ExperienceKind
    let isReflecting: Bool
    
    // We pass isReflecting so experiences can pause/slow down if they want,
    // though the wrapper already blurs them.
    
    var body: some View {
        Group {
            switch kind {
            case .visualStrain: VisualStrainExperience(isReflecting: isReflecting)
            case .colorPerception: ColorPerceptionExperience(isReflecting: isReflecting)
            case .focusTunnel: FocusTunnelExperience(isReflecting: isReflecting)
            case .readingStability: ReadingStabilityExperience(isReflecting: isReflecting)
            case .memoryLoad: MemoryLoadExperience(isReflecting: isReflecting)
            case .focusDistraction: FocusDistractionExperience(isReflecting: isReflecting)
            case .cognitiveLoad: CognitiveLoadExperience(isReflecting: isReflecting)
            case .interactionPrecision: InteractionPrecisionExperience(isReflecting: isReflecting)
            }
        }
    }
}

// --- Experience Implementations ---

struct VisualStrainExperience: View {
    let isReflecting: Bool
    
    // Core time driver
    @State private var timeElapsed: Double = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // The reading content
    let paragraphs = [
        "Language gives us the illusion of concrete meaning, but interpretation is inherently fluid.",
        "We read not just the words, but the spaces between them, the structure they form on the page.",
        "When consistency is present, the mind glides over the text, absorbing ideas without friction.",
        "When the visual foundation becomes unstable, reading shifts from effortless comprehension to active decryption.",
        "This effort is rarely loud; it is a quiet, accumulating toll on cognitive resources."
    ]
    
    // State variables for the reading interaction
    @State private var revealedCount = 5 // Show all 5 paragraphs from start
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Layer (subtle contrast drift)
                let bgOpacity = 0.9 + (sin(timeElapsed * 0.15) * 0.08)
                Color(uiColor: .systemBackground).opacity(bgOpacity)
                    .ignoresSafeArea()
                
                // Muted gray wash to lower overall contrast organically over time
                let contrastWash = min(0.15, timeElapsed / 100.0)
                Color.gray.opacity(contrastWash)
                    .ignoresSafeArea()
                
                // Content Layer
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(0..<paragraphs.count, id: \.self) { i in
                            if i < revealedCount {
                                StrainParagraph(
                                    text: paragraphs[i],
                                    index: i,
                                    timeElapsed: timeElapsed,
                                    isReflecting: isReflecting
                                )
                                // Interactive reveal
                                .onTapGesture {
                                    if i == revealedCount - 1 && revealedCount < paragraphs.count {
                                        withAnimation(.easeInOut(duration: 1.5)) {
                                            revealedCount += 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 80)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Overlay A: Very Subtle Noise Grain
                // Starts coming in rapidly and gets thicker
                if timeElapsed > 2 {
                    let noiseOpacity = min(0.12, (timeElapsed - 2) / 20.0)
                    Canvas { context, size in
                        for _ in 0..<Int(150 * noiseOpacity * 100) {
                            let rect = CGRect(
                                x: .random(in: 0...size.width),
                                y: .random(in: 0...size.height),
                                width: 1.5,
                                height: 1.5
                            )
                            context.fill(Path(rect), with: .color(.black.opacity(opacityForNoise())))
                        }
                    }
                    .opacity(isReflecting ? 0.2 : 1.0) // Calms down on reflection
                    .allowsHitTesting(false)
                }
                
                // Overlay B: Uneven Brightness/Focus patches drifting slowly
                ZStack {
                    if timeElapsed > 5 {
                        let patchOpacity = min(0.4, (timeElapsed - 5) / 20.0)
                        
                        Circle()
                            .fill(Color(uiColor: .systemBackground).opacity(patchOpacity))
                            .frame(width: geo.size.width * 1.5)
                            .blur(radius: 80)
                            .offset(
                                x: sin(timeElapsed * 0.05) * 100,
                                y: cos(timeElapsed * 0.07) * 150
                            )
                            
                        Circle()
                            .fill(Color.gray.opacity(patchOpacity * 0.5))
                            .frame(width: geo.size.width)
                            .blur(radius: 60)
                            .offset(
                                x: cos(timeElapsed * 0.04) * 80,
                                y: sin(timeElapsed * 0.06) * 120
                            )
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .onReceive(timer) { _ in
            guard !isReflecting else { return }
            timeElapsed += 0.1
        }
    }
    
    private func opacityForNoise() -> Double {
        // Random small opacity for noise dots to avoid uniformity
        Double.random(in: 0.1...0.3)
    }
}

// A single paragraph that manages its own micro-degradations based on time
struct StrainParagraph: View {
    let text: String
    let index: Int
    let timeElapsed: Double
    let isReflecting: Bool
    
    // We split into words to allow subtle intra-paragraph irregularities
    private var words: [String] {
        text.components(separatedBy: .whitespaces)
    }
    
    var body: some View {
        // We use a custom layout approach or an HWrap if available. For brevity and reliability in SwiftUI,
        // since we just have short text, Text with tracking/lineSpacing can simulate much of this.
        // However, to do true sub-pixel baseline shifting, we need individual Text views or AttributedString.
        // A simpler but highly effective approach matching the constraints:
        // We will alter the kerning, line spacing, blur, and opacity on the whole paragraph block,
        // but drive them with different sine waves based on the paragraph index.
        
        // 1. Calculate progressive strain (starts at 0, ramps up very quickly over 15s)
        let strain = min(1.0, timeElapsed / 15.0)
        
        // 2. Micro Contrast Instability (Opacity fluctuates)
        // Base opacity drops slightly, then oscillates
        let baseOpacity = 0.85 - (strain * 0.2)
        let opacityOscillation = sin(timeElapsed * 0.3 + Double(index)) * 0.1 * strain
        let finalOpacity = isReflecting ? 0.8 : max(0.2, baseOpacity + opacityOscillation)
        
        // 3. Text Metrics Drift (Tracking and Line Spacing)
        // Normal tracking is 0. We drift it slightly positive and negative.
        let kerningDrift = sin(timeElapsed * 0.15 + Double(index * 2)) * 1.5 * strain
        let lineSpacingDrift = 8.0 + (cos(timeElapsed * 0.1 + Double(index)) * 4.0 * strain)
        
        // 4. Alignment Imperfections (Slight vertical/horizontal shift)
        let yShift = sin(timeElapsed * 0.25 + Double(index * 3)) * 2.0 * strain
        let rotationDrift = cos(timeElapsed * 0.08 + Double(index)) * 0.5 * strain
        
        // 5. Focus Inconsistency (Subtle blur)
        // Some paragraphs blur slightly while others don't, shifting over time
        let blurAmount = max(0, sin(timeElapsed * 0.2 + Double(index * 4)) * 1.2 * strain)
        
        Text(text)
            .font(.system(size: 20, weight: .regular, design: .serif))
            .kerning(isReflecting ? 0 : kerningDrift)
            .lineSpacing(isReflecting ? 8 : lineSpacingDrift)
            .foregroundColor(.primary.opacity(finalOpacity))
            .blur(radius: isReflecting ? 0 : blurAmount)
            .offset(y: isReflecting ? 0 : yShift)
            .rotationEffect(.degrees(isReflecting ? 0 : rotationDrift))
            .animation(.easeInOut(duration: 2.0), value: isReflecting)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}



struct ColorPerceptionExperience: View {
    let isReflecting: Bool
    
    // Game State
    @State private var targetIndex: Int = 0
    @State private var baseColor: Color = .blue
    @State private var level: Int = 1
    @State private var flashIndex: Int? = nil // For feedback
    @State private var isCorrect: Bool? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var difficulty: Double {
        // As level increases, difficulty 0->1
        // Level 1: Diff 0.2 (Easy). Level 10: Diff 0.01 (Hard)
        return min(Double(level) / 10.0, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Find the different shade")
                .font(.caption)
                .textCase(.uppercase)
                .kerning(2)
                .opacity(0.6)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<9) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color(for: index))
                        .aspectRatio(1.0, contentMode: .fit)
                        // Feedback overlay
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(lineWidth: 4)
                                .foregroundColor(flashIndex == index ? (isCorrect == true ? .green : .red) : .clear)
                        )
                        .scaleEffect(flashIndex == index ? 0.95 : 1.0)
                        .onTapGesture {
                            handleTap(index)
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: flashIndex)
                }
            }
            .padding(40)
            
            Text("Round \(level)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
        }
        .onAppear {
            generateRound()
        }
    }
    
    private func color(for index: Int) -> Color {
        if index == targetIndex {
            // Calculate difference
            // Level 1 (Diff 0.0) -> Hue Shift 0.15
            // Level 10 (Diff 1.0) -> Hue Shift 0.005
            let shift = 0.15 - (difficulty * 0.145)
            
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            UIColor(baseColor).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return Color(hue: h + shift, saturation: s, brightness: b)
        }
        return baseColor
    }
    
    private func handleTap(_ index: Int) {
        guard flashIndex == nil else { return } // Prevent spam
        
        flashIndex = index
        isCorrect = (index == targetIndex)
        
        let delay = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            flashIndex = nil
            if isCorrect == true {
                level += 1
                generateRound()
            } else {
                // Keep same level, new colors
                generateRound()
            }
        }
    }
    
    private func generateRound() {
        targetIndex = Int.random(in: 0..<9)
        baseColor = Color(
            hue: Double.random(in: 0...1),
            saturation: 0.7,
            brightness: 0.9
        )
    }
}

struct FocusTunnelExperience: View {
    let isReflecting: Bool
    @State private var startTime = Date()
    @State private var now = Date()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        // Narrow over 30 seconds
        let p = now.timeIntervalSince(startTime) / 30.0
        return min(p, 1.0)
    }
    
    var body: some View {
        ZStack {
            // Content Layer: Grid of Context Info
            GeometryReader { geo in
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                    ForEach(0..<20) { i in
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Contextual Alert \(i)")
                                .font(.caption)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                // Vital warning labels on the far edges
                Text("WARNING: System Failure")
                    .foregroundColor(.red)
                    .position(x: 50, y: geo.size.height / 2)
                Text("BATTERY CRITICAL")
                    .foregroundColor(.orange)
                    .position(x: geo.size.width - 50, y: geo.size.height / 2)
            }
            .blur(radius: isReflecting ? 10 : 0)
            
            // Mask Layer
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                let maxRadius = max(geo.size.width, geo.size.height)
                let currentRadius = maxRadius * (1.1 - (progress * 0.95)) // Shrink to 15%
                
                ZStack {
                    // Dark Outer
                    Color.black.opacity(0.95)
                        .mask(
                            Rectangle()
                                .overlay(
                                    Circle()
                                        .frame(width: max(50, currentRadius), height: max(50, currentRadius))
                                        .blendMode(.destinationOut)
                                )
                        )
                    
                    // Tunnel edges (Gradient)
                    Circle()
                        .strokeBorder(
                            RadialGradient(gradient: Gradient(colors: [.clear, .black]), center: .center, startRadius: 0, endRadius: max(25, currentRadius/2)),
                            lineWidth: currentRadius
                        )
                        .frame(width: currentRadius, height: currentRadius)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { startTime = Date() }
        .onReceive(timer) { input in
            guard !isReflecting else { return }
            now = input
        }
    }
}

struct ReadingStabilityExperience: View {
    let isReflecting: Bool
    @State private var time: Double = 0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 30) {
                ForEach(0..<12) { i in
                    Text("Continuous text requires a stable baseline. When elements shift, the cognitive cost of tracking increases significantly. This simulation mimics nystagmus and other instability conditions.")
                        .font(.title3)
                        .lineLimit(2)
                        .offset(x: xOffset(i), y: yOffset(i))
                        .rotationEffect(.degrees(rotation(i)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(40)
            .frame(height: geo.size.height)
        }
        .onReceive(timer) { _ in
            guard !isReflecting else { return }
            time += 0.05
        }
    }
    
    // Chaotic Physics
    func xOffset(_ i: Int) -> CGFloat {
        // Drifts left/right
        return sin(time + Double(i)) * 15 + cos(time * 0.5) * 10
    }
    
    func yOffset(_ i: Int) -> CGFloat {
        // Bobs up/down randomly
        return sin(time * 1.5 + Double(i)*0.2) * 8
    }
    
    func rotation(_ i: Int) -> Double {
        // Subtle tilt
        return sin(time * 0.8 + Double(i)) * 2
    }
}

struct MemoryLoadExperience: View {
    let isReflecting: Bool
    @State private var pattern: [Int] = (0..<9).map { _ in Int.random(in: 0...1) }
    @State private var phase: Int = 0 // 0: Observe, 1: Noise, 2: Recall
    @State private var userPattern: [Int] = Array(repeating: 0, count: 9)
    
    // Timer for phase transitions
    @State private var time: Double = 0
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Text(statusText)
                .font(.title3)
                .animation(.easeInOut, value: phase)
            
            ZStack {
                // The Grid
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(80), spacing: 16), count: 3), spacing: 16) {
                    ForEach(0..<9) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(cellColor(at: i))
                            .frame(width: 80, height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                            .onTapGesture {
                                if phase == 2 {
                                    userPattern[i] = userPattern[i] == 1 ? 0 : 1
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: userPattern)
                    }
                }
                .opacity(phase == 1 ? 0.1 : 1.0)
                .blur(radius: phase == 1 ? 10 : 0)
                
                // Distraction Phase
                if phase == 1 {
                    GeometryReader { geo in
                        ForEach(0..<20) { _ in
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .offset(x: CGFloat.random(in: 0...geo.size.width),
                                        y: CGFloat.random(in: 0...geo.size.height))
                                .animation(
                                    Animation.spring().repeatForever().speed(Double.random(in: 0.5...2.0)),
                                    value: time
                                )
                        }
                    }
                }
            }
            .frame(width: 300, height: 300)
            
            if phase == 2 {
                Button("Check Memory") {
                    // Start over with new pattern
                    withAnimation {
                        pattern = (0..<9).map { _ in Int.random(in: 0...1) }
                        userPattern = Array(repeating: 0, count: 9)
                        phase = 0
                        time = 0
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onReceive(timer) { _ in
            guard !isReflecting else { return }
            time += 1
            if time == 5 && phase == 0 { withAnimation { phase = 1 } }
            if time == 10 && phase == 1 { withAnimation { phase = 2 } }
        }
    }
    
    var statusText: String {
        switch phase {
        case 0: return "Memorize the pattern (5s)"
        case 1: return "Wait..."
        case 2: return "Recreate the pattern"
        default: return ""
        }
    }
    
    func cellColor(at i: Int) -> Color {
        if phase == 0 {
            return pattern[i] == 1 ? Color.blue : Color.gray.opacity(0.1)
        } else if phase == 2 {
            return userPattern[i] == 1 ? Color.blue : Color.gray.opacity(0.1)
        }
        return Color.gray.opacity(0.1)
    }
}

struct FocusDistractionExperience: View {
    let isReflecting: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Layer (Distractors)
                ForEach(0..<15) { i in
                    DistractorCircle(isReflecting: isReflecting, index: i, size: geo.size)
                }
                
                // Foreground Layer (Task)
                VStack(spacing: 20) {
                    Text("Read this passage carefully")
                        .font(.headline)
                        .opacity(0.5)
                    
                    Text("In an environment of high kinetic distraction, the ability to maintain focal attention is compromised. The brain's visual system is hardwired to detect motion, overriding voluntary focus commands. This creates a constant tug-of-war between intent and instinct.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
                .frame(width: 300)
                .position(x: geo.size.width/2, y: geo.size.height/2)
            }
        }
    }
}

struct DistractorCircle: View {
    let isReflecting: Bool
    let index: Int
    let size: CGSize
    @State private var position: CGPoint = .zero
    
    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.3))
            .frame(width: CGFloat.random(in: 30...80), height: CGFloat.random(in: 30...80))
            .position(position)
            .onAppear {
                position = randomPosition()
                animate()
            }
    }
    
    func randomPosition() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        )
    }
    
    func animate() {
        guard !isReflecting else { return }
        
        withAnimation(
            Animation.linear(duration: Double.random(in: 3.0...10.0))
                .repeatForever(autoreverses: false)
        ) {
            position = randomPosition()
        }
    }
}

struct CognitiveLoadExperience: View {
    let isReflecting: Bool
    
    // Core state
    @State private var tasks: [CognitiveTask] = []
    @State private var taskCounter: Int = 0 // Used purely for unique IDs to ensure fresh offset generation
    @State private var timeElapsed: Double = 0
    @State private var lastSpawnTime: Double = 0
    
    // Timers
    // Base arrival rate. We'll use a slightly random interval in the actual logic,
    // but this timer drives the check.
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    struct CognitiveTask: Identifiable, Equatable {
        let id: Int
        let type: TaskType
        var isCompleting: Bool = false
        // Visual positioning
        let xOffset: CGFloat
        let yOffset: CGFloat
        let rotation: Double
        
        enum TaskType: Equatable {
            case multiTap(text: String, required: Int, color: Color)
            case slider(text: String, target: Double, color: Color)
            case stroop(prompt: String, validWord: String, options: [StroopOption])
            case logicToggle(text: String, requiredState: Bool, color: Color)
        }
        
        struct StroopOption: Equatable, Hashable {
            let word: String
            let colorIndex: Int
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                // Background
                Color.white.opacity(0.02).ignoresSafeArea()
                
                // Active Tasks Canvas
                ZStack {
                    ForEach(tasks) { task in
                        CognitiveTaskView(task: task) {
                            completeTask(task)
                        }
                        .offset(x: task.xOffset, y: task.yOffset)
                        .rotationEffect(.degrees(task.rotation))
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                        // The zIndex ensures newer tasks appear *above* older ones
                        .zIndex(Double(task.id))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: isReflecting ? 15 : 0)
                
                // Top-Right Task Counter
                VStack {
                    HStack {
                        Spacer()
                        Text("Task: \(tasks.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 24)
                            .padding(.trailing, 24)
                            .opacity(tasks.isEmpty || isReflecting ? 0 : 1)
                            .animation(.easeInOut(duration: 1.2), value: isReflecting)
                    }
                    Spacer()
                }
            }
        }
        .onReceive(timer) { _ in
            guard !isReflecting else { return }
            timeElapsed += 0.1
            
            // Progressive overload: demands arrive faster over time
            let currentSpawnRate = max(1.2, 3.2 - (timeElapsed / 20.0))
            
            if timeElapsed - lastSpawnTime >= currentSpawnRate {
                addTask()
                lastSpawnTime = timeElapsed
                
                // Overlap: Secondary prompt appears before first resolves
                if timeElapsed > 6.0 && Double.random(in: 0...1) > 0.6 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if !isReflecting { addTask() }
                    }
                }
            }
        }
        .onAppear {
            addTask()
        }
    }
    
    private func addTask() {
        taskCounter += 1
        
        // Ensure new tasks overlap but drift across the view area gradually
        let spreadX = min(220.0, 60.0 + (timeElapsed * 2.5))
        let spreadY = min(300.0, 80.0 + (timeElapsed * 3.0))
        
        let xOffset = CGFloat.random(in: -spreadX...spreadX)
        let yOffset = CGFloat.random(in: -spreadY...spreadY)
        let rotation = Double.random(in: -5...5)
        
        let type = generateRandomTaskType()
        
        let newTask = CognitiveTask(
            id: taskCounter,
            type: type,
            xOffset: xOffset,
            yOffset: yOffset,
            rotation: rotation
        )
        
        withAnimation(.easeInOut(duration: 1.2)) {
            tasks.append(newTask)
        }
    }
    
    private func completeTask(_ task: CognitiveTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        // Mark as completing to trigger internal animations if needed, though mostly
        // we'll just remove it with a transition.
        withAnimation(.easeInOut(duration: 0.5)) {
            tasks[index].isCompleting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                tasks.removeAll(where: { $0.id == task.id })
            }
        }
    }
    
    private func generateRandomTaskType() -> CognitiveTask.TaskType {
        let colors: [Color] = [.blue, .purple, .orange, .teal, .indigo, .pink]
        let color = colors.randomElement() ?? .blue
        
        let rand = Int.random(in: 0...3)
        switch rand {
        case 0:
            let prompts = ["Confirm Data", "Reject Input", "System Check", "Verify Status"]
            let required = Int.random(in: 2...4)
            return .multiTap(text: prompts.randomElement()!, required: required, color: color)
        case 1:
            return .slider(text: "Calibrate frequency", target: Double.random(in: 0.2...0.8), color: color)
        case 2:
            let requiredState = Bool.random()
            let text = requiredState ? "Ensure process is ACTIVE" : "Ensure process is HALTED"
            return .logicToggle(text: text, requiredState: requiredState, color: color)
        default:
            let words = ["RED", "BLUE", "GREEN", "YELLOW"]
            let validWord = words.randomElement()!
            
            var options: [CognitiveTask.StroopOption] = []
            let availableWords = words.shuffled()
            let availableColorIndices = [0, 1, 2, 3].shuffled()
            
            for i in 0..<3 {
                options.append(CognitiveTask.StroopOption(word: availableWords[i], colorIndex: availableColorIndices[i]))
            }
            
            if !options.contains(where: { $0.word == validWord }) {
                options[0] = CognitiveTask.StroopOption(word: validWord, colorIndex: availableColorIndices[0])
            }
            options.shuffle()
            
            return .stroop(prompt: "Select word: \(validWord)", validWord: validWord, options: options)
        }
    }
}

// Separate view for the individual task cards to keep the main file clean
struct CognitiveTaskView: View {
    let task: CognitiveLoadExperience.CognitiveTask
    let onComplete: () -> Void
    
    // Local state for interactive tasks
    @State private var currentTaps: Int = 0
    @State private var sliderValue: Double = 0.0
    @State private var toggleState: Bool = false
    @State private var isError: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Task Header
            HStack(spacing: 8) {
                Circle()
                    .fill(taskColor)
                    .frame(width: 8, height: 8)
                
                Text(taskTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if case let .multiTap(_, req, _) = task.type {
                    Text("\(currentTaps)/\(req)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .animation(.none, value: currentTaps)
                }
            }
            
            // Task Content Interaction
            Group {
                switch task.type {
                case .multiTap(let text, let required, let color):
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentTaps += 1
                        }
                        if currentTaps >= required {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onComplete()
                            }
                        }
                    }) {
                        Text(text)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(color)
                            .cornerRadius(8)
                    }
                    
                case .slider(let text, let target, let color):
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(text) (Target: \(Int(target * 100))%)")
                            .font(.caption2)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Slider(value: Binding(
                            get: { sliderValue },
                            set: { val in
                                sliderValue = val
                                if abs(val - target) < 0.04 {
                                    onComplete()
                                }
                            }
                        ), in: 0...1)
                        .tint(color)
                    }
                    
                case .logicToggle(let text, let required, let color):
                    VStack(alignment: .leading, spacing: 8) {
                        Text(text)
                            .font(.caption2)
                            .foregroundColor(.primary.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Toggle(isOn: Binding(
                            get: { toggleState },
                            set: { val in
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    toggleState = val
                                }
                                if val == required {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        if toggleState == required {
                                            onComplete()
                                        }
                                    }
                                }
                            }
                        )) {
                            Text(toggleState ? "ACTIVE" : "HALTED")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .animation(.none, value: toggleState)
                        }
                        .tint(color)
                    }
                    .onAppear {
                        toggleState = !required
                    }
                    
                case .stroop(let prompt, let validWord, let options):
                    VStack(alignment: .leading, spacing: 10) {
                        Text(prompt)
                            .font(.caption2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 8) {
                            ForEach(options, id: \.word) { option in
                                Button(action: {
                                    if option.word == validWord {
                                        onComplete()
                                    } else {
                                        showError()
                                    }
                                }) {
                                    Text(option.word)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.primary.opacity(0.06))
                                        .foregroundColor(getColor(from: option.colorIndex))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(width: 270)
        .background(.regularMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isError ? Color.red.opacity(0.6) : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
        .opacity(task.isCompleting ? 0 : 1)
        .scaleEffect(task.isCompleting ? 0.9 : 1.0)
        .offset(x: isError ? 6 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isError)
    }
    
    private func showError() {
        isError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isError = false
        }
    }
    
    private func getColor(from index: Int) -> Color {
        switch index {
        case 0: return .red
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        default: return .primary
        }
    }
    
    private var taskColor: Color {
        switch task.type {
        case .multiTap(_, _, let c), .slider(_, _, let c), .logicToggle(_, _, let c):
            return c
        case .stroop:
            return .purple
        }
    }
    
    private var taskTitle: String {
        switch task.type {
        case .multiTap: return "Action Sequence"
        case .slider: return "Fine Calibration"
        case .logicToggle: return "Logical Verification"
        case .stroop: return "Semantic Conflict"
        }
    }
}

struct InteractionPrecisionExperience: View {
    let isReflecting: Bool
    
    @State private var attempts = 0
    @State private var timeElapsed: Double = 0
    
    @State private var position: CGPoint = CGPoint(x: 200, y: 300)
    @State private var targetScale: CGFloat = 1.0
    @State private var tapFeedback: Color = .clear
    
    // Timer to drive the continuous, subtle evolution
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Top-Right Counter
                VStack {
                    HStack {
                        Spacer()
                        Text("Attempts: \(attempts)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 24)
                            .padding(.trailing, 24)
                            .opacity(attempts == 0 || isReflecting ? 0 : 1)
                            .animation(.easeInOut(duration: 1.2), value: attempts)
                            .animation(.easeInOut(duration: 1.2), value: isReflecting)
                    }
                    Spacer()
                }
                
                // Active Button
                Button(action: {
                    handleTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.red]),
                                    center: .topLeading,
                                    startRadius: 5,
                                    endRadius: 80 * targetScale
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                    .blur(radius: 1)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle())
                            )
                            .shadow(color: Color.red.opacity(0.4), radius: 8 * targetScale, x: 0, y: 5 * targetScale)
                            
                        // Muted internal tap feedback
                        Circle()
                            .fill(tapFeedback)
                    }
                    .frame(width: 80 * targetScale, height: 80 * targetScale)
                }
                .position(position)
            }
            .background(Color.clear.contentShape(Rectangle()).onTapGesture {
                handleTap() // Misses count as attempts too
            })
            .onAppear {
                position = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .onReceive(timer) { _ in
                guard !isReflecting else { return }
                timeElapsed += 0.1
                
                // 1. Target Size Variation
                let baseScale = max(0.3, 1.0 - (timeElapsed / 45.0))
                let fluctuation = sin(timeElapsed * 0.4) * 0.15
                withAnimation(.easeInOut(duration: 1.2)) {
                    targetScale = max(0.2, baseScale + fluctuation)
                }
                
                // 2. Target Movement (Subtle drift every 1.0 seconds, up from 1.5)
                if Int(timeElapsed * 10) % 10 == 0 {
                    let moveMultiplier = min(2.5, 1.0 + (timeElapsed / 15.0)) // Speeds up and moves further over time
                    let driftX = CGFloat.random(in: -50...50) * moveMultiplier
                    let driftY = CGFloat.random(in: -50...50) * moveMultiplier
                    
                    let newX = min(max(50, position.x + driftX), geo.size.width - 50)
                    let newY = min(max(100, position.y + driftY), geo.size.height - 100)
                    
                    withAnimation(.easeInOut(duration: 0.8)) {
                        position = CGPoint(x: newX, y: newY)
                    }
                }
            }
        }
        .blur(radius: isReflecting ? 15 : 0)
    }
    
    private func handleTap() {
        attempts += 1
        
        // 3. Input Delay
        let delay = min(0.6, timeElapsed * 0.01)
        
        // 4. Feedback Inconsistency
        let isMuted = Double.random(in: 0...1) < min(0.3, timeElapsed * 0.005)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if !isMuted {
                withAnimation(.easeIn(duration: 0.15)) {
                    tapFeedback = Color.white.opacity(0.4)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        tapFeedback = .clear
                    }
                }
            }
        }
    }
}
