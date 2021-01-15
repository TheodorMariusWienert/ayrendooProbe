//
//  ProfileViewModel.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 02.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//
import FirebaseAuth
import Foundation
class ProfileViewModel: ObservableObject,Identifiable{
    var  profileRepo = ProfileViewRepository()
    @Published var stillLoading = true
    @Published var user: User?
     @Published var username=""
     @Published var age=""
    @Published var urlProfilePic = URL(string: "")
      @Published var freindsCount: Int?
     private var handle: AuthStateDidChangeListenerHandle?
    
    init(){//event: Event as Paramater
        
      handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            

        if let user = user {
        
        print("ProfileViewModel")
        self.profileRepo.loadUser() { user in
            print("User foun", user)
            self.user = user
            self.username=user.username
            self.age=user.age
            self.stillLoading = false
           
        }
        self.profileRepo.getUrlFromRef(){url in
                   self.urlProfilePic=url
                   print("URL PP: ", self.urlProfilePic)
               }
    
            }
                      else {
                                 print("No logged in user")
                             }
                   }
}
  deinit {
        if let listener = handle {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
}
