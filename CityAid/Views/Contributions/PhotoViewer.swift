import SwiftUI

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
                
            
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .glassEffect(.clear.interactive().tint(.blue))
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
        .onTapGesture {
            dismiss()
        }
    }
}
