import SwiftUI
import PhotosUI

struct MediaPickerRow: View {
    @Binding var contributionMedia: [MediaItem]
    @Binding var selectedItems: [PhotosPickerItem]
    let contributionManager: ContributionManager
    var onImageTap: (Int, UIImage) -> Void
    var pickerNamespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(contributionMedia.indices, id: \.self) { index in
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
                        if let thumbnail = contributionManager.generateThumbnail(from: url) {
                            ZStack {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(15)
                                
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)

                            }
                        }
                    }
                }

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
