//
//  ObjectSettingsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Amplitude


struct ObjectSettingsView: View {
    
    @EnvironmentObject var viewModel: ObjectSettingsViewModel
    
    @Binding var isCoverPickerPresented: Bool
    @Binding var isIconPickerPresented: Bool
    @Binding var isLayoutPickerPresented: Bool
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 0
        ) {
            DragIndicator(bottomPadding: 0)
            settings
        }
        .background(Color.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 4)
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.settings, id: \.self) { setting in
                ObjectSettingRow(setting: setting) {
                    switch setting {
                    case .icon:
                        isIconPickerPresented = true
                    case .cover:
                        // Analytics
                        Amplitude.instance().logEvent(AmplitudeEventsName.buttonProfileWallpaper)
                        
                        isCoverPickerPresented = true
                    case .layout:
                        withAnimation() {
                            isLayoutPickerPresented = true
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing, .bottom], 16)
    }
}

struct ObjectSettingsView_Previews: PreviewProvider {
    @State static private var isIconPickerPresented = false
    @State static private var isCoverPickerPresented = false
    @State static private var isLayoutPickerPresented = false
    
    static var previews: some View {
        ObjectSettingsView(
            isCoverPickerPresented: $isCoverPickerPresented,
            isIconPickerPresented: $isIconPickerPresented,
            isLayoutPickerPresented: $isLayoutPickerPresented
        )
        .environmentObject(ObjectSettingsViewModel(objectDetailsService: ObjectDetailsService(eventHandler: EventHandler(), objectId: "")))
    }
}
