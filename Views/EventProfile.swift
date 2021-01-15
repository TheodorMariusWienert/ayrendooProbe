//
//  EventProfile.swift
//  Event
//
//  Created by Theodor Wienert on 17.07.20.
//  Copyright © 2020 Theodor Wienert. All rights reserved.
//

import SwiftUI

import UIKit
import MapKit
import SDWebImageSwiftUI
import Firebase



struct EventProfileView: View {
    
    @State private var showingMapAlert = false
    @State private var shareEventSheet = false
    @State private var showingDeleteAlert = false
    @State var editEventState = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var eventProfileVM: EventProfileViewModel
    var dismiss: (() -> Void)?
    
    
    init(eventProfileVM:EventProfileViewModel){
        print("Init vom EventProfile", eventProfileVM.eventID)
    
        self.eventProfileVM = eventProfileVM
        
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.primary]
        
    }
    
    
    var body: some View {
    
            NavigationView {
                
                //            ContentView()
                    LoadingView(isShowing: $eventProfileVM.stillLoading) {
                VStack(alignment: .center){
                    
                    
                    List(){
                        
                        
                        if(self.eventProfileVM.event != nil){
                            
                            // Image(typeToImageName(typeString: self.eventProfileVM.event!.eventType))
                            
                            //                            Text(String(self.eventProfileVM.event!.joinedUsersCount))
                            //                                .multilineTextAlignment(.center)
                            //
                            //                            Text(" von "+self.eventProfileVM.event!.numberOfParticipants)
                            //                            .multilineTextAlignment(.center)
                            
                            Section(header: Text("Attendees")) {
                                self.progressUser
                                
                                
                                
                                VStack(alignment: .center){
                                    ScrollView (.horizontal){
                                        
                                        HStack{
                                            ForEach(self.eventProfileVM.users, id: \.uid) { user in
                                                UserInScrollView(user:user, myUserID: self.eventProfileVM.eventRepo.user.uid)
                                            }
                                            
                                        }
                                    }.frame(height:100)
                                    VStack{
                                        
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                self.shareEventSheet.toggle()
                                                shareButton(self.eventProfileVM.event!)
                                            }){
                                                VStack{
                                                    Image(systemName: "square.and.arrow.up")
                                                        .font(.title)
                                                    Text("Share Event")
                                                } .accentColor(Color.secondPrimary)
                                            }.buttonStyle(BorderlessButtonStyle())
                                         
                                            if(self.eventProfileVM.event!.creator != self.eventProfileVM.eventRepo.user.uid){
                                                   Spacer()
                                            Button(action: {
                                                self.saveEvent(self.eventProfileVM.event!)
                                            }){
                                                VStack{
                                                    Image(systemName: self.eventProfileVM.bookmark)
                                                        .font(.title)
                                                    Text("Save Event")
                                                } .accentColor(Color.secondPrimary)
                                            }.buttonStyle(BorderlessButtonStyle())
                                            }
                                            Spacer()
                                        }
                                    }
                                        .padding(.bottom)
                                }
                            }
                            Section(header: Text("Date")) {
                                Text(formatDate(time: self.eventProfileVM.event!.date))
                            }
                            
                            
                            Section(header: Text("Description")) {
                                
                                Text(self.eventProfileVM.event!.eventDescription)
                            }
                            if(self.eventProfileVM.event!.requirements != ""  ){
                                Section(header: Text("Requirments")) {
                                    
                                    Text(self.eventProfileVM.event!.requirements)
                                }
                            }
                            Section(header: Text("Adress")) {
                                VStack(alignment:.center){
                                    Text(self.eventProfileVM.event!.street)
                                    Button(action: {
                                        self.showingMapAlert = true
                                    }, label: {
                                        VStack {
                                            Image("Maps-icon").renderingMode(.original)
                                        }
                                    }).buttonStyle(BorderlessButtonStyle())
                                        .alert(isPresented: self.$showingMapAlert) {
                                            Alert(title: Text("Open in Maps?"),
                                                  
                                                  primaryButton: .destructive(Text("Yes"), action:{ showMap(street: self.eventProfileVM.event!.street) })
                                                ,
                                                  secondaryButton: .cancel(Text("No"))
                                            )
                                            
                                    }
                                    
                                    
                                }
                            }
                            
                            
                            
                        }
                    }.listStyle(GroupedListStyle())
                    
                    
                }
                     }
                .navigationBarTitle(Text(self.eventProfileVM.eventName), displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    if self.dismiss != nil {
                        self.dismiss!()
                    }
                    else {
                        //TODO: remove since this doesn't work?
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .imageScale(.medium)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                        .foregroundColor(Color.secondPrimary)
                    }
                    
                    ,trailing:   Button(action : {
                        if(self.eventProfileVM.eventRepo.user.uid == self.eventProfileVM.event!.creator){
                            self.eventProfileVM.view = self
                            self.editEventState = true
                        }
                        else {
                            self.eventProfileVM.pressButton()
                        }
                    }){
                        Text(self.eventProfileVM.buttonStateName)
                            .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 0))
                            .foregroundColor(Color.secondPrimary)
                    }.disabled(self.eventProfileVM.buttonStateName == "Wait" )
                        .sheet(isPresented: self.$editEventState, content: {
                            self.eventProfileVM.editEvent()
                        })
                        
                        
                        // .frame(height: self.eventProfileVM.buttonStateName == "" ? nil : 0)//hides button if i cant join
                        )
                    
                    .background(Color(UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)))
                //.edgesIgnoringSafeArea(.bottom)
           
        }
    }
    
    var progressUser: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress(joinedUsers: self.eventProfileVM.event!.joinedUsersCount, maxUsers: self.eventProfileVM.event!.numberOfParticipants), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeIn)
            HStack{
                //Text(String(self.eventProfileVM.event!.joinedUsersCount)+" von "+String(100000))
                Text(String(self.eventProfileVM.event!.joinedUsersCount)+" von "+self.eventProfileVM.event!.numberOfParticipants)
                //                Text("von")
                //                //Text(self.eventProfileVM.event!.numberOfParticipants)
                //                   Text("100000")
                
            }
        }
        .frame(height:100)
        .padding()
    }
    
    func saveEvent(_ event: Event){
        if self.eventProfileVM.eventIsSaved {
            firestore.collection(kUSERS).document(Auth.auth().currentUser!.uid).collection(kSAVEDEVENTS).document(event.id!).delete() { error in
                if let error = error {
                    print("Unexpected error: \(error)")
                    return
                }
                else {
                    print("unsaved")
                    self.eventProfileVM.bookmark = "bookmark"

                }
                
            }
        }
        else {
            
            //TODO: make user wait before enabling another firestore call
            firestore.collection(kUSERS).document(Auth.auth().currentUser!.uid).collection(kSAVEDEVENTS).document(event.id!).setData([kEVENTID: event.id!]) { error in
                if let error = error {
                    print("Unexpected error: \(error)")
                    return
                }
                else {
                    print("saved")
                    self.eventProfileVM.bookmark = "bookmark.fill"
                }
                
            }
            
        }
        self.eventProfileVM.eventIsSaved = !self.eventProfileVM.eventIsSaved

    }
    
}

