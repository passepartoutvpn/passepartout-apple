//
//  ProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import Combine
import PassepartoutCore

struct ProfileView: View {
    enum ModalType: Int, Identifiable {
        case rename
        
        case paywallTrustedNetworks

        var id: Int {
            return rawValue
        }
    }

    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject private var profileManager: ProfileManager
    
    private let header: Profile.Header
    
    private var isDeleted: Bool {
        !profileManager.isExistingProfile(withId: header.id)
    }

    @State private var modalType: ModalType?
    
    @State private var isLoaded = false

    @State private var isAskingRemoveProfile = false
    
    init(header: Profile.Header?) {
        let profileManager: ProfileManager = .shared
        
        self.profileManager = profileManager
        self.header = header ?? profileManager.activeHeader ?? Profile.placeholder.header
    }

    var body: some View {
        debugChanges()
        return Group {
            if !isDeleted {
                List {
                    if isLoaded {
                        mainView
                    } else {
                        loadingSection
                    }
                }
            } else {
                welcomeView
            }
        }.themeSecondaryView()
        .navigationTitle(title)
        .toolbar(content: toolbar)
        .sheet(item: $modalType, content: presentedModal)
        .onAppear(perform: loadProfileIfNeeded)
    }
    
    private var title: String {
        !isDeleted ? header.name : ""
    }
    
    @ViewBuilder
    private var mainView: some View {
        VPNSection(currentProfile: profileManager.currentProfile)
        ProviderSection(currentProfile: profileManager.currentProfile)
        ConfigurationSection(
            currentProfile: profileManager.currentProfile,
            modalType: $modalType
        )
        ExtraSection(currentProfile: profileManager.currentProfile)
        DiagnosticsSection(currentProfile: profileManager.currentProfile)
        removeProfileSection
    }
    
    private var welcomeView: some View {
        WelcomeView()
    }
    
    private func toolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !isDeleted {
                Button {
                    modalType = .rename
                } label: {
                    Image(systemName: themeRenameProfileImage)
                }
            }
        }
    }
    
    @ViewBuilder
    private func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .rename:
            NavigationView {
                RenameView(currentProfile: profileManager.currentProfile)
            }.themeGlobal()
            
        case .paywallTrustedNetworks:
            NavigationView {
                PaywallView(
                    modalType: $modalType,
                    feature: .trustedNetworks
                )
            }.themeGlobal()
        }
    }
    
    private var loadingSection: some View {
        Section(
            header: Text(Unlocalized.VPN.vpn)
        ) {
            ProgressView()
        }
    }

    private var removeProfileSection: some View {
        Section {
            Button {
                isAskingRemoveProfile = true
            } label: {
                Label(L10n.Organizer.Alerts.RemoveProfile.title, systemImage: themeDeleteImage)
            }.foregroundColor(themeErrorColor)
            .actionSheet(isPresented: $isAskingRemoveProfile) {
                ActionSheet(
                    title: Text(L10n.Organizer.Alerts.RemoveProfile.message(header.name)),
                    message: nil,
                    buttons: [
                        .destructive(Text(L10n.Organizer.Alerts.RemoveProfile.title), action: confirmRemoveProfile),
                        .cancel(Text(L10n.Global.Strings.cancel))
                    ]
                )
            }
        }
    }

    private func loadProfileIfNeeded() {
        guard !isLoaded else {
            return
        }
        guard !header.isPlaceholder else {
            pp_log.debug("ProfileView is a placeholder for WelcomeView, no active profile")
            return
        }
        do {
            let result = try profileManager.loadCurrentProfile(withId: header.id)
            if result.isReady {
                isLoaded = true
                return
            }
            Task {
                do {
                    try await profileManager.makeProfileReady(result.profile)
                    withAnimation {
                        isLoaded = true
                    }
                } catch {
                    pp_log.error("Profile \(header.id) could not be made ready: \(error)")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } catch {
            pp_log.error("Profile \(header.id) could not be loaded: \(error)")
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func confirmRemoveProfile() {
        withAnimation {
            removeProfile()
        }
    }

    private func removeProfile() {
        guard profileManager.isExistingProfile(withId: header.id) else {
            assertionFailure("Deleting non-existent profile \(header.name)")
            return
        }
        IntentDispatcher.forgetProfile(withHeader: header)
        profileManager.removeProfiles(withIds: [header.id])

        // XXX: iOS 14, NavigationLink removal via header removal in OrganizerView+Profiles doesn't pop
        if #available(iOS 15, *) {
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func presentPaywallTrustedNetworks() {
        modalType = .paywallTrustedNetworks
    }
}
