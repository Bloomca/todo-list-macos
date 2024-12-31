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
            Spacer()
            Text("Log in")
                .font(.largeTitle)
            
            TextField("Username", text: $username)
                .frame(width: 250)
                .modifier(CustomTextField())
            SecureField("Password", text: $password)
                .frame(width: 250)
                .modifier(CustomTextField())
            
            if loginError != nil {
                Text("Login failed")
                    .foregroundStyle(.red)
            }
            
            Button {
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
            } label: {
                Text("Log in")
                    .font(.headline)
                    .padding(8)
                    .frame(minWidth: 266)
                    .background(.blue.mix(with: .teal, by: 0.5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.blue.mix(with: .teal, by: 0.3))
                    )
            }
            .buttonStyle(.plain)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            
            Spacer()
            
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
