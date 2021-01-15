//
//  LocationSearchView.swift
//  ayrendoo
//
//  Created by Theodor Wienert on 12.09.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Binding var isPresented:Bool
    @Binding var currentLocation:Bool
    @Binding var locationFromSearch: CLLocation
    @ObservedObject var locationService: LocationPreview
    @State var results = true
    var body: some View {
        NavigationView{
        VStack {
            Form {
                Section(header: Text("Location Search")) {
                    
                    HStack{
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $locationService.query, onEditingChanged: { (changed) in
                            self.results=true
                            print("Edited")
                        })
                        Spacer()
                        if !locationService.query.isEmpty
                        {
                            Button(action:
                                {
                                    self.locationService.query = ""
                                    self.results=true
                            })
                            {
                                Image(systemName: "clear")
                                    .foregroundColor(Color(UIColor.opaqueSeparator))
                            }
                            .padding(8)
                        }
                    }
                    
                }
                if(results){
                    Section(header: Text("Results")) {
                        if locationService.status == .isSearching {
                            Image(systemName: "clock")
                                .foregroundColor(Color.gray)
                        }
                        List {
                            
                            Group { () -> AnyView in
                                switch locationService.status {
                                case .noResults: return AnyView(Text("No Results"))
                                case .error(let description): return AnyView(Text("Error: \(description)"))
                                default: return AnyView(EmptyView())
                                }
                            }.foregroundColor(Color.gray)
                            
                            
                            ForEach(locationService.searchResults, id: \.self) { completionResult in
                                
                                VStack(alignment: .leading){
                                    Text(completionResult.title)
                                    Text(completionResult.subtitle)
                                        .fontWeight(.light)
                                        .font(Font.system(size:10, design: .default))
                                    Button("", action: {
                                        
                                        self.locationService.query=completionResult.title+", " + completionResult.subtitle
                                        //self.locationService.startSearchWith(completion: completionResult)
                                        
                                        CLGeocoder().geocodeAddressString(completionResult.title+", " + completionResult.subtitle){ (placemarks, error) in
                                            // Process Response
                                            if let error = error {
                                                print("Unable to Forward Geocode Address (\(error))")
                                                
                                            }
                                            
                                            
                                            if let placemarks = placemarks, placemarks.count > 0 {
                                                self.locationFromSearch = placemarks.first?.location! as! CLLocation
                                                self.currentLocation=false
                                                self.isPresented=false
                                            }
                                            else{
                                                print("CAnt find coordinates for this shit")
                                                self.results=false
                                                self.locationService.startSearchWith(completion: completionResult)
                                            }
                                            
                                        }
                                        
                                    })
                                }
                                
                                
                                
                            }
                        }
                    }
                    
                }
                    
                else{
                    Section(header: Text("Results")) {
                        
                        if(locationService.mapResults.count>0)
                        {
                            ForEach(locationService.mapResults, id: \.self) { mapResult in
                                
                                VStack(alignment: .leading){
                                    if(mapResult.name != nil){
                                        Text(mapResult.name!)
                                    }
                                    Text(self.createAdress(placemark: mapResult.placemark))
                                        .fontWeight(.light)
                                        .font(Font.system(size:10, design: .default))
                                    Button("", action: {
                                        if(mapResult.name != nil){
                                            
                                            self.locationService.query=mapResult.name!
                                        }
                                        self.locationService.query+=self.createAdress(placemark: mapResult.placemark)
                                        
                                        
                                        if(mapResult.isCurrentLocation){
                                            self.locationService.query=""
                                            self.currentLocation=true
                                            self.isPresented=false
                                        }
                                        else{
                                          if(mapResult.placemark != nil) {
                                                self.locationFromSearch = mapResult.placemark.location!
                                            print("PLACE",mapResult.placemark.location!)
                                                self.currentLocation=false
                                                self.isPresented=false
                                            }
                                        }
                                        
                                        
                                        
                                    })
                                    
                                }
                                
                            }
                        }
                        else{
                            Text ("No Results change search")
                        }
                        
                    }
                }
            }
        }  .navigationBarTitle(Text(""), displayMode: .inline)
                      .navigationBarItems(leading: Button(action: {
                          self.isPresented=false
                          
                      }) {
                          Image(systemName: "chevron.down")
                              .imageScale(.medium)
                                 .foregroundColor(Color.secondPrimary)
                              
                              .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                      })
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
    func createAdress( placemark: CLPlacemark)-> String{
        var addressString : String = ""
        if placemark.isoCountryCode == "TW" /*Address Format in Chinese*/ {
            if placemark.country != nil {
                addressString = placemark.country!
            }
            if placemark.subAdministrativeArea != nil {
                addressString = addressString + placemark.subAdministrativeArea! + ", "
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode! + " "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality!
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare!
            }
            if placemark.subThoroughfare != nil {
                addressString = addressString + placemark.subThoroughfare!
            }
        } else {
            if placemark.subThoroughfare != nil {
                addressString = placemark.subThoroughfare! + " "
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare! + ", "
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode! + " "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality! + ", "
            }
            if placemark.administrativeArea != nil {
                addressString = addressString + placemark.administrativeArea! + " "
            }
            if placemark.country != nil {
                addressString = addressString + placemark.country!
            }
            
        }
        return addressString
    }
}

