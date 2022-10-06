import SwiftUI

struct MessageView: View {
    @EnvironmentObject var state: StateController
    
    var body: some View {
        VStack {
            ForEach(state.getMessages(), id: \.self) { message in
                HStack {
                    Text(message)
                        .foregroundColor(message.contains("\"") ? Color.white :  Color(UIColor.lightGray))
                        .font(.system(size: 12, design: .monospaced))
                    Spacer()
                }
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
            .environmentObject(StateController())
    }
}
