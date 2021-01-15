//
//  EventProfileRepository.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 18.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation
import Firebase
class EventProfileRepository: ObservableObject{
    
    @Published var event: Event!
    var eventID: String
    var user: User!
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    private var eventReference: CollectionReference {
        return db.collection(kEVENTS)
    }
    init(){
        eventID=""
        guard let currentUser = Auth.auth().currentUser else{
            print("Couldn't get user")
            return
        }
        user = User(authData: currentUser)
        
    }
    
    
    func loadFriendsCount(){
        
    }
    func loadData(eventID: String, completion: @escaping ([User])->Void){
        let eventDocRef = eventReference.document(eventID)
        eventDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.self.event = Event(document: document)
                self.self.eventID=self.self.event.id!
                print("eventId: ", self.self.eventID)
                self.db.collection(kEVENTS).document(eventID).collection(kJOINEDUSERS).getDocuments { (snapshots, error) in
                    if let error = error {
                        print("Unexpected error: \(error)")
                    }
                    else {
                        var users: [User] = []
                        let documentCount = snapshots?.documents.count
                        var loadedUsers = 0
                        snapshots?.documents.forEach({ (snapshot) in
                            let uid = snapshot.documentID
                            print("uid: ", uid)
                            self.loadUsers(uid: uid) { (user) in
                                if(user.uid == self.user.uid){
                                    users.insert(user, at: 0)
                            }
                            else{
                                users.append(user)
                            }
                            
                            loadedUsers += 1
                            if loadedUsers == documentCount {
                                completion(users)
                            }
                        }
                    })
                    
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}
func loadUsers(uid: String, completion: @escaping (User) -> Void)
{
    self.db.collection(kUSERS).document(uid).getDocument { (document, error) in
        if let error = error {
            print("Unexpected error: \(error)")
        }
        if let document = document, document.exists {
            
            //if uid != Auth.auth().currentUser?.uid {
            let user = User(document: document)
            
            completion(user!)
            // }
            
        }
    }
}
//loadData(evenID: localEventID)
func delete(){
    print("Delete Event")
    self.db.collection(kEVENTS).document(self.eventID).delete() { err in
        if let err = err {
            print("Error setting document: \(err)")
        }
        else {
            let sender = PushNotificationSender()
            
            let joinedUsersRef = self.db.collection([kEVENTS, self.eventID, kJOINEDUSERS].joined(separator: "/"))
            joinedUsersRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        
                        let token = data[kFCMTOKEN] as! String
                        
                        sender.sendPushNotification(to: token, title: self.event.eventName, body: [self.event.creator," deleted the event"].joined())
                        
                        self.db.collection([kUSERS, document.documentID, kCHANNELS].joined(separator: "/")).document(self.eventID).delete()
                        
                    }
                }
            }
        }
    }
}


func leaveEvent(completion: @escaping () -> Void) {
    self.event.joinedUsersCount -= 1
    print("LEave evenet")
    db.collection([kEVENTS, eventID, kJOINEDUSERS].joined(separator: "/")).document(self.user.uid).delete() { err in
        if let err = err {
            print("Error setting document: \(err)")
        }
        else {
            
            let sender = PushNotificationSender()
            
            let joinedUsersRef = self.db.collection([kEVENTS, self.eventID, kJOINEDUSERS].joined(separator: "/"))
            joinedUsersRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let token = data[kFCMTOKEN] as! String
                        print(token)
                        sender.sendPushNotification(to: token, title: self.event.eventName, body: [self.user.username," left"].joined())
                        
                        
                    }
                }
            }
            self.db.collection([kUSERS, self.user.uid, kCHANNELS].joined(separator: "/")).document(self.eventID).delete() {
                err in
                if let err = err {
                    print("Error deleting document: \(err)")
                }
                else {
                    print("Document successfully deleted")
                    self.db.collection(kEVENTS).document(self.eventID).updateData([kJOINEDUSERSCOUNT: FieldValue.increment(Int64(-1))]) { (error) in
                        if let error = error {
                            print("Unexpected error: \(error)"); return
                        }
                        else{
                            completion()
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
}
func joinEvent(completion: @escaping () -> Void){
    print("JOin event function")
    db.collection([kEVENTS, eventID, kJOINEDUSERS].joined(separator: "/")).document(self.user.uid).setData(user.representation, merge: true)
    db.collection(kUSERS).document(user.uid).getDocument { (document, error) in
        if let document = document, document.exists {
            let token = document.data()![kFCMTOKEN] as! String
            self.db.collection([kEVENTS, self.eventID, kJOINEDUSERS].joined(separator: "/")).document(self.self.user.uid).setData([kFCMTOKEN: token], merge: true)
            { err in
                if let err = err {
                    print("Error setting document: \(err)")
                }
                else {
                    completion()//returns the button stat
                    let sender = PushNotificationSender()
                    
                    let joinedUsersRef = self.db.collection([kEVENTS, self.eventID, kJOINEDUSERS].joined(separator: "/"))
                    joinedUsersRef.getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let data = document.data()
                                let token = data[kFCMTOKEN] as! String
                                print(token)
                                //self.setReminder()
                                sender.sendPushNotification(to: token, title: self.event.eventName, body: [self.user.username," joined"].joined())
                            }
                        }
                    }
                }
            }
        }
    }
    db.collection([kUSERS, user.uid, kCHANNELS].joined(separator: "/")).document(eventID).setData(["eventID": eventID as Any, "isCreator": false])
    
    // TODO transition into chat
    
    self.db.collection(kEVENTS).document(self.eventID).updateData([kJOINEDUSERSCOUNT: FieldValue.increment(Int64(1))]) { (error) in
        if let error = error {
            print("Unexpected error: \(error)"); return
        }
    }
}
}


