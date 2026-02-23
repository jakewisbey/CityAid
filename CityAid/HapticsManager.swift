import SwiftUI
import UIKit
import AVFoundation

class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    public func selectionVibrate() {
        DispatchQueue.main.async {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    public func vibrate(type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
        }
    }
        
    public func test() {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1125)
            HapticsManager.shared.vibrate(type: .success)
        }
    }
}

struct hapticTestView: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.blue)
                .ignoresSafeArea()

            Text("Tap anywhere to play a sound")
        }
        .onTapGesture {
            HapticsManager.shared.test()
        }

    }
}

#Preview {
    hapticTestView()
}
