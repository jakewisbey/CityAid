import SwiftUI
import PhotosUI
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

}
