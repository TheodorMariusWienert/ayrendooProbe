//
//  ProfileView.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 24.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI


struct ProfileView: View {
    
    @ObservedObject var profileVM = ProfileViewModel()
    @State private var isPresented = false
    @State private var myEventsState = false
    @State private var savedEventsState = false
    @State var friendsViewState: Bool = false
    @State var addFriendViewState: Bool = false
    init(){
        let barAppearance = UINavigationBar.appearance()
        barAppearance.titleTextAttributes = [.foregroundColor: UIColor.primary]
        barAppearance.tintColor = UIColor.secondPrimary
        
        
    }
    
    var body: some View {
        LoadingView(isShowing: $profileVM.stillLoading)
        {
            NavigationView {
                VStack{
                    if(self.profileVM.user != nil){
                        List{
                            Profile(profileVm: self.profileVM)
                                .listRowBackground(Color.superLightGray)
                            
                            Section(header: Text("Events: ")) {
                                
                                
                                VStack{
                                    Button(action: {
                                        self.myEventsState=true
                                        
                                    })
                                    {
                                        HStack {
                                            VStack{
                                                Image("Other")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .foregroundColor(Color.secondPrimary)
                                                    .aspectRatio(UIImage(named: "Other")!.size,contentMode: .fit)
                                            }.frame(height:25)
                                                .padding(2.5)
                                            
                                            
                                            
                                            Text("My Events")
                                                .fontWeight(.semibold)
                                                
                                                
                                                .foregroundColor(.black)
                                        }.frame(maxWidth: .infinity,maxHeight: .infinity)
                                    }
                                    .buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                                    .sheet(isPresented: self.$myEventsState, content: {
                                        // TODO use eventList view as well 
                                        CreatedEventsView(isPresented: self.$myEventsState)
                                        
                                    })
                                    
                                    Button(action: {
                                        self.savedEventsState=true
                                        
                                    })
                                    {
                                        HStack {
                                            VStack{
                                                Image(systemName: "bookmark.fill")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .foregroundColor(Color.secondPrimary)
                                                    .aspectRatio(UIImage(systemName: "bookmark.fill")!.size,contentMode: .fit)
                                            }.frame(height:25)
                                                .padding(2.5)
                                            
                                            
                                            
                                            Text("Saved Events")
                                                .fontWeight(.semibold)
                                                
                                                
                                                .foregroundColor(.black)
                                        }.frame(maxWidth: .infinity,maxHeight: .infinity)
                                    }
                                    .buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                                    .sheet(isPresented: self.$savedEventsState, content: {
                                        EventList(showOnlySavedEvents: true)
                                        
                                    })
                                    
                                }
                                
                                
                            }.listRowBackground(Color.superLightGray)
                            Section(header: Text("Friends")) {
                                
                                VStack{
                                    Button(action: {
                                        addFriends()
                                        self.addFriendViewState=true
                                    }){
                                        HStack {
                                            VStack{
                                                Image(systemName: "person.crop.circle.badge.plus")
                                                    .resizable()
                                                    
                                                    .aspectRatio(UIImage(systemName: "person.crop.circle.badge.plus")!.size, contentMode: .fit)
                                                    .foregroundColor(Color.secondPrimary)
                                                
                                            }.frame(height:25)
                                                .padding(2.5)
                                            
                                            
                                            Text("Add Friend")
                                                .fontWeight(.semibold)
                                                
                                                .foregroundColor(.black)
                                        }.frame(maxWidth: .infinity,maxHeight: .infinity)
                                    }.buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                                        .sheet(isPresented: self.$addFriendViewState, content: {
                                            AddFriendView(isPresented: self.$addFriendViewState,name: self.$profileVM.username)
                                        })
                                    Button(action: {
                                        self.friendsViewState=true
                                    }){
                                        HStack {
                                            VStack{
                                                Image(systemName: "person.3.fill")
                                                    .resizable()
                                                    
                                                    .aspectRatio(UIImage(systemName: "person.3.fill")!.size,contentMode: .fit)
                                                    .foregroundColor(Color.secondPrimary)
                                            }.frame(height:25)
                                                .padding(2.5)
                                            
                                            
                                            Text("Show Friends")
                                                .fontWeight(.semibold)
                                                
                                                .foregroundColor(.black)
                                        }    .frame(maxWidth: .infinity,maxHeight: .infinity)
                                    }.buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                                        .sheet(isPresented: self.$friendsViewState, content: {
                                            FriendsView(isPresented: self.$friendsViewState)
                                        })
                                }
                                
                                
                                
                                
                                
                                
                                
                            }.listRowBackground(Color.superLightGray)
                            
                        }.listStyle(GroupedListStyle())
                            .environment(\.horizontalSizeClass, .regular)
                        
                        
                        
                    }
                }
                    
                .navigationBarTitle(Text(self.profileVM.username+", "+self.profileVM.age).foregroundColor(Color.secondPrimary), displayMode: .inline)
                    
                .navigationBarItems(trailing:Button(action: {
                    openSettings()
                    self.isPresented = true
                }) {
                    Image(systemName: "gear")
                        .imageScale(.medium)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 0))
                        .foregroundColor(Color.secondPrimary)
                }
                .sheet(isPresented: self.$isPresented){
                    SettingsPageViewControllerRepresentable()
                    }
                    
                    
                    
                )
            }
            
            
            
            
            
            
            
        }
    }
}

func openSettings(){
    print("open settings func")
    
    SettingsPageViewControllerRepresentable()
    
}
func addFriends(){
    print("Add friends func")
}
func myEvent(){
    print("My Events func")
    
}
func showFriends(){
    print("Show friends func")
}
func saveChanges(){
    print("Save Changes func")
}


