import SwiftUI
import PhotosUI
import AVKit
internal import CoreData

class ContributionManager {
    let context: NSManagedObjectContext
    var user: UserData

    init(user: UserData, context: NSManagedObjectContext) {
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
    
    func saveContribution(contributionTitle: String, contributionDate: Date, contributionMedia: [MediaItem], selectedType: TypeOfContribution, contributionNotes: String, showStreakAnimation: Binding<Bool>) {
        
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
        
        
        // handle media stuff
        var mediaData: [String] = []
        for media in contributionMedia {
            // make files for the media stuff in the filemanager
            switch media {
            case .photo(let image):
                let filename = UUID().uuidString + ".jpg"
                if let url = saveImageToAppFolder(image: image, filename: filename) {
                    mediaData.append(url.path)
                }
                
            case .video(let url):
                if let url = copyMediaToAppFolder(originalURL: url) {
                    mediaData.append(url.path)
                }
            }
        }
        
        // convert to data and store
        do {
            entity.media = try JSONEncoder().encode(mediaData)
        } catch {
            print("media encode failed", error)
            entity.media = Data()
        }
        
        let randomXp = Int.random(in: 4...8)
        entity.xp = Int16(randomXp)
        user.xp += randomXp
        user.CalculateUserLevel()
        
        
        
        if !user.isStreakCompletedToday {
            user.isStreakCompletedToday = true
            user.streak += 1
        }
        
        /*
         if user.isStreakCompletedToday && !user.playedStreakAnimation {
         showStreakAnimation.wrappedValue = true
         }
         */
        print("changedValues:", entity.changedValues())
        print("id:", entity.id as Any)
          print("date:", entity.date as Any)
          print("type:", entity.type as Any)
          print("xp:", entity.xp)
          print("title:", entity.title as Any)
          print("notes:", entity.notes as Any)
          print("media is Data:", entity.media != nil)
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback() // important to discard the bad insert/update
        }
    }
    
    func editContribution(contribution: ContributionEntity, contributionTitle: String, contributionDate: Date, contributionMedia: [MediaItem], selectedType: TypeOfContribution, contributionNotes: String) {
        contribution.title = contributionTitle
        contribution.date = contributionDate
        contribution.type = selectedType.rawValue
        contribution.notes = contributionNotes
        
        var mediaData: [String] = []
        
        // handle media stuff
        for media in contributionMedia {
            // make files for the media stuff in the filemanager
            switch media {
            case .photo(let image):
                let filename = UUID().uuidString + ".jpg"
                if let url = saveImageToAppFolder(image: image, filename: filename) {
                    mediaData.append(url.path)
                }
                
            case .video(let url):
                if let url = copyMediaToAppFolder(originalURL: url) {
                    mediaData.append(url.path)
                }
            }
        }
        
        // convert to data and store
        contribution.media = try? JSONEncoder().encode(mediaData)
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback() // important to discard the bad insert/update
        }
    }
    
    func copyMediaToAppFolder(originalURL: URL) -> URL? {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newURL = docs.appendingPathComponent(originalURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: newURL.path) {
                try fileManager.removeItem(at: newURL)
            }
            try fileManager.copyItem(at: originalURL, to: newURL)
            return newURL
        } catch {
            print("Error copying file: \(error)")
            return nil
        }
    }
    
    func saveImageToAppFolder(image: UIImage, filename: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(filename)
        
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
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
