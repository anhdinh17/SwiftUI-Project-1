//
//  ProfileView.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/26/23.
//

import SwiftUI
import FirebaseAuth

enum PhotoSource: Identifiable {
    case photoLibrary
    case camera

    var id: Int {
        hashValue
    }
}

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var showPhotoOptions = false
    @State private var photoSource: PhotoSource?
    // The reason why we store the image as an UIImage object is that the image returned from the photo library also has a type of UIImage.
    @State private var userImage = UIImage(systemName: "person.circle")!
    
    var body: some View {
        NavigationStack {
            VStack {
                // Check if user is signed in
                //            if viewModel.isSignedIn {
                Image(uiImage: userImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .onTapGesture {
                        self.showPhotoOptions.toggle()
                    }
                
                VStack(alignment: .leading) {
                    HStack{
                        Text("Name: ")
                            .bold()
                        Text(viewModel.getUserName())
                    }
                    .padding()
                    
                    HStack{
                        Text("Email: ")
                            .bold()
                        Text(viewModel.getUserEmail())
                    }
                    .padding()
    //
    //                HStack{
    //                    Text("Member since: ")
    //                        .bold()
    //                }
    //                .padding()
                }
                .padding()

                // Test Button to upload image to Storage
                StandardButton(title: "Upload Image",
                               backgroundColor: .pink) {
                    // Upload Image
                    viewModel.uploadImage(selectedImage: self.userImage)
                }
                
                Spacer()
                
                StandardButton(title: "Sign Out",
                               backgroundColor: .red) {
                    viewModel.signOut()
                }
                //            } else {
                //                Text("Please make sure you have signed in.")
                //            }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            // Fetch Image
            // Moi lan dau vo screen nay thi xai userImage cua screen nay
            // Neu upload xong va khi quay lai screen nay thi xai viewModel.userImage
            viewModel.downloadImage {
                if let image = viewModel.userImage {
                    DispatchQueue.main.async {
                        // set userImage = viewModel.userImage
                        self.userImage = image
                    }
                }
            }
        }
        .actionSheet(isPresented: $showPhotoOptions) {
            ActionSheet(title: Text("Choose your photo source"),
                        message: nil,
                        buttons: [
                            .default(Text("Camera")) {
                                self.photoSource = .camera
                            },
                            .default(Text("Photo Library")) {
                                self.photoSource = .photoLibrary
                            },
                            .cancel()
                        ])
        }
        /*
         - Thằng này observe "photoSource"
         - Khi mới vô, photoSource là nil.
         - Click on image -> actionSheet -> chọn 1 option -> photoSource sẽ thay đổi giá trị từ nil sang photoLibrary/camera -> .fullScreenCover triggered
         */
        .fullScreenCover(item: $photoSource) { source in
            switch source {
            case .photoLibrary: ImagePicker(sourceType: .photoLibrary, selectedImage: $userImage).ignoresSafeArea()
            case .camera: ImagePicker(sourceType: .camera, selectedImage: $userImage).ignoresSafeArea()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
