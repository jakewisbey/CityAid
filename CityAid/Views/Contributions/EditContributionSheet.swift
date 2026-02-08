import SwiftUI
internal import CoreData
import PhotosUI
import AVKit

struct EditContributionSheet: View {
    var contribution: ContributionEntity
    @Namespace private var pickerNamespace
    
    @State private var selectedType: TypeOfContribution
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var context
    let user: UserData
    @FocusState private var isTitleFocused: Bool
    
    init(contribution: ContributionEntity, user: UserData) {
        self.user = user
        self.contribution = contribution

        let initialType = TypeOfContribution(rawValue: contribution.type ?? "Cleanliness") ?? .cleanliness
        _selectedType = State(initialValue: initialType)

        _contributionTitle = State(initialValue: contribution.title ?? "")
        _contributionType = State(initialValue: initialType)
        _contributionDate = State(initialValue: contribution.date ?? Date())
        //media too pls
        _contributionNotes = State(initialValue: contribution.notes ?? "")
    }
    
    var contributionManager: ContributionManager {
        ContributionManager(context: context, user: user)
    }
    
    @State private var contributionTitle: String = ""
    @State private var contributionType: TypeOfContribution = .cleanliness
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
                    
                    MediaPickerRow(contributionMedia: $contributionMedia, selectedItems: $selectedItems, contributionManager: contributionManager, onImageTap: { index, image in photoViewerImage = image; tappedPhotoID = "photo-\(index)" }, pickerNamespace: pickerNamespace)
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
                        contributionManager.editContribution(contribution: contribution, contributionTitle: contributionTitle, contributionDate: contributionDate, selectedType: selectedType, contributionNotes: contributionNotes)
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