func close(){
    
    let root = UIApplication.shared.keyWindow?.rootViewController
    root?.dismiss(animated: true, completion: nil)
}
func showMap(street: String) {
    print("Street",street)
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(street){ (placemarks, error) in
        // Process Response
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
        }
        else {
            let clPlacemark = placemarks?.first
            if let addressDict = clPlacemark?.addressDictionary as? [String:AnyObject]?, let coordinate = clPlacemark?.location?.coordinate {
                let mapItem = MKMapItem(placemark:MKPlacemark(coordinate: coordinate, addressDictionary: addressDict))
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: launchOptions)
            }
        }
    }
    
}


//func progressColor(joinedUsers: Int, maxUsers: String)-> (Color){
//
//    if(progress(joinedUsers: joinedUsers, maxUsers: maxUsers) == 1){
//        return Color.red
//
//    }
//    else{
//        return Color.green
//    }
//}
func progress(joinedUsers: Int, maxUsers: String)-> (Double){
    print("jointSU",joinedUsers)
    print("maxusers",maxUsers)
    if(maxUsers != "∞"){
        return (Double)(Double(joinedUsers)/Double(maxUsers)!)
        // return (Double)(Double(joinedUsers)/Double(maxUsers)!)
    }
    else{
        return 1.0
    }
    
}





struct UserInScrollView: View {
    var user: User
    var myUserID: String
    private let storageRef = Storage.storage().reference()
    
    
    
    var body: some View {
        
        
        
        
        VStack{
            
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
            
            if(user.uid == myUserID){
                //.stroke(Color.orange, lineWidth: 4)
                Text("You")
                
                
            }
            else{
                Text(user.username)
            }
            
            
            
            
            //
            
            
        }
        
        
        
        
        
        
    }
}

func shareButton(_ event: Event){
    // TODO: better title
    let socialMetaTagTitle =  "Event (\(event.eventName)) from Ayrendoo"
    let socialMetaTagDescription = event.eventDescription
    let promoText = "Check out this cool event on Ayrendoo! Let's go there together "
    
    createDynamicLink(path: kEVENTSPATH, queryItemName: [kEVENTID], queryItemValue: [event.id ?? ""], socialMetaTagTitle: socialMetaTagTitle, socialMetaTagDescription: socialMetaTagDescription, promoText: promoText)
}


struct EventProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EventProfileView(eventProfileVM: EventProfileViewModel(eventID: "1vezU1zhiHaK9DPGl1AI"))
    }
}
extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}


