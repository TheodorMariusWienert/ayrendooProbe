//
//  EvenetProfileViewModel.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 18.07.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation

import SwiftUI
import Firebase
import MapKit

class EventProfileViewModel: ObservableObject,Identifiable{
    
    var  eventRepo = EventProfileRepository()
    var event: Event?
    var eventID: String?
    @Published var stillLoading = true
   @Published var users=[User]()
    @Published var eventName=""
    @Published var eventIsSaved = false
    @Published var bookmark = "bookmark"
    var view: EventProfileView?
//    var coordinates: CLLocationCoordinate2D?
   
    @Published var buttonStateName = "Wait"
    
    init(eventID: String){//event: Event as Paramater
       print("EventVM Init")
            self.eventID = eventID
       print("eventID: \(eventID)")
        self.eventRepo.loadData(eventID: eventID) {users in
            
           
           
            self.event=self.eventRepo.event
            self.eventName=self.eventRepo.event.eventName
        
            self.users = users
               self.stillLoading = false
                self.updateButtonState()
            self.isEventSaved(eventID)
            
            }
       
    }
    func pressButton(){
            var state=false
            for user in users {
                if(user.uid == eventRepo.user.uid){
                   state=true
               
                }
            }
            if(state){
                 print("leave eve")
                self.event!.joinedUsersCount -= 1
                buttonStateName="Wait"
                users.remove(at: 0)
                print("users",users)
                eventRepo.leaveEvent() {
                    self.updateButtonState()
                }
                
                
            }
            else{
                if(self.event!.joinedUsersCount == Int(self.event!.numberOfParticipants)){
                 return
                }else{
                    print("join event")
                                  buttonStateName="Wait"
                                  self.event!.joinedUsersCount += 1
                                users.insert(self.eventRepo.user, at: 0)
                                  print("users",users)
                                  eventRepo.joinEvent(){
                                      self.updateButtonState()
                                  }
                    
                }
              
               
                
            }
   
   
    }
    
    func editEvent() -> AddEventTableViewControllerRepresentable {
        let editEventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddEventView") as! AddEventTableViewController
        let coordinates = CLLocationCoordinate2D(latitude: event!.latitude, longitude: event!.longitude)
        editEventVC.createdFromCoordinates = coordinates

        editEventVC.editEvent = true
        editEventVC.eventProfileVM = self
        
        editEventVC.eventName = event?.eventName
        editEventVC.eventType = event?.eventType
        editEventVC.numberOfParticipants = event?.numberOfParticipants
        editEventVC.requirements = event?.requirements
        editEventVC.eventDescription = event?.eventDescription
        editEventVC.time = event!.date
        
        return AddEventTableViewControllerRepresentable(editEventVC)
    }
    
    func deleteEvent() {
        if(eventRepo.user.uid == event!.creator) {
            eventRepo.delete()
            if view!.dismiss != nil {
                view!.dismiss!()
            }
            else {
                view!.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func updateButtonState(){
        
         if(eventRepo.user.uid == self.event!.creator){
            buttonStateName="Edit"
            return
        }
        var state=false
        for user in users {
            if(user.uid == eventRepo.user.uid){
               state=true
           
            }
        }
        if(state){
            
            buttonStateName="Leave"
            
            
        }
        else{
            if(self.event!.joinedUsersCount == Int(self.event!.numberOfParticipants)){
                buttonStateName=""
            }
            else{
                 buttonStateName="Join"
            }
           
            
        }
     
        
        
    }
    
    
    func isEventSaved(_ eventID: String) {
        firestore.collection(kUSERS).document(Auth.auth().currentUser!.uid).collection(kSAVEDEVENTS).document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Unexpected error: \(error)")
                return
            }
            if let document = document, document.exists {
                self.eventIsSaved = true
                self.bookmark = "bookmark.fill"
            }
        }
    }
}

struct EventProfileViewModel_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
