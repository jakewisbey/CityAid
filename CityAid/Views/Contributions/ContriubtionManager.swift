import SwiftUI
import PhotosUI
import AVKit
internal import CoreData

class ContributionManager {
    var context: NSManagedObjectContext
    var user: UserData
    
    init(context: NSManagedObjectContext, user: UserData) {
        self.context = context
        self.user = user
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
    }
    
    func handlePickerItem(item: PhotosPickerItem, contributionMedia: Binding<[MediaItem]>) {
        item.loadTransferable(type: Data.self) { result in
            if case .success(let data?) = result,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    contributionMedia.wrappedValue.append(.photo(image))
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            }
    }
    
    func generateThumbnail(from url: URL, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600)) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    func saveContribution(contributionTitle: String, contributionDate: Date, selectedType: TypeOfContribution, contributionNotes: String) {
        let entity = ContributionEntity(context: context)
        entity.id = UUID()
        
        
        if contributionTitle.isEmpty {
            entity.title = "Unnamed Contribution"
        } else {
            entity.title = contributionTitle
        }
        
        entity.date = contributionDate
        entity.type = selectedType.rawValue
        
        if contributionNotes.isEmpty {
            entity.notes = "No notes"
        } else {
            entity.notes = contributionNotes
        }
        
        let randomXp = Int.random(in: 4...8)
        
        if !user.isStreakCompletedToday {
            user.isStreakCompletedToday = true
            user.streak += 1
        }
        
        user.xp += randomXp
        try? context.save()
    }

    func editContribution (contribution: ContributionEntity, contributionTitle: String, contributionDate: Date, selectedType: TypeOfContribution, contributionNotes: String) {
        contribution.title = contributionTitle
        contribution.date = contributionDate
        contribution.type = selectedType.rawValue
        contribution.notes = contributionNotes
        
        try? context.save()
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
