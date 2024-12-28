//
//  LoginView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct LoginView: View {    
    @EnvironmentObject var router: Router
    @EnvironmentObject var authStore: AuthStore
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoading: Bool = false
    @State private var loginError: Error?
    
    var body: some View {
        VStack {
            Text("Log in to your account")
                .font(.largeTitle)
            
            TextField("Username", text: $username)
                .frame(width: 200)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .frame(width: 200)
                .textFieldStyle(.roundedBorder)
            
            if loginError != nil {
                Text("Login failed")
                    .foregroundStyle(.red)
            }
            
            Button("Log in") {
                Task {
                    do {
                        loginError = nil
                        isLoading = true
                        let token = try await authNetworkService.login(
                            username: username,
                            password: password)
                        isLoading = false
                        // Store the token or handle successful login
                        print(token)
                        authStore.setToken(token)
                        router.navigate(to: .app)
                    } catch {
                        isLoading = false
                        loginError = error
                        // Handle error
                        print("Login failed: \(error)")
                    }
                }
            }
            .font(.headline)
            .disabled(isLoading)
            
            HStack {
                Text("Not registered yet?")
                    .foregroundColor(.secondary)
                Button("Register") {
                    router.navigate(to: .signup)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .underline(true)
            }
            
                
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
