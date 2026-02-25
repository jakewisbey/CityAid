import SwiftUI
import PhotosUI

struct MediaPickerRow: View {
    @Binding var contributionMedia: [MediaItem]
    @Binding var selectedItems: [PhotosPickerItem]
    let contributionManager: ContributionManager
    var onImageTap: (Int, UIImage) -> Void
    var onVideoTap: (Int, URL) -> Void
    var pickerNamespace: Namespace.ID
    let showPicker: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(Array(contributionMedia.enumerated()), id: \.offset) { index, _ in
                    let media = contributionMedia[index]
                    switch media {
                    case .photo(let image):
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(15)
                            .matchedTransitionSource(id: "photo-\(index)", in: pickerNamespace)
                            .onTapGesture {
                                onImageTap(index, image)
                            }
                        
                    case .video(let url):
                        if let thumbnail = contributionManager.generateThumbnail(path: url) {
                            let _ = print("video at index \(index), url: \(url)")
                            ZStack {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(15)
                                
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .contentShape(Rectangle())
                            .matchedTransitionSource(id: "video-\(index)", in: pickerNamespace)
                            .onTapGesture {
                                onVideoTap(index, url)
                            }

                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)

                            }
                            .matchedTransitionSource(id: "video-\(index)", in: pickerNamespace)
                            .onTapGesture {
                                onVideoTap(index, url)
                            }
                        }
                    }
                }

                if showPicker {
                    PhotosPicker(
                        selection: $selectedItems,
                        matching: .any(of: [.images, .videos])
                    ) {
                        Image(systemName: "plus")
                            .font(.system(size: 36, weight: .bold))
                            .frame(width: 100, height: 100)
                            .background(.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white.opacity(0.1))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}
