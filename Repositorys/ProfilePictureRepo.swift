//
//  ProfilePictureRepo.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 19.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation
import Firebase
class ProfilePictureRepo: ObservableObject {
    private let storageRef = Storage.storage().reference()

    func  loadProfilePic(users: [User], completion: @escaping ([String: UIImage])->Void){
//        var user = user
        var task : StorageDownloadTask!
        
        var loadedProfilePictures = 0
        var images: [String: UIImage] = [:]
        for user in users {
            print("for users in users")
            let profilePicRef = storageRef.child([user.uid, "profilePicture_200x200.jpg"].joined(separator: "/"))
                    profilePicRef.downloadURL { url, error in
                        if let error = error {
                            // Handle any errors
                            print("error \(error)")
                        } else {
                            print("URL: ", url)
                            // Get the download URL for 'images/stars.jpg'
                        }
                    }
                    profilePicRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        
//                        task.removeAllObservers()
                        
                        if let error = error {
                            print("Unexpected Error: \(error)")
                            images[user.uid] = (UIImage(named: "Questionmark")!)
                            return
                        }
                        else {
                            let image = UIImage(data: data!)
            //                  user.profilePicture = image
                            images[user.uid] = image!
                            loadedProfilePictures += 1
                            print("usersCount: ", users.count, " ", loadedProfilePictures)
                            if loadedProfilePictures == users.count {
                                print("completion")
                                completion(images)
                            }
                          }
                        print("fefoaofae")
                    }
        }
        
//        task.observe(StorageTaskStatus.progress, handler: {
//            snapshot in
//            print("snapshot")
//
//
//        })
        print("lol")
//        let profilePicRef = storageRef.child([user.uid, "profilePicture_200x200.jpg"].joined(separator: "/"))
//          profilePicRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//              print("Unexpected Error: \(error)"); return
//            completion(user)
//            } else {
//              let image = UIImage(data: data!)
//                user.profilePicture = image
//                completion(user)
//
//            }
//          }
        
    }
  

}
