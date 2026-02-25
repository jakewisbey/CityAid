import SwiftUI
import AVKit
import AVFoundation

struct VideoViewer: View {
    let videoURL: URL
    @State private var player: AVPlayer
    @Environment(\.dismiss) private var dismiss

    init(videoURL: URL) {
        self.videoURL = videoURL
        _player = State(initialValue: AVPlayer(url: videoURL))
    }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .aspectRatio(contentMode: .fit)
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 20))
                        .foregroundStyle(.opacity(0.9))
                        .frame(width: 45, height: 45)
                        .glassEffect(.clear.interactive().tint(.blue))
                        .padding(5)
                }
                .padding()

                Spacer()

                HStack {
                    Spacer()
                    Text("Tap to dismiss")
                        .font(.system(size: 16).italic())
                        .foregroundStyle(Color.gray.opacity(0.7))
                    Spacer()
                }
                .padding()
            }
            
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            player.actionAtItemEnd = .none
            player.play()

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem,
                                                   queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        .onDisappear() {
            player.pause()
            player.seek(to: .zero)
        }
    }
}
