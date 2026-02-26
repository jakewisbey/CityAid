import SwiftUI
internal import CoreData
import PhotosUI
import AVKit

struct ViewContributionSheet: View {
    var contribution: ContributionEntity
    @Namespace private var pickerNamespace
    
    @State private var selectedType: TypeOfContribution
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var context
    let user: UserData
    @FocusState private var isTitleFocused: Bool
    
    
    init(contribution: ContributionEntity, user: UserData, contributionToEdit: Binding<ContributionEntity?>) {
        self.user = user
        self.contribution = contribution

        let initialType = TypeOfContribution(rawValue: contribution.type ?? "Cleanliness") ?? .cleanliness
        _selectedType = State(initialValue: initialType)

        _contributionID = State(initialValue: contribution.id?.uuidString ?? "")
        _contributionTitle = State(initialValue: contribution.title ?? "")
        _contributionType = State(initialValue: initialType)
        _contributionDate = State(initialValue: contribution.date ?? Date())
        
        if let mediaData = contribution.media,
           let paths = try? JSONDecoder().decode([String].self, from: mediaData) {
            // map strings to MediaItem
            let mediaItems = paths.map { path -> MediaItem in
                if path.hasSuffix(".jpg") {
                    // image file
                    if let image = UIImage(contentsOfFile: path) {
                        return .photo(image)
                    } else {
                        return .photo(UIImage()) // fallback placeholder
                    }
                } else {
                    // assume video
                    return .video(URL(fileURLWithPath: path))
                }
            }
            _contributionMedia = State(initialValue: mediaItems)
        } else {
            _contributionMedia = State(initialValue: [])
        }
        _contributionNotes = State(initialValue: contribution.notes ?? "")
        
        self._contributionToEdit = contributionToEdit
    }
    
    var contributionManager: ContributionManager {
        ContributionManager(user: user, context: context)
    }
    
    @State private var contributionID: String
    @State private var contributionTitle: String = ""
    @State private var contributionType: TypeOfContribution = .cleanliness
    @State private var contributionDate: Date = Date()
    @State private var contributionMedia: [MediaItem] = []
    @State private var contributionNotes: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // Animation handling
    @State private var tappedPhotoID: String? = nil
    @State private var photoViewerImage: UIImage? = nil
    
    @State private var tappedVideoID: String? = nil
    @State private var videoViewerURL: URL? = nil

    @Binding private var contributionToEdit: ContributionEntity?
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section (header: Text("Attributes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.5)),
                             footer: Text("ID: " + contributionID)
                    ) {
                        HStack(spacing: 2) {
                            Text("Type:")
                            Spacer()
                            Text(contribution.type ?? "Error")
                        }
                        
                        
                        HStack {
                            Text("Date:")
                            Spacer()
                            Text(contributionDate, format: .dateTime.day(.twoDigits).month(.twoDigits).year())
                        }
                        
                        VStack {
                            if contributionMedia.count == 0 {
                                HStack {
                                    Text("Photos & Videos")
                                    Spacer()
                                    Text("None")
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Photos & Videos")
                                    
                                    MediaPickerRow(contributionMedia: $contributionMedia,
                                                   selectedItems: $selectedItems,
                                                   contributionManager: contributionManager,
                                                   onImageTap: { index, image in photoViewerImage = image; tappedPhotoID = "photo-\(index)"},
                                                   onVideoTap: { index, url in videoViewerURL = url; tappedVideoID = "video-\(index)"},
                                                   pickerNamespace: pickerNamespace,
                                                   showPicker: false)
                                    .onChange(of: selectedItems) { oldItems, newItems in
                                        contributionMedia.removeAll()
                                        
                                        for item in newItems {
                                            contributionManager.handlePickerItem(item: item, contributionMedia: $contributionMedia)
                                        }
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { photoViewerImage != nil },
                                        set: { if !$0 { photoViewerImage = nil; tappedPhotoID = nil } }
                                    )) {
                                        if let image = photoViewerImage, let sourceID = tappedPhotoID {
                                            PhotoViewer(image: image)
                                                .navigationTransition(.zoom(sourceID: sourceID, in: pickerNamespace))
                                        }
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { videoViewerURL != nil },
                                        set: { if !$0 { videoViewerURL = nil; tappedVideoID = nil } }
                                    )) {
                                        if let url = videoViewerURL, let sourceID = tappedVideoID {
                                            VideoViewer(videoURL: url)
                                                .navigationTransition(.zoom(sourceID: sourceID, in: pickerNamespace))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes:")
                            Text(contributionNotes)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.interactively)
                .scrollContentBackground(.hidden)
                .navigationTitle("Untitled")
            }
            .padding(.top, 15)
            
            
            HStack {
                Menu {
                    Menu {
                        Button {
                            contributionManager.duplicateContribution(contribution: contribution, duplicateDate: false, user: user)
                        } label: {
                            Label("Today's date", systemImage: "calendar")
                        }
                        
                        Button {
                            contributionManager.duplicateContribution(contribution: contribution, duplicateDate: true, user: user)
                        } label: {
                            Label("Keep original", systemImage: "calendar.badge.clock")
                        }
                        
                    } label: {
                        Label("Duplicate", systemImage: "document.on.document")
                    }
                    
                    Button {
                       contributionToEdit = contribution
                        dismiss()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        contributionManager.deleteContribution(contribution: contribution)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .glassEffect(.clear.interactive())
                }
                
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .glassEffect(.clear.interactive().tint(.blue))
                    .onTapGesture {
                        dismiss()
                    }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(20)

        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTitleFocused = true
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            contributionManager.hideKeyboard()
        }
    }
}




#Preview {
    let container = PreviewPersistenceController.shared
    let context = container.viewContext

    // create dummy contribution
    let contribution = ContributionEntity(context: context)
    contribution.id = UUID()
    contribution.title = "Test Title"
    contribution.type = "Cleanliness"
    contribution.date = Date()
    contribution.notes = "This is a test contribution. A longer note is used to ensure that it wraps correctly arount the avaliable space"

    // dummy user
    let user = UserData()

    return ViewContributionSheet(
        contribution: contribution,
        user: user,
        contributionToEdit: .constant(nil)
    )
    .environment(\.managedObjectContext, context)
}
