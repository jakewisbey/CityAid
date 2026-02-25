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
    
    // Had in-built Apple Intelligence help with this one, as was having a lot of trouble storing videos
    // however, it was my idea to convert all videos to mp4 before saving because photos picker apparently can't handle other types of video, but this is quite slow for videos which are not already compatible
    func handlePickerItem(item: PhotosPickerItem, contributionMedia: Binding<[MediaItem]>) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data?):
                if let image = UIImage(data: data) {
                    // image case
                    DispatchQueue.main.async {
                        contributionMedia.wrappedValue.append(.photo(image))
                    }
                } else {
                    // treat as video
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                    do {
                        try data.write(to: tempURL)
                    } catch {
                        print("failed to save video data:", error)
                        return
                    }

                    // check if conversion is needed
                    let fileExtension = tempURL.pathExtension.lowercased()
                    if fileExtension == "mov" || fileExtension == "mp4" {
                        // likely compatible, append directly
                        DispatchQueue.main.async {
                            contributionMedia.wrappedValue.append(.video(tempURL))
                        }
                    } else {
                        // export to mp4
                        let asset = AVURLAsset(url: tempURL)
                        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                            print("Could not create export session")
                            return
                        }
                        let mp4URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                        exportSession.outputURL = mp4URL
                        exportSession.outputFileType = .mp4
                        exportSession.exportAsynchronously {
                            if exportSession.status == .completed {
                                DispatchQueue.main.async {
                                    contributionMedia.wrappedValue.append(.video(mp4URL))
                                }
                            } else {
                                print("Video export failed:", exportSession.error?.localizedDescription ?? "unknown error")
                            }
                        }
                    }
                }
            case .success(nil):
                print("No data returned from picker item")
            case .failure(let error):
                print("failed to load transferable:", error)
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    }
    
    // Source - https://stackoverflow.com/a/40987452
    // Posted by David Seek, modified by community. See post 'Timeline' for change history
    // Retrieved 2026-02-25, License - CC BY-SA 4.0

    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    // Convenience overload to match call sites using `from:`
    func generateThumbnail(from url: URL) -> UIImage? {
        return generateThumbnail(path: url)
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
        
        AudioServicesPlaySystemSound(1125)
        HapticsManager.shared.vibrate(type: .success)

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
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback()
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
        
        AudioServicesPlaySystemSound(1125)
        HapticsManager.shared.vibrate(type: .success)

        
        // convert to data and store
        contribution.media = try? JSONEncoder().encode(mediaData)

        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback()
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
    
    func duplicateContribution(contribution: ContributionEntity, duplicateDate: Bool, user: UserData) {
        let duplicateContribution = ContributionEntity(context: context)
        
        duplicateContribution.id = UUID()
        duplicateContribution.title = contribution.title
        duplicateContribution.type = contribution.type
        
        if duplicateDate {
            duplicateContribution.date = contribution.date
        } else {
            duplicateContribution.date = Date()
        }
        
        duplicateContribution.media = contribution.media

        duplicateContribution.xp = contribution.xp
        user.xp += Int(duplicateContribution.xp)
        duplicateContribution.notes = contribution.notes
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback()
        }
    }
        
    func deleteContribution (contribution: ContributionEntity) {
        // remove 2/3 of previously awarded xp from user.xp, and recalculate level in case it goes negative
        user.xp -= ( 2 * Int(contribution.xp) / 3 )
        user.CalculateUserLevel()
        context.delete(contribution)
        
        AudioServicesPlaySystemSound(1126)
        HapticsManager.shared.vibrate(type: .warning)
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Core Data save error:", error)
            print("userInfo:", error.userInfo)
            context.rollback()
        }
    }
    
    func deleteAllContributions(contributions: FetchedResults<ContributionEntity>) {
        // this only deletes all contributions and related stars, does not affect anything else.
        contributions.forEach {
            context.delete($0)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Core Data save error:", error)
                print("userInfo:", error.userInfo)
                context.rollback()
            }
        }
    }
    
    func getMediaItems(from contribution: ContributionEntity) -> [MediaItem] {
        guard let mediaData = contribution.media else { return [] }
        
        do {
            let paths = try JSONDecoder().decode([String].self, from: mediaData)
            return paths.compactMap { path in
                let url = URL(fileURLWithPath: path)
                if path.hasSuffix(".jpg"), let image = UIImage(contentsOfFile: path) {
                    return .photo(image)
                } else if path.lowercased().hasSuffix(".mp4") || path.lowercased().hasSuffix(".mov") || path.lowercased().hasSuffix(".m4v") {
                    return .video(url)
                }
                return nil
            }
        } catch {
            print("Error decoding media from contribution:", error)
            return []
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
