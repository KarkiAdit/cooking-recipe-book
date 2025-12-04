//
//  AddReceipeView.swift
//  CookBook
//
//

import SwiftUI
import PhotosUI

/*
 
 An image is binary data
 
 Upload an image to Google Cloud Storage => Reference
 To save the receipe into Firestore Database
 */

struct AddReceipeView: View {
    
    @State var viewModel = AddReceipeViewModel()
    @StateObject var imageLoaderViewModel = ImageLoaderViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("What's New")
                        .font(.system(size: 26, weight: .bold))
                        .padding(.top, 20)
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryFormEntry)
                            .frame(height: 200)
                        Image(systemName: "photo.fill")
                    }
                    if let displayedReceipeImage = viewModel.displayedReceipeImage {
                        
                        displayedReceipeImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .clipped()
                    }
                }
                .onTapGesture {
                    viewModel.showImageOptions = true
                }
                Text("Receipe Name")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.top)
                TextField("", text: $viewModel.receipeName)
                    .textFieldStyle(CapsuleTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Text("Preparation Time")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.top)
                Picker(selection: $viewModel.preparationTime) {
                    ForEach(0...120, id: \.self) { time in
                        if time % 5 == 0 {
                            Text("\(time) mins")
                                .font(.system(size: 15))
                                .tag(time)
                        }
                    }
                } label: {
                    Text("Prep Time")
                }
                Text("Cooking Instructions")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.top)
                TextEditor(text: $viewModel.instructions)
                    .frame(height: 150)
                    .background(Color.primaryFormEntry)
                    .scrollContentBackground(.hidden)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button(action: {
                    Task {
                        if let imageURL = await viewModel.upload() {
                            viewModel.addReceipe(imageURL: imageURL) { success in
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    }
                }, label: {
                    Text("Add Receipe")
                })
                .buttonStyle(PrimaryButtonStyle())
                Spacer()
            }
            .padding(.horizontal)
            .photosPicker(isPresented: $viewModel.showLibrary, selection: $imageLoaderViewModel.imageSelection, matching: .images, photoLibrary: .shared())
            .onChange(of: imageLoaderViewModel.imageToUpload, { _, newValue in
                if let newValue = newValue {
                    viewModel.displayedReceipeImage = Image(uiImage: newValue)
                    viewModel.receipeImage = newValue
                }
            })
            .confirmationDialog("Upload an image to your receipe", isPresented: $viewModel.showImageOptions, titleVisibility: .visible) {
                Button(action: {
                    viewModel.showLibrary = true
                }, label: {
                    Text("Upload from Library")
                })
                Button(action: {
                    viewModel.showCamera = true
                }, label: {
                    Text("Upload from Camera")
                })
            }
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraPicker { image in
                    viewModel.displayedReceipeImage = Image(uiImage: image)
                    viewModel.receipeImage = image
                }
            }
            if viewModel.isUploading {
                ProgressComponentView(value: $viewModel.uploadProgress)
            }
            if viewModel.isLoading {
                LoadingComponentView()
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button(action: {
                
            }, label: {
                Text("OK")
            })
        } message: {
            Text(viewModel.alertMessage)
        }

    }
}

#Preview {
    AddReceipeView()
}
