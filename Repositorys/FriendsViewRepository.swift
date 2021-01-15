//
//  FriendsViewRepository.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 26.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//
import Foundation
import Firebase
class FriendsViewRepository: ObservableObject{
    
    
    
    
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    private var userReference: CollectionReference {
        return db.collection(kUSERS)
    }
    init(){
        
        
    }
    
    
    
    func loadFriends( completion: @escaping (User)->Void){
        guard let currentUser = Auth.auth().currentUser else{
            print("Couldn't get user")
            return
        }
        let userDocRef = userReference.document(currentUser.uid)
        
        userDocRef.collection("friends").getDocuments { (snapshots, error) in
            if let error = error {
                print("Unexpected error: \(error)")
            }
            else {
                
                snapshots?.documents.forEach({ (snapshot) in
                    let uid = snapshot.documentID
                    self.loadUsers(uid: uid) { (user) in
                        
                        completion(user)
                    }
                })
            }
            
            
        }
    }
    
    
    func loadUsers(uid: String, completion: @escaping (User) -> Void)
    {
        self.db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Unexpected error: \(error)")
            }
            else{
                
                //if uid != Auth.auth().currentUser?.uid {
                let user = User(document: document!)
                
                completion(user!)
                // }
                
            }
        }
    }
}
