//
//  EventList.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 25.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
    
struct EventList: View {
     @State var eventProfileVM: EventProfileViewModel?
    @ObservedObject var eventListVM: EventListViewModel
//        var events = [Event]()
    var locationPreview: LocationPreview
       
    // TODO: make it an enum [allEvents, savedEvents, createdEvents]
    var showOnlySavedEvents: Bool
        
    init(showOnlySavedEvents: Bool, isTabBar: Bool = false){
            print("eventListView init")
            self.showOnlySavedEvents = showOnlySavedEvents
            self.eventListVM =  EventListViewModel(isTabBar: isTabBar)
        self.locationPreview = LocationPreview()
            
        }
        
    var events = [Event]()
    
    @State var evenState = false
    @State var showFilter = false
    
    
    
    var body: some View {
        //LoadingView(isShowing: $createdEventsVM.stillLoading) {
        
        NavigationView {
           
             
                    VStack{
                    
                            
                        List(eventListVM.eventList, id: \.id) { event in
                                Button(action: {
                                    self.evenState=true
                                    self.eventProfileVM = EventProfileViewModel(eventID: event.id!)
                                   
                                  
                                }, label: {
                                    HStack{
                                        Image(event.eventType)
                                            .renderingMode(.original)
                                            .resizable()
                                            .frame(width:40,height:40)
                                            .aspectRatio(contentMode: .fit)
                                        VStack(alignment: .leading) {
                                            Text(event.eventName)
                                            HStack{
                                                Text("on: "+formatDate(time: event.date))
                                                    .font(Font.system(size:10, design: .default))
                                               Spacer()
                                                Text(String(self.eventListVM.distanceList[event.id!] ?? "") + "km away").font(Font.system(size:10, design: .default))
                                            }
                                        }
                                    }
                                    
                                })
                                  
                                
                                
                                
                            }
                        .sheet(isPresented: self.$evenState, onDismiss: {
                                                                                                 print("onDismiss")
                                                                                                 if self.showOnlySavedEvents {
                                                                                                     self.eventListVM.reloadSavedEvents()
                                                                                                 }
                                                                                             }, content: {
                                                                                              
                                                                                                 // TODO: check why its called for every eventID...
                                                                                               EventProfileView(eventProfileVM:self.eventProfileVM!)
                                                                                                 
                                                                                             })
                            
                        //}
                    }

            .navigationBarTitle(Text("Events"), displayMode: .inline)
            .navigationBarItems(trailing:Button(action: {
                    withAnimation {
                         self.showFilter.toggle()
                    }
                   
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .imageScale(.medium)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 0))
                        .foregroundColor(Color.secondPrimary)
            }.sheet(isPresented: self.$showFilter, content: {
                FilterView(isPresented: self.$showFilter, eventListVM: self.eventListVM, locationPreview: self.locationPreview)
            })
        )
        }
            
            
        }
        
        //}
        
        
        
}
    





struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList(showOnlySavedEvents: false/*events: testEventArray*/)
    }
}
