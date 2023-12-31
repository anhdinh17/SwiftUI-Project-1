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
    @State var isSaveButtonDisabled: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                // Check if user is signed in
                //            if viewModel.isSignedIn {
                VStack(spacing: -10) {
                    Image(uiImage: userImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: -30) {
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
                    }
                    .padding()
                    
                    // Click here to select how users want to choose new photo
                    StandardButton(title: "Update Image",
                                   backgroundColor: .blue) {
                        self.showPhotoOptions.toggle()
                    }
                                   .padding(.top, -20)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Upload image to Firebase Storage
                        viewModel.uploadImage(selectedImage: self.userImage)
                        self.isSaveButtonDisabled = true
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                    .disabled(isSaveButtonDisabled)
                }
            }
        }
        .onAppear {
            // Fetch Image
            // Moi lan dau vo screen nay thi xai userImage w/ person.circle cua screen nay
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
                            // photoSource chuyển từ nil sang giá trị khác
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
         - Click on update image -> actionSheet -> chọn 1 option -> photoSource sẽ thay đổi giá trị từ nil sang photoLibrary/camera -> .fullScreenCover triggered
         - Sau khi chọn hình mới xong thì userImage sẽ có hình mới (vì bind với selectedImage trong ImagePicker) -> hiện hình mới chọn.
         */
        .fullScreenCover(item: $photoSource) { source in
            switch source {
            case .photoLibrary:
                ImagePicker(sourceType: .photoLibrary, selectedImage: $userImage, isSaveButtonDisabled: $isSaveButtonDisabled).ignoresSafeArea()
            case .camera:
                ImagePicker(sourceType: .camera, selectedImage: $userImage, isSaveButtonDisabled: $isSaveButtonDisabled).ignoresSafeArea()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
