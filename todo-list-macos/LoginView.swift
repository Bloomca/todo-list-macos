//
//  LoginView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct LoginView: View {
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
                    let service = FetchService()
                    do {
                        loginError = nil
                        isLoading = true
                        let token = try await service.login(username: "user", password: "pass")
                        isLoading = false
                        // Store the token or handle successful login
                        print(token)
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
                
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
