//
//  EventAnnotationView.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 01.09.19.
//  Copyright © 2019 Philipp Ahrendt. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import SwiftUI

class EventAnnotationView: MKAnnotationView {
    private let db = Firestore.firestore()
    private var joinedUsersReference: CollectionReference?
    var totalNumberOfParticipients: String?
    var eventTitle: String?
    var originalFrame: CGRect?
    var originalImage: UIImage?
    
    override var annotation: MKAnnotation? {
        willSet {
            print("annotation: ", newValue)
            guard let event = newValue as? EventPin else { return }

            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            //TODO: remove if not gonna be used anymore
//            leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
//                                                    size: CGSize(width: 30, height: 30)))
//            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
//            rightCalloutAccessoryView = mapsButton

           image = UIImage(named: event.imageName)
           
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 5
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = event.subtitle
            detailCalloutAccessoryView = detailLabel

            totalNumberOfParticipients = event.totalNumberOfParticipients
            eventTitle = event.title
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            originalImage = image
            let size = CGSize(width: 10, height: 10)
            UIGraphicsBeginImageContext(size)
            image!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            image = resizedImage
        }
        else {
            image = originalImage
        }
    }
    
    @objc func calloutTapped(_ sender: Any){
        let event = annotation as! EventPin
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "InfoScrollVC") as! InfoScrollViewController
        let nextViewController = UIHostingController(rootView:  EventProfileView(eventProfileVM: EventProfileViewModel(eventID: event.id!)))
        nextViewController.rootView.dismiss = self.dismiss

//        nextViewController.eventPin = event
        self.parentContainerViewController()?.navigationController?.present(nextViewController, animated: true, completion: nil)
//        nextViewController.modalPresentationStyle = .popover
//        self.parentContainerViewController()?.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func dismiss() {
        self.parentContainerViewController()?.dismiss(animated: true, completion: nil)
    }
    
    override func addSubview(_ view: UIView) {
        print("add Subview")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(calloutTapped(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //TODO: remove or use instead of gestureRecognizer
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(button)
//        NSLayoutConstraint.activate([
//            button.topAnchor.constraint(equalTo: view.topAnchor),
//            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        button.addTarget(self, action: #selector(calloutTapped(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: -50, width: 100, height: 50)
        
        label.layer.cornerRadius = label.frame.size.height / 2
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .systemBlue
        label.textAlignment = .left

        let pin = annotation as! EventPin

        if view.subviews.count != 0{
            if view.subviews[0] is UIVisualEffectView {
                label.text = pin.joinedUsers! + "/" + pin.totalNumberOfParticipients!
                view.addSubview(label)
            }
        }
        super.addSubview(view)
    }
}

struct EventAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
