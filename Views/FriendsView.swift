//
//  FriendsView.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 09.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendsView: View {
    @Binding var isPresented:Bool
    @ObservedObject var friendsVM = FriendsViewModel()
    
    @State private var query=""
    
    var body: some View {
   
        
        NavigationView{
            VStack{
              SearchBar(query: self.$query, placeholder: "Search Friends")
            
            
                List(self.friendsVM.users.filter { user in
                   if(!self.query.isEmpty){
                                      if(user.username.lowercased().contains(self.query.lowercased()) )
                                  {
                                     return true
                                  }
                                  }
                                  else{
                                      return true
                                  }
                    return false
                }, id: \.uid) { user in
                    UserInTable(user: user)

                }
            }
                
                .navigationBarTitle(Text("Friends"), displayMode: .inline)
                
                .navigationBarItems(leading: Button(action: {
                    print("leading Button")
                    self.isPresented=false
                    
                }) {
                    Image(systemName: "chevron.down")
                        .imageScale(.medium)
                       .foregroundColor(Color.secondPrimary)
                    }
                    , trailing:Button(action: {
                        self.makeBigUserArry()


                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.medium)
                         .foregroundColor(Color.secondPrimary)
                    }
                    
                    
                    
            )
                
        }
    }
    func makeBigUserArry() {
       for i in 0..<2001 { i
        let user=User(name: String(i))
        self.friendsVM.users.append(user)
        }
       
    }
    
}
struct UserInTable: View {
    var user: User
    
    
    
    var body: some View {
        
        
        
        
        HStack{
            
            WebImage(url: URL(string: user.profilePictureURL))
                // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
                
                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                
                .placeholder {
                    Rectangle().foregroundColor(.gray)
            }
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5))
                .clipShape(Circle())
                .frame(width: CGFloat(60),height: CGFloat(60))
                .clipped()
            
            
                Text(user.username)
            
    
            
        }

    }
}

struct FriendsView_Previews: PreviewProvider {
    @State static var value = false
    static var previews: some View {
        FriendsView(isPresented: $value)
    }
}
