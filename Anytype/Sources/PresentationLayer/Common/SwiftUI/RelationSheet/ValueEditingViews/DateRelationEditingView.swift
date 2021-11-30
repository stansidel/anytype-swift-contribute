import SwiftUI

struct DateRelationEditingView: View {
    
    @ObservedObject var viewModel: DateRelationEditingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.values, id: \.self) { value in
                DateRelationRowView(
                    value: value,
                    isSelected: value == viewModel.selectedValue
                )
            }
            Spacer.fixedHeight(20)
            StandardButtonView(text: "Apply".localized, style: .primary)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
    }
}

struct DateRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        DateRelationEditingView(
            viewModel: DateRelationEditingViewModel(
                service: DetailsService(objectId: ""),
                key: "",
                value: nil
            )
        )
    }
}
