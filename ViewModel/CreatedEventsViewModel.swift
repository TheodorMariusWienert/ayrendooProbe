//
//  CreatedEventsViewModel.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 09.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation

class CreatedEventsViewModel: ObservableObject,Identifiable{
    var  eventsRepo = CreatedEventsRepository()
    @Published var stillLoading = true
    @Published var user: User?
     @Published var username=""
     @Published var age=""
    @Published var events: [Event]?
    
    init(){//event: Event as Paramater
        
        print("ProfileViewModel")
        self.eventsRepo.loadEvents(completion: { (events) in
            print("events: ", events)
            for event in events {
                print(event)
            }
            self.events  = events.sorted {
                $0.date < $1.date
            }
              
          
            
            self.stillLoading = false
        })
    }
}
