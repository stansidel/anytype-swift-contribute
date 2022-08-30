import SwiftUI
import Kingfisher

// figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=4061%3A0
struct HomeCell: View {
    let cellData: HomeCellData
    let selected: Bool
    
    private var isRedacted: Bool {
        cellData.isLoading
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            icon
            iconSpacer
            title
            Spacer(minLength: 1)
            type
        }
        .padding(padding)
        .frame(height: 126)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundDashboard)
        .redacted(reason: isRedacted ? .placeholder : [])
        .cornerRadius(16)
        
        .if(selected) {
            $0.overlay(
                Image(asset: .selection)
                    .frame(width: 20, height: 20)
                    .padding([.trailing, .bottom], 10),
                alignment: .bottomTrailing
            )
        }
    }
    
    private var padding: EdgeInsets {
        if cellData.title.isTodo {
            return EdgeInsets(top: 16, leading: 11, bottom: 13, trailing: 16)
        } else {
            return EdgeInsets(top: 16, leading: 16, bottom: 13, trailing: 16)
        }
    }
    
    private var title: some View {
        Group {
            switch cellData.title {
            case let .default(title):
                defaultTitle(with: title, lineLimit: cellData.icon.isNil ? 4 : 1)
            case let .todo(title, isChecked):
                todoTitle(with: title, isChecked: isChecked)
            }
        }
    }
    
    private func defaultTitle(with text: String, lineLimit: Int?) -> some View {
        var titleString = text.isEmpty ? Loc.untitled : text
        titleString = isRedacted ? Loc.RedactedText.pageTitle : titleString
        
        return AnytypeText(titleString, style: .previewTitle2Medium, color: .textPrimary)
            .lineLimit(lineLimit)
            .multilineTextAlignment(.leading)
    }
    
    private func todoTitle(with text: String, isChecked: Bool) -> some View {
        HStack(alignment: .top, spacing: 6) {
            SwiftUIObjectIconImageView(
                iconImage: .todo(isChecked),
                usecase: .dashboardList
            ).frame(width: 18, height: 18)
            defaultTitle(with: text, lineLimit: nil).multilineTextAlignment(.leading)
        }
    }
    
    private var type: some View {
        let type = isRedacted ? Loc.RedactedText.pageType : cellData.type
        return AnytypeText(type, style: .relation3Regular, color: .textSecondary)
            .if(cellData.title.isTodo) {
                $0.padding(.leading, 5)
            }
    }
    
    private var icon: some View {
        Group {
            if isRedacted {
                RoundedRectangle(
                    cornerRadius: Constants.iconCornerRadius
                )
                    .foregroundColor(Color.strokeTertiary)
                    .frame(
                        width: Constants.iconSize.width,
                        height: Constants.iconSize.height
                    )
            } else {
                switch cellData.icon {
                case .some(let icon):
                    SwiftUIObjectIconImageView(
                        iconImage: .icon(icon),
                        usecase: .dashboardList
                    ).frame(
                        width: Constants.iconSize.width,
                        height: Constants.iconSize.height
                    )
                case .none:
                    EmptyView()
                }
            }
        }
    }

    private var iconSpacer: some View {
        Group {
            if cellData.icon.isNotNil || isRedacted {
                Spacer(minLength: 12)
            } else {
                EmptyView()
            }
        }
    }
}

private extension HomeCell {
    
    enum Constants {
        static let iconSize = CGSize(width: 48, height: 48)
        static let iconCornerRadius: CGFloat = 2
    }
    
}


struct HomeCell_Previews: PreviewProvider {
    static let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    static var previews: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(HomeCellDataMock.data) { data in
                    HomeCell(cellData: data, selected: false)
                }
            }
            .padding()
        }
        .background(Color.orange.ignoresSafeArea())
    }
}
