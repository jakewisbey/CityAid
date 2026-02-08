import SwiftUI

struct OnboardingSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("OnboardingPicture")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.3)
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 50)
                Text("Welcome to")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(.gray.opacity(0.5)))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("CityAid")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                Text("Quickly log and monitor your contributions, complete challenges to stay motivated, earn badges for milestones, and learn how every action you take makes a meaningful difference in your community")
                    .font(.system(size: 12).italic())
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center) // centers lines
                    .lineLimit(nil) // allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // lets it expand vertically
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                
                VStack (spacing: 40){
                    HStack {
                        Image(systemName: "building.2")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)
                        
                        VStack (alignment: .leading, spacing: 4) {
                            Text("Log Contributions")
                                .font(.system(size: 20, weight: .bold))
                            Text("Log your contributions using the + button and keep a record of all the ways you help your community grow over time")
                                .font(.system(size: 12).italic())
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Image(systemName: "medal")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                        
                        VStack (alignment: .leading, spacing: 4) {
                            Text("Complete Challenges")
                                .font(.system(size: 20, weight: .bold))
                            Text("Complete daily and weekly challenges to increase your user level and earn unique badges for milestones you reach")
                                .font(.system(size: 12).italic())
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)

                    }
                    .padding(.horizontal, 20)

                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                        
                        VStack (alignment: .leading, spacing: 4) {
                            Text("Understand your impact")
                                .font(.system(size: 20, weight: .bold))
                            Text("See how your contributions are affecting your city and how you can make a difference in the future")
                                .font(.system(size: 12).italic())
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)

                    }
                    .padding(.horizontal, 20)
                }
                                
                VStack {
                    Button("Start contributing now") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 300, height: 50)
                    .glassEffect(.clear.interactive().tint(.blue))
                    .padding(.top, 85)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(.black))
    }
}


#Preview {
    OnboardingSheet()
}
