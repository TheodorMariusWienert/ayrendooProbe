//
//  FilterView.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 26.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
import MapKit
import Combine


struct FilterView: View {
    @State private var date = Date()
    @State private var tomorrowState = true
    @State private var todayState = true
    @State private var weekendState = true
    @State private var catExpanded=false
    @State private var locationExpanded=false
    @State private var previewResults=false
    @State private var showDistanceSlider=false
    @State private var currentLocation=true
    
    
    
    @State private var myEventsState = false
    @State private var friendsEventsState = true
    @State private var strangersEventsState = true
    
    @State private var location = EventFetcher.shared.userLocation
    @State private var distance = 25.0
    @ObservedObject var locationPreview: LocationPreview
    
    @State private var toggleAll = true
    
    @State var locationViewisPresented=false
    
    @Binding var isPresented:Bool
    var eventListVM: EventListViewModel
    
    var catDisclosureText: String {
        if self.toggleAll {
            return "All"
        }
        var count = 0
        var categorie = ""
        for i in (0..<kEVENTTYPELIST.count) {
            if selectedCat[i] {
                count += 1
                if count == 2 {
                    categorie = categorie + " & " + kEVENTTYPELIST[i]
                }
                else {
                    categorie = kEVENTTYPELIST[i]
                }
            }
        }
        if !selectedCat.contains(false) {
            return "All"
        }
        if count <= 2 {
            return categorie
        }
        else {
            return String(count) + " out of " + String(kEVENTTYPELIST.count)
        }
    }
    @State var locationDisclosureText="Current Location"
    @State var selectedCat = Array(repeating: true, count: kEVENTTYPELIST.count)

