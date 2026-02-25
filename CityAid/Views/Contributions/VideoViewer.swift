import SwiftUI
import AVKit

struct VideoViewer: View {
    let videoURL: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .scaledToFill()
            .cornerRadius(8)
            .padding()
    }
}
