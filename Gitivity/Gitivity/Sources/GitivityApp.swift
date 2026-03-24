//
//  GitivityApp.swift
//  Gitivity
//
//  Created by Muchan Kim on 3/24/26.
//

import SwiftUI

@main
struct GitivityApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}
