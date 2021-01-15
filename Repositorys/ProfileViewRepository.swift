//
//  ProfileViewRepository.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 02.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation
import Firebase

import UIKit

class ProfileViewRepository {
    
    
    private var currentUserId=""
    
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    private var userReference: CollectionReference {
        return db.collection(kUSERS)
    }

    init(){
        
        guard let currentUserId = Auth.auth().currentUser?.uid else{
            print("Couldn't get user")
            return
        }
        self.currentUserId = currentUserId
    }
    
    func loadUser( completion: @escaping (User)->Void){
            self.userReference.document(currentUserId).getDocument { (document, error) in
                if let error = error {
                    print("Unexpected error: \(error)")
                }
                else{
                    let user = User(document: document!)
                    print("Load User", user)
                    completion(user!)
                    
                }
            }
        }
    func uploadProfilePicture(profilePicture: UIImage){
        let image = profilePicture.jpegData(compressionQuality: 0.5)
               
         
               let metadata = StorageMetadata()
               metadata.contentType = "image/jpeg"
               let profilePicRef = storageRef.child([currentUserId, kPROFILEPICTURE].joined(separator: "/"))
               profilePicRef.putData(image!, metadata: metadata) { (metadata, error) in
                   guard metadata != nil else {
                       return
                 }
                
              
        }
    }
 
    func getUrlFromRef(completion: @escaping (URL)->Void) {
        print("GET PP URL ")
        let profilePicRef = storageRef.child([currentUserId, kPROFILEPICTURE_400X400].joined(separator: "/"))
       
        profilePicRef.downloadURL { url, error in
          if let error = error {
            print("NO url found for this reference of profile pic, error:",error)
            return
          } else {
            completion(url!)
          }
        }
       
    }
}
