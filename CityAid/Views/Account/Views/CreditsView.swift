import SwiftUI

struct CreditsView: View {
    var body: some View {
        List {
            Section(
                header: Text("Icons")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            ) {
                HStack {
                    Text("Cleanliness Icon")
                    Spacer()
                    Link("smalllikeart", destination: URL(string: "https://www.flaticon.com/free-icon/bubbles_1678282")!)
                }
                
                HStack {
                    Text("Plant care Icon")
                    Spacer()
                    Link("Ahkâm", destination: URL(string: "https://www.freeiconspng.com/img/10680")!)
                }
                
                HStack {
                    Text("Kindness Icon")
                    Spacer()
                    Link("Succo Design", destination: URL(string: "https://www.softicons.com/holidays-icons/valentines-day-icons-by-succo-design/heart-icon")!)
                }
                
                HStack {
                    Text("Donation Icon")
                    Spacer()
                    Link("photo3idea_studio", destination: URL(string: "https://www.flaticon.com/free-icon/gift-box_4213958")!)
                }
                
                HStack {
                    Text("Animal care Icon")
                    Spacer()
                    Link("Freepik", destination: URL(string: "https://www.flaticon.com/free-icon/squirrel_1864480")!)
                }
                
                HStack {
                    Text("Other Icon")
                    Spacer()
                    Link("shapes", destination: URL(string: "https://www.shareicon.net/interface-mark-shapes-more-ellipsis-punctuation-three-dots-842377")!)
                }
            }
            
            Section(
                header: Text("Pictures")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            ) {
                HStack {
                    Text("Cityscape")
                    Spacer()
                    Link("Johannes Hurtig", destination: URL(string: "https://unsplash.com/photos/aerial-photography-of-cityscape-z-fpG7D7buk")!)
                }

                
                HStack {
                    Text("Cleanliness 1")
                    Spacer()
                    Link("Paul Schellenkens", destination: URL(string: "https://unsplash.com/photos/person-standing-beside-garbage-bin-c-R885Oc7k0")!)
                }
                
                HStack {
                    Text("Cleanliness 2")
                    Spacer()
                    Link("Pixel Shot", destination: URL(string: "https://unsplash.com/photos/pile-of-black-trash-bags-on-a-sidewalk-kxTwgF_uHow")!)
                }
                
                HStack {
                    Text("Plant care 1")
                    Spacer()
                    Link("Kwang Mathurosemontri", destination: URL(string: "https://unsplash.com/photos/shallow-focus-photography-of-white-and-pink-petaled-flowers-fY1ECB1RCd0")!)
                }
                
                HStack {
                    Text("Plant care 2")
                    Spacer()
                    Link("Freddie Entin", destination: URL(string: "https://unsplash.com/photos/a-bunch-of-pink-flowers-in-a-garden-Ynkntl4iZbg")!)
                }
                
                HStack {
                    Text("Kindness 1")
                    Spacer()
                    Link("Clay Banks", destination: URL(string: "https://unsplash.com/photos/blue-and-white-brick-wall-YrYSlTuBvBA")!)
                }
                
                HStack {
                    Text("Kindness 2")
                    Spacer()
                    Link("Kelly Sikkema", destination: URL(string: "https://unsplash.com/photos/person-reaching-black-heart-cutout-paper-XX2WTbLr3r8")!)
                }
                
                HStack {
                    Text("Donation 1")
                    Spacer()
                    Link("Claudia Raya", destination: URL(string: "https://unsplash.com/photos/a-large-amount-of-brown-paper-bags-1VOx-Ffbd9w")!)
                }
                
                HStack {
                    Text("Donation 2")
                    Spacer()
                    Link("Katt Yukawa", destination: URL(string: "https://unsplash.com/photos/person-showing-both-hands-with-make-a-change-note-and-coins-K0E6E0a0R3A")!)
                }

                HStack {
                    Text("Animal care 1")
                    Spacer()
                    Link("Özgür Avşar", destination: URL(string: "https://unsplash.com/photos/a-cat-enjoys-a-meal-outdoors-HQALIGDjy_M")!)
                }
                
                HStack {
                    Text("Animal care 2")
                    Spacer()
                    Link("Margarita Kosior", destination: URL(string: "https://unsplash.com/photos/white-and-brown-short-coated-dog-standing-on-brown-field-during-daytime-WVGGBALwXPE")!)
                }
            }
        }
        .navigationTitle("Credits")
    }
}

#Preview {
    CreditsView()
}
