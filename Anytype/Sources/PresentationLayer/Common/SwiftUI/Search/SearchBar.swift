import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    let focused: Bool
        
    var body: some View {
        Group {
            if focused {
                AutofocusedTextField(title: "Search".localized, text: $text)
            } else {
                TextField("Search".localized, text: $text)
            }
        }
        .padding(8)
        .padding(.horizontal, 25)
        .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
        .background(Color.grayscale10)
        .cornerRadius(10)
        .overlay(overlay)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private var overlay: some View {
        HStack() {
            Image.SearchBar.magnifyingGlass
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.grayscale50)
                .frame(width: 14, height: 14)
                .padding(.leading, 11)
            
            Spacer()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image.SearchBar.circleFill
                        .renderingMode(.template)
                        .foregroundColor(.grayscale50)
                        .padding(.trailing, 8)
                }
            }
            
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), focused: true)
    }
}
