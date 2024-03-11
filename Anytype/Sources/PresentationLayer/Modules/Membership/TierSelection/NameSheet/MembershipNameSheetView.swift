import SwiftUI
import Services


struct MembershipNameSheetView: View {    
    @StateObject private var model: MembershipNameSheetViewModel
    @State private var name = ""
    
    init(tier: MembershipTier) {
        _model = StateObject(
            wrappedValue: MembershipNameSheetViewModel(tier: tier)
        )
    }
    
    var body: some View {
        content
            .background(Color.Background.primary)
            .onChange(of: name) { name in
                model.validateName(name: name)
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(26)
            AnytypeText(Loc.Membership.NameForm.title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(Loc.Membership.NameForm.subtitle, style: .calloutRegular, color: .Text.primary)
            Spacer.fixedHeight(10)
            HStack {
                TextField(Loc.myself, text: $name)
                    .textContentType(.username)
                AnytypeText(".any", style: .bodyRegular, color: .Text.primary)
            }
            .padding(.vertical, 12)
            .newDivider()
            status
            AnytypeText("$99 ", style: .title, color: .Text.primary) +
            AnytypeText(Loc.perYear, style: .relation1Regular, color: .Text.primary)
            Spacer.fixedHeight(15)
            StandardButton(
                Loc.payByCard,
                style: .primaryLarge
            ) {
                // TODO: Pay
            }
            .disabled(!model.state.isValidated)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
    }
    
    var status: some View {
        HStack {
            Spacer()
            switch model.state {
            case .default:
                Spacer.fixedHeight(28)
            case .validating:
                AnytypeText(Loc.Membership.NameForm.validating, style: .relation2Regular, color: .Text.secondary)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            case .error(text: let text):
                AnytypeText(text, style: .relation2Regular, color: .Dark.red)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            case .validated:
                AnytypeText(Loc.Membership.NameForm.validated, style: .relation2Regular, color: .Dark.green)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            }
            Spacer()
        }
        .lineLimit(1)
    }
}

#Preview {
    MembershipNameSheetView(tier: .builder)
}
