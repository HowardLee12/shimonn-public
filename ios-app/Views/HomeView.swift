import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Status Indicator
                VStack(spacing: 10) {
                    Text("Time Remaining")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.timeRemainingString)
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundColor(colorForStatus(viewModel.timeRemainingColor))
                }
                
                // Big Check-in Button
                Button(action: {
                    viewModel.checkIn()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 10)
                        
                        Text("I'M ALIVE")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Text("Last Check-in: \(viewModel.lastCheckIn, style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Dead Man's Switch")
            .padding()
        }
    }
    
    func colorForStatus(_ status: String) -> Color {
        switch status {
        case "Critical": return .red
        case "Warning": return .orange
        default: return .green
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
