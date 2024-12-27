//
//  SignupView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct SignupView: View {    
    @EnvironmentObject var router: Router
    @EnvironmentObject var authStore: AuthStore
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoading: Bool = false
    @State private var loginError: Error?
    
    var body: some View {
        VStack {
            Text("Signup")
                .font(.largeTitle)
            
            TextField("Username", text: $username)
                .frame(width: 200)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .frame(width: 200)
                .textFieldStyle(.roundedBorder)
            
            if loginError != nil {
                Text("Signup failed")
                    .foregroundStyle(.red)
            }
            
            Button("Signup") {
                Task {
                    do {
                        loginError = nil
                        isLoading = true
                        let token = try await authNetworkService.signup(
                            username: username, password: password)
                        isLoading = false
                        // Store the token or handle successful singup
                        print(token)
                        authStore.setToken(token)
                        router.navigate(to: .app)
                    } catch {
                        isLoading = false
                        loginError = error
                        // Handle error
                        print("Signup failed: \(error)")
                    }
                }
            }
            .font(.headline)
            .disabled(isLoading)
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                Button("Login") {
                    router.navigate(to: .login)
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
    SignupView()
}
