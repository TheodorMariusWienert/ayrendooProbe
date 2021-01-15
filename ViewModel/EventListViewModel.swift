//
//  EventListViewModel.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 27.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class EventListViewModel: ObservableObject,Identifiable{
    
//    var  eventListRepo = EventListViewRepository()
    @Published var eventList = [Event]()
    
    @Published var distanceList = [String: String]()
        
    init(isTabBar: Bool){
//        eventList = eventListRepo.eventList
        print("eventListViewModel init")
        if isTabBar {
            EventFetcher.shared.handleDocumentChangeListView = handleDocumentChange
            EventFetcher.shared.handleUpdateUserLocation = distanceFromUserLocation
        }
        else {
            for event in EventFetcher.shared.eventList {
               
               //TODO: remove since we don't need another firestore call
                firestore.collection(kUSERS).document(Auth.auth().currentUser!.uid).collection(kSAVEDEVENTS).document(event.value.id!).getDocument { (document, error) in
                    if let error = error {
                        print("Unexpected error: \(error)")
                        return
                    }
                    if let document = document, document.exists {
                        self.eventList.append(event.value)
                        self.distanceFromUserLocation(userLocation: EventFetcher.shared.userLocation)
                    }
                }
            }
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        guard let event = Event(document: change.document) else {
            print("can't initialize document as Event")
            return
        }
        
        switch change.type {
        case .added:
            if eventList.contains(event) {
                return
            }
            let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            if isDistanceInRange(eventLocation: eventLocation, filterLocation: EventFetcher.shared.userLocation, filterRange: 50.0) {
                eventList.append(event)
            }
        case .modified:
            guard let index = eventList.firstIndex(of: event) else { return }
            eventList.remove(at: index)
            
            let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            if isDistanceInRange(eventLocation: eventLocation, filterLocation: EventFetcher.shared.userLocation, filterRange: 50.0) {
                eventList.insert(event, at: index)
            }
            
        case .removed:
            guard let index = eventList.firstIndex(of: event) else { return }
            eventList.remove(at: index)
        }
    }
    
    func distanceFromUserLocation(userLocation: CLLocation) {
        for event in eventList {
            let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            let distance = eventLocation.distance(from: userLocation)/1000
            
            // round to first digit after point if closer than 10km
            if distance < 10.0 {
                distanceList[event.id!] = String(round(10*(distance))/10)
            }
            else {
                distanceList[event.id!] = String(Int(distance))
            }
        }
    }
    
    func reloadSavedEvents() {
        for event in self.eventList {
            firestore.collection(kUSERS).document(Auth.auth().currentUser!.uid).collection(kSAVEDEVENTS).document(event.id!).getDocument { (document, error) in
                if let error = error {
                    print("Unexpected error: \(error)")
                    return
                }
                if document == nil || !(document!.exists) {
                    if let index = self.eventList.firstIndex(of: event) {
                        self.eventList.remove(at: index)
                    }
                }
            }
        }
    }
    
    func updateWithAppliedFilters(_ filter: EventFilter) {
        eventList.removeAll()
        for eventKeyValuePair in EventFetcher.shared.eventList {
            let event = eventKeyValuePair.value
//            if !filter.type.contains(event.eventType){
//                continue
//            }
            if !filter.type[event.eventType]! {
                continue
            }

            let eventDate = Date(timeIntervalSince1970: Double(event.date))
            if !isInTimeFrame(eventDate: eventDate, dateFilter: filter.filterDates) {
                continue
            }
            
            let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            if !isDistanceInRange(eventLocation: eventLocation, filterLocation: filter.location, filterRange: filter.locationRadius)
            {
                continue
            }
            
            // TODO: persist filter selection for next time FilterView is presented
            eventList.append(event)
        }
    }
    
    func isDistanceInRange(eventLocation: CLLocation, filterLocation: CLLocation, filterRange: Double) -> Bool {
        print("eventLocation \(eventLocation), filterLocation: \(filterLocation), filterRange \(filterRange)")
        print("filterLocation.distance(from: eventLocation): \(filterLocation.distance(from: eventLocation))")
        return (filterLocation.distance(from: eventLocation) < filterRange*1000)
    }
    
    func isInTimeFrame(eventDate: Date, dateFilter: DateFilter) -> Bool {
        let calendar = Calendar.current
        
        if dateFilter.today {
            let todaysDate = calendar.date(byAdding: .day, value: 0, to: Date())
            if (todaysDate!.isInSameDayOf(date: eventDate)) {
                return true
            }
        }
        
        if dateFilter.tomorrow {
            let tomorrowsDate = calendar.date(byAdding: .day, value: 1, to: Date())
            if (tomorrowsDate!.isInSameDayOf(date: eventDate)) {
                return true
            }
        }
        
        if dateFilter.weekend {
            if calendar.isDateInThisWeekend(eventDate) {
                return true
            }
        }
        
        if calendar.isDate(dateFilter.selectedDate, equalTo: eventDate, toGranularity: .day) {
            return true
        }
        return false
    }
}

