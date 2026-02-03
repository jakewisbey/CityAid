import SwiftUI
internal import CoreData
import PhotosUI

struct NewContributionSheet: View {
    var type: TypeOfContribution
    @State private var selectedType: TypeOfContribution
    
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
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
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
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 10) {
                            ForEach(contributionMedia.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    let media = contributionMedia[index]
                                    switch media {
                                    case .photo(let image):
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(15)
                                    case .video(_):
                                        Image(systemName: "play.rectangle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
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
                    .onChange(of: selectedItems) { oldItems, newItems in
                        contributionMedia.removeAll()
                        
                        for item in newItems {
                            contributionManager.handlePickerItem(item: item, contributionMedia: $contributionMedia)
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

struct Contribution {
    var id = UUID()
    var type : TypeOfContribution
    var title : String
    var date: Date
    var media: [MediaItem]
    var notes: String?
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


final class PreviewPersistenceController {
    static let shared = PreviewPersistenceController()
    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "CityAid")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
    }
    var context: NSManagedObjectContext { container.viewContext }
}

#Preview {
    let user = UserData()
    let previewContext = PreviewPersistenceController.shared.context
    
    return NewContributionSheet(type: .cleanliness, user: user)
        .environment(\.managedObjectContext, previewContext)
}
