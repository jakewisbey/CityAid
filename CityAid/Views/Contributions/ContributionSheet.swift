import SwiftUI
internal import CoreData
import PhotosUI

struct NewContributionSheet: View {
    var type: TypeOfContribution
    @Namespace private var pickerNamespace
    @State private var selectedType: TypeOfContribution
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var context
    let user: UserData
    @FocusState private var isTitleFocused: Bool
    
    init(type: TypeOfContribution, user: UserData) {
        self.type = type
        self.user = user
        _selectedType = State(initialValue: type)
    }
    
    var contributionManager: ContributionManager {
        ContributionManager(context: context, user: user)
    }
    
    @State private var contributionTitle: String = ""
    @State private var contributionDate: Date = Date()
    @State private var contributionMedia: [MediaItem] = []
    @State private var contributionNotes: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // Animation handling
    @State private var tappedPhotoID: String? = nil
    @State private var photoViewerImage: UIImage? = nil
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        TextField("Title", text: $contributionTitle)
                            .submitLabel(.done)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .focused($isTitleFocused)
                            .lineLimit(nil)
                        
                        Image(systemName: contributionTitle.isEmpty ? "pencil" : "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .contentTransition(.symbolEffect(.replace))
                            .onTapGesture {
                                contributionTitle = ""
                            }
                    }
                    
                    HStack(spacing: 2) {
                        Text("Type: ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Menu {
                            Button {
                                selectedType = .cleanliness
                            } label: {
                                Label("Cleanliness", systemImage: "bubbles.and.sparkles")
                            }
                            Button {
                                selectedType = .plantcare
                            } label: {
                                Label("Plant Care", systemImage: "leaf")
                            }
                            Button {
                                selectedType = .kindness
                            } label: {
                                Label("Kindness", systemImage: "heart")
                            }
                            Button {
                                selectedType = .donation
                            } label: {
                                Label("Donation", systemImage: "gift")
                            }
                            Button {
                                selectedType = .animalcare
                            } label: {
                                Label("Animal Care", systemImage: "dog")
                            }
                            Button {
                                selectedType = .other
                            } label: {
                                Label("Other", systemImage: "ellipsis.circle")
                            }
                            
                        } label: {
                            HStack {
                                Text("\(selectedType.rawValue)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        DatePicker("Date", selection: $contributionDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Text("Photos & Videos")
                        .font(.system(size: 24).bold())
                    
                    MediaPickerRow(contributionMedia: $contributionMedia, selectedItems: $selectedItems, onImageTap: { index, image in photoViewerImage = image; tappedPhotoID = "photo-\(index)" }, pickerNamespace: pickerNamespace)
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
                    
                    
                    
                    Text("Notes")
                        .font(.system(size: 20))
                        .foregroundColor(Color(.gray.withAlphaComponent(0.6)))
                        .padding(.top, 10)
                        .padding(.bottom, -5)
                    
                    TextEditor(text: $contributionNotes)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .scrollContentBackground(.hidden)
                        .background(.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.1))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Save Contribution") {
                        contributionManager.saveContribution(contributionTitle: contributionTitle, contributionDate: contributionDate, selectedType: selectedType, contributionNotes: contributionNotes)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(GlassButtonStyle())
                    
                    Text("Always ensure your contributions are safe, legal and respectful to people and public/private property. Check with your local council or environmental body for any specific guidelines.")
                        .font(.system(size: 14, weight: .regular))
                        .italic()
                        .foregroundStyle(.gray.opacity(0.8))
                        .padding(.bottom, 8)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(30)
            }
            .scrollDisabled(true)
            .ignoresSafeArea(.keyboard)
        }
        .background(LinearGradient(colors: [.purple.opacity(0.2), .black, .blue.opacity(0.2)],
                                   startPoint: UnitPoint(x: 0, y: 1),
                                   endPoint: UnitPoint(x: 1, y: 0)))
        .background(LinearGradient(colors: [.red.opacity(0.3), .black, .indigo.opacity(0.2)],
                                   startPoint: UnitPoint(x: 1, y: 1),
                                   endPoint: UnitPoint(x: 0, y: 0)))
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

struct MediaPickerRow: View {
    @Binding var contributionMedia: [MediaItem]
    @Binding var selectedItems: [PhotosPickerItem]
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
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                            .matchedTransitionSource(id: "photo-\(index)", in: pickerNamespace)
                            .onTapGesture {
                                onImageTap(index, image)
                            }
                    case .video(_):
                        Image(systemName: "play.rectangle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
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

enum TypeOfContribution: String, Identifiable, Codable, CaseIterable{
    case cleanliness = "Cleanliness"
    case plantcare = "Plant Care"
    case donation = "Donation"
    case kindness = "Kindness"
    case animalcare = "Animal Care"
    case other = "Other"
    
    var id: String { rawValue }
}

enum MediaItem {
    case photo(UIImage)
    case video(URL)
}

struct PhotoViewer: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(x: 1, y: 3, anchor: .center)
                .clipped()
                .blur(radius: 30)
                .overlay(Color.black.opacity(0.8))
                .ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 10)
                .onTapGesture {
                    dismiss()
                }
                
            
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 20))
                        .foregroundStyle(.opacity(0.9))
                        .frame(width: 45, height: 45)
                        .glassEffect(.clear.interactive().tint(.blue))
                        .padding(5)
                        .onTapGesture {
                            dismiss()
                        }
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

        }
    }
}






extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


#Preview("NewContributionSheet") {
    // In-memory Core Data stack for previews
    let container = NSPersistentContainer(name: "CityAidModel")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, _ in }
    let context = container.viewContext

    return NewContributionSheet(type: .cleanliness, user: UserData())
        .environment(\.managedObjectContext, context)
        .preferredColorScheme(.dark)
}