struct Profile: View {
    @ObservedObject var profileVm: ProfileViewModel
    @State private var inputImage: UIImage?
    
    @State private var showEdit = false
    @State private var showingImagePicker = false
    
    
    @State private var imageChanged=false
    @State private var newImage = UIImage(named: "Questionmark")
    
    //    @State private var imageChange: Image?
    
    
    
    
    var body: some View{
        
        
        
        
        VStack(alignment: .center){
            VStack(alignment: .center) {
//                Button(action: {
//                    showFriends()
//                }){
//                    VStack{
//                        Text("4")
//                            .fontWeight(.light)
//                        Text("Friends")
//                            .fontWeight(.light)
//                            .font(Font.system(size:10, design: .default))
//                        
//                    } .frame(width: CGFloat(50),height: CGFloat(50))
//                }.buttonStyle(SimpleTextButtonStyle())
//                
//                
//                
                HStack(alignment: .center) {
                    //                    Button(action: {
                    //                        showFriends()
                    //                    }){
                    //                        VStack{
                    //
                    //                            Text("4")
                    //                                .fontWeight(.light)
                    //
                    //                            Text("Strangers met")
                    //
                    //                                .fontWeight(.light)
                    //                                .multilineTextAlignment(.center)
                    //                                .font(Font.system(size:10, design: .default))
                    //
                    //                        }.frame(width: CGFloat(60),height: CGFloat(60))
                    //
                    //                    }.buttonStyle(SimpleTextButtonStyle())
                    
                    
                    
                    if(imageChanged){
                        Image(uiImage: newImage!)
                            .renderingMode(.original)
                            .resizable()
                            .clipped()
                            .clipShape(Circle())
                            .frame(width: CGFloat(200),height: CGFloat(200))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                            .onTapGesture {
                                self.showingImagePicker = true
                        }
                    }
                    else{
                        WebImage(url: profileVm.urlProfilePic)
                            .renderingMode(.original)
                            .resizable()
                            .placeholder {
                                Image("Other")
                            }
                            .clipped()
                            .clipShape(Circle())
                    
                            .frame(width: CGFloat(200),height: CGFloat(200))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                            .onTapGesture {
                                self.showingImagePicker = true
                        }
                   
                        
                    }
                    
                    
                    //
                    //                    Button(action: {
                    //                        showFriends()
                    //                    }){
                    //                        VStack{
                    //                            Text("4")
                    //                                .fontWeight(.light)
                    //
                    //
                    //                            Text("Attended Events")
                    //                                .font(Font.system(size:10, design: .default))
                    //                                .fontWeight(.light)
                    //                                .multilineTextAlignment(.center)
                    //
                    //                        }
                    //                            .frame(width: CGFloat(60),height: CGFloat(60))
                    //
                    //                    }.buttonStyle(SimpleTextButtonStyle())
                    
                    
                    
                } .frame(maxWidth: .infinity)
            }
            //            VStack{
            //
            //                VStack(alignment: .center){
            //                    if self.showEdit {
            //                        TextField("Name", text: $username).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.leading, 5).font(.system(size: 20))
            //                            .autocapitalization(.words)
            //                            .disableAutocorrection(true)
            //                        TextField("Age", text: $age).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.leading, 5).font(.system(size: 20))
            //                            .autocapitalization(.words)
            //                            .disableAutocorrection(true)
            //                    } else {
            //                        Text(username).font(.title)
            //                        Text(age).font(.title)
            //                    }
            //
            //
            //
            //                }.frame(alignment: .center)
            //
            //
            //                if (!self.showEdit) { Button(action: {
            //                    self.showEdit=true
            //                }){
            //
            //                    Image(systemName: "pencil.circle.fill")
            //                        .resizable()
            //                        .frame(width: 20, height: 20)
            //
            //
            //                }.padding(.top, 5)
            //
            //                }
            //                else{
            //                    HStack{
            //
            //                        Button(action: {
            //                            self.showEdit=false
            //                            self.username=self.user.username
            //                            self.age=self.user.age
            //
            //                        }){
            //
            //                            Text("Exit")
            //                                .foregroundColor(Color.white)
            //                                .frame(maxWidth: .infinity,maxHeight: .infinity)
            //
            //
            //                        }
            //                        .buttonStyle(SimpleButtonStyle(color: Color.lightBlue))
            //
            //                        Button(action: {
            //                            self.showEdit=false
            //                            saveChanges()
            //                        }){
            //
            //                            Text("Save")
            //                                .foregroundColor(Color.white)
            //                                .frame(maxWidth: .infinity,maxHeight: .infinity)
            //
            //                        }
            //                        .buttonStyle(SimpleButtonStyle(color: Color.lightBlue))
            //                    } .padding(.top, 5)
            //
            //                }
            //
            //
            //
            //            }  .frame(maxWidth: .infinity)
            //
            
            
        }
        .padding()
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
            
            
            
        }
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        imageChanged = true
        newImage = inputImage
        profileVm.profileRepo.uploadProfilePicture(profilePicture: newImage!)
    }
    
}





struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.navigationItem.backBarButtonItem?.tintColor=UIColor.red
        //        picker.navigationBarBackButtonHidden(true)
        //        picker.navigationBarItems(leading: Button(action : {
        //            self.showingImagePicker=false
        //        }){
        //            Image(systemName: "arrow.left")
        //                .foregroundColor(Color.white)
        //        })
        //
        
        picker.delegate = context.coordinator
        return picker
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
        
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
            
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}





