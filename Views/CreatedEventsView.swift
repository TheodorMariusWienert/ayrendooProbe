//
//  CreatedEventsView.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 09.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI

import UIKit
import MapKit
import SDWebImageSwiftUI
import Firebase

struct CreatedEventsView: View {
    @Binding var isPresented:Bool
    @ObservedObject var createdEventsVM = CreatedEventsViewModel()
    @State var evenState = false
    init(isPresented: Binding<Bool>){
         UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.primary]
        self._isPresented = isPresented
    }
    
    
    
    
    var body: some View {
        LoadingView(isShowing: $createdEventsVM.stillLoading) {
            NavigationView {
                VStack{
                    
                    if(self.createdEventsVM.events != nil){
                        
                        List(self.createdEventsVM.events!, id: \.id) { event in
                            Button(action: {
                                self.evenState=true
                            }, label: {
                                HStack{
                                    Image(event.eventType)
                                        .renderingMode(.original)
                                        .resizable()
                                        .frame(width:40,height:40)
                                        .aspectRatio(contentMode: .fit)
                                    VStack(alignment: .leading) {
                                        Text(event.eventName)
                                        Text("on: "+formatDate(time: event.date))
                                            .font(Font.system(size:10, design: .default))
                                    }
                                }
                                
                            })
                                
                                .sheet(isPresented: self.$evenState, content: {
                                    EventProfileView(eventProfileVM: EventProfileViewModel(eventID: event.id!))
                                   
                                    
                                })
                            
                            
                            
                        }
                        
                    }
                }
                .navigationBarTitle(Text("My Events"), displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    self.isPresented=false
                    
                }) {
                    Image(systemName: "chevron.down")
                        .imageScale(.medium)
                           .foregroundColor(Color.secondPrimary)
                        
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                })
            }
        }
    }
}


struct CreatedEventsView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