    init(isPresented: Binding<Bool>, eventListVM: EventListViewModel, locationPreview: LocationPreview) {

        self.locationPreview = locationPreview
        self._isPresented = isPresented
        self.eventListVM = eventListVM
        if let appliedFilter = NonPersistentStorage.shared.appliedFilter {
            // TODO: toggle already applied filters
            self._toggleAll = State(initialValue: !appliedFilter.type.values.contains(false))
            
            self._selectedCat = State(initialValue: Array(appliedFilter.type.values))
            
            self._todayState = State(initialValue: appliedFilter.filterDates.today)
            self._tomorrowState = State(initialValue: appliedFilter.filterDates.tomorrow)
            self._weekendState = State(initialValue: appliedFilter.filterDates.weekend)
            self._date = State(initialValue: appliedFilter.filterDates.selectedDate)
            
            // TODO: still uses currentLocation every time
            self._location = State(initialValue: appliedFilter.location)
            self._distance = State(initialValue: appliedFilter.locationRadius)
            
            // TODO: myEvents, friendsEvents, strangersEvents
            
        }
//    UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
//          UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    
    }
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Form{
                    Section(){
                        HStack{
                            Text("Categories Applied")
                            Spacer()
                            Text(catDisclosureText)
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.secondPrimary)
                        } .onTapGesture {
                            self.catExpanded.toggle()
                        }
                        
                        if(catExpanded){
                            Toggle("All Categories",isOn: self.$toggleAll.didSet { (state) in
                                if (state){
                                    for n in 0...self.selectedCat.count-1 {
                                        self.selectedCat[n]=true
                                    }
                                }
                                else{
                                    for n in 0...self.selectedCat.count-1 {
                                        self.selectedCat[n]=false
                                    }      }
                            })
                            ForEach(0 ..< kEVENTTYPELIST.count ) { i in
                                
                                // TODO: at least one categorie has to be toggled on
                                Toggle(kEVENTTYPELIST[i],isOn: self.$selectedCat[i].didSet { (state) in
                                    if (state){
                                        var i=0
                                        for n in 0...self.selectedCat.count-1 {
                                            if(self.selectedCat[n]){
                                                i += 1
                                            }
                                        }
                                        if(i==self.selectedCat.count){
                                            self.toggleAll=true
                                        }
                                    }
                                    else{
                                        self.toggleAll=false
                                    }
                                })
                            }
                        }
                        
                        
                    }
                    Section(){
                        Toggle(isOn: $todayState) {
                            Text("Today")
                        }
                        Toggle(isOn: $tomorrowState) {
                            Text("Tommorow")
                        }
                        Toggle(isOn: $weekendState) {
                            Text("This weekend")
                        }
                        
                        DatePicker("Select a date",selection: self.$date, in: Date()...,displayedComponents: .date)
                            .padding(0)
                        
                        
                    }
                    Section(){
                        HStack{
                            Text("Location")
                            Spacer()
                            Text(locationDisclosureText)
                            Image(systemName: "chevron.down")
                             .foregroundColor(Color.secondPrimary)
                             
                                                          
                        }
                            .onTapGesture {
                                self.locationExpanded.toggle()
                                self.showDistanceSlider.toggle()
                                
                        }
                        if(locationExpanded){
                            Button(action: {
                                self.currentLocation=true
                                self.locationDisclosureText="Current Location"
                                self.locationPreview.query=""
                                self.location = EventFetcher.shared.userLocation
                                
                            }) {
                                if(!currentLocation){
                                    HStack{ Text("Current Location")
                                    Image(systemName: "location")
                                       
                                    }
                                }
                                else{   HStack{ Text("Current Location")
                                    Image(systemName: "location.fill")
                                    }
                                }
                               
                            }.accentColor( Color.secondPrimary)
                          
                            HStack{
                                  Image(systemName: "magnifyingglass")
                                TextField("Search", text: $locationPreview.query)
                                    .disabled(true)
                                Button("", action: {
                                      self.locationViewisPresented=true
                                } )
                                   
                            }
                                .sheet(isPresented: self.$locationViewisPresented, content: {
                                                                 
                                    LocationSearchView(isPresented: self.$locationViewisPresented, currentLocation: self.$currentLocation, locationFromSearch: self.$location, locationService: self.locationPreview)
                                                                      
                                                                  })
//
                            if(showDistanceSlider){
                                VStack(alignment: .center){
                                    Slider(value: $distance, in: 0...100, step: 1.0)
                                    .accentColor(Color.secondPrimary)
                                    Text("Radius for events: "+String(distance)+" km")
                                }
                            }
                            
                        }
                        
                    }
                    Section(){
                        Toggle(isOn: $myEventsState) {
                            Text("My Events")
                        }
                        Toggle(isOn: $friendsEventsState) {
                            Text("Events From Friends")
                        }
                        Toggle(isOn: $strangersEventsState) {
                            Text("Events From Strangers")
                        }
                        
                    }
                    
                
                }
            }
                
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
               
            .navigationBarTitle(Text("Filter"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.isPresented=false
            }) {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                    .foregroundColor(Color.secondPrimary)
                }
                
                ,trailing:   Button(action : {
                    self.applyFilters()
                    
                }){
                    Text("Apply")
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 0))
                        .foregroundColor(Color.secondPrimary)
            })
                
                .background(Color(UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)))
            
            
        }
    }
    

    func applyFilters() {
        var eventTypeFilter = [String: Bool]()
        for (index, element) in kEVENTTYPELIST.enumerated() {
            // map eventTypeString to corresponding toggleState Bool
            eventTypeFilter[element] = selectedCat[index]
        }
        
        let filterDates = DateFilter(today: self.todayState, tomorrow: self.tomorrowState, weekend: self.weekendState, selectedDate: self.date)
        let filter = EventFilter(type: eventTypeFilter, location: location, locationRadius: self.distance, filterDates: filterDates)
        self.eventListVM.updateWithAppliedFilters(filter)
        NonPersistentStorage.shared.appliedFilter = filter
        
        self.locationPreview.query = ""
        self.isPresented = false
        }
        
        
}



struct FilterView_Previews: PreviewProvider {
   @State static var value = false
    static var previews: some View {
        FilterView(isPresented: $value, eventListVM: EventListViewModel(isTabBar: true), locationPreview: LocationPreview())
    }
}
