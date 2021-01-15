//
//  CreatedEventsRepository.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 09.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//
import Foundation
import Firebase

class CreatedEventsRepository {
    
    
    private var currentUserId=""
    
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()
    private var eventReference: CollectionReference {
        return db.collection(kEVENTS)
    }

    init(){
        
        guard let currentUserId = Auth.auth().currentUser?.uid else{
            print("Couldn't get user")
            return
        }
        self.currentUserId = currentUserId
    }
    
    func loadEvents( completion: @escaping ([Event])->Void){
        self.eventReference.whereField(kCREATOR, isEqualTo: currentUserId).getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print("Unexpected error: \(error)")
            }
            else{
                var events: [Event] = []
                snapshot?.documents.forEach({ (document) in
                    let event = Event(document: document)
                    print("Load event", event as Any)
                    events.append(event!)
                })
                completion(events)
            }
        })
        }
}

