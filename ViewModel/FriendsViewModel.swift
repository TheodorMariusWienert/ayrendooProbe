//
//  FriendsViewModel.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 26.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase

class FriendsViewModel: ObservableObject,Identifiable{
    
 
    
   @Published var users=[User]()
    let friednsRepo = FriendsViewRepository()
   
  
    
    init(){//event: Event as Paramater
       
           
      
        self.friednsRepo.loadFriends() {user in
            
            self.users.append(user)
        
            
            }
       
    }
   
    
    
}

