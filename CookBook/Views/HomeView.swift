//
//  HomeView.swift
//  CookBook
//

import SwiftUI

struct HomeView: View {
    
    @State var viewModel = HomeViewModel()
    @Environment(SessionManager.self) var sessionManager: SessionManager
    
    fileprivate func ReceipeRow(receipe: Receipe) -> some View {
        VStack(alignment: .leading) {
            
            AsyncImage(url: URL(string: receipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemWidth, height: itemHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
            } placeholder: {
                VStack {
                    ProgressView()
                }
                .frame(width: itemWidth, height: itemHeight)
            }
            Text(receipe.name)
                .lineLimit(1)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    let spacing: CGFloat = 10
    let padding: CGFloat = 10
    
    var itemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - (spacing * 2) - (padding * 2)) / 3
    }
    
    var itemHeight: CGFloat {
        return CGFloat(1.5) * itemWidth
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.receipes) { receipe in
                            NavigationLink {
                                ReceipeDetailView(receipe: receipe)
                            } label: {
                                ReceipeRow(receipe: receipe)
                            }
                        }
                    }
                    .padding(padding)
                }
                Spacer()
                Button(action: {
                    viewModel.showAddReceipeView = true
                }, label: {
                    Text("Add Receipe")
                })
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.showSignOutAlert = true
                    }, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.black)
                    })
                }
            })
            .alert("Are you sure you would like to sign out?", isPresented: $viewModel.showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    if viewModel.signOut() {
                        sessionManager.sessionState = .loggedOut
                    }
                }
                Button("Cancel", role: .cancel) {
                    
                }
            }
        }
        .task {
            await viewModel.fetchReceipes()
        }
        .sheet(isPresented: $viewModel.showAddReceipeView, onDismiss: {
            Task {
                await viewModel.fetchReceipes()
            }
        }) {
            AddReceipeView()
        }

    }
    
}

#Preview {
    HomeView()
        .environment(SessionManager())
}


