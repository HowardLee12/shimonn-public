import SwiftUI

struct MessageView: View {
    @State private var subject: String = EmergencyMessage.defaultMessage.subject
    @State private var bodyText: String = EmergencyMessage.defaultMessage.body
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Email Subject")) {
                    TextField("Subject", text: $subject)
                }
                
                Section(header: Text("Email Body")) {
                    TextEditor(text: $bodyText)
                        .frame(height: 200)
                }
                
                Section {
                    Button("Save Changes") {
                        // Save logic here
                    }
                }
            }
            .navigationTitle("Emergency Message")
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
