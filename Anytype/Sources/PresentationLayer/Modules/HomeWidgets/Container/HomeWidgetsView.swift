import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetsView: View {
    let info: AccountInfo
    let output: (any HomeWidgetsModuleOutput)?
    
    var body: some View {
        HomeWidgetsInternalView(info: info, output: output)
            .id(info.hashValue)
    }
}

private struct HomeWidgetsInternalView: View {
    @StateObject private var model: HomeWidgetsViewModel
    @State var dndState = DragState()
    
    init(info: AccountInfo, output: (any HomeWidgetsModuleOutput)?) {
        self._model = StateObject(wrappedValue: HomeWidgetsViewModel(info: info, output: output))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            DashboardWallpaper(wallpaper: model.wallpaper)
            VerticalScrollViewWithOverlayHeader {
                HomeTopShadow()
            } content: {
                VStack(spacing: 12) {
                    if model.dataLoaded {
                        if FeatureFlags.updateAlert {
                            HomeUpdateSubmoduleView()
                        }
                        SpaceWidgetView {
                            model.onSpaceSelected()
                        }
                        if #available(iOS 17.0, *) {
                            WidgetSwipeTipView()
                        }
                        ForEach(model.widgetBlocks) { widgetInfo in
                            HomeWidgetSubmoduleView(widgetInfo: widgetInfo, widgetObject: model.widgetObject, homeState: $model.homeState, output: model.output)
                        }
                        BinLinkWidgetView(spaceId: model.spaceId, homeState: $model.homeState, output: model.submoduleOutput())
                        if FeatureFlags.discussions {
                            HomeEditButton(text: "Discussion for test", homeState: model.homeState) {
                                model.onTapDiscussion()
                            }
                        }
                        editButtons
                    }
                    AnytypeNavigationSpacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .fitIPadToReadableContentGuide()
            }
            .animation(.default, value: model.widgetBlocks.count)
            
            HomeBottomPanelView(homeState: $model.homeState) {
                model.onCreateWidgetFromEditMode()
            }
        }
        .task {
            await model.startWidgetObjectTask()
        }
        .task {
            await model.startParticipantTask()
        }
        .onAppear {
            model.onAppear()
        }
        .navigationBarHidden(true)
        .anytypeStatusBar(style: .lightContent)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .homeBottomPanelHidden(model.homeState.isEditWidgets)
        .anytypeVerticalDrop(data: model.widgetBlocks, state: $dndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
    }
    
    private var editButtons: some View {
        EqualFitWidthHStack(spacing: 12) {
            HomeEditButton(text: Loc.Widgets.Actions.addWidget, homeState: model.homeState) {
                model.onCreateWidgetFromMainMode()
            }
            HomeEditButton(text: Loc.Widgets.Actions.editWidgets, homeState: model.homeState) {
                model.onEditButtonTap()
            }
        }
    }
}
