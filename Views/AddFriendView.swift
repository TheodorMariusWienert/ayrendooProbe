//
//  AddFriendView.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 26.08.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import SwiftUI
import Firebase
import CoreImage.CIFilterBuiltins

struct AddFriendView: View {
    @Binding var isPresented:Bool
    @Binding var name: String
    @State var qrCode: Image = Image(systemName: "plus")
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack{
                Text("My Code")
                Image(uiImage: self.generateQRCode())
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                List{
                    Section(header: Text("Add Friend")) {
                        VStack{
                            Button(action: {
                                self.scanQRCode()
                            }){
                                HStack {
                                    VStack{
                                        Image(systemName: "camera.viewfinder")
                                            .resizable()
                                            
                                            .aspectRatio(UIImage(systemName: "camera.viewfinder")!.size,contentMode: .fit)
                                            .foregroundColor(Color.secondPrimary)
                                    }.frame(height:25)
                                        .padding(2.5)
                                    
                                    
                                    Text("Scan code")
                                        .fontWeight(.semibold)
                                        
                                        .foregroundColor(.black)
                                }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            }.buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                            Button(action: {
                                self.addByUsername()
                            }){
                                HStack {
                                    VStack{
                                        Image(systemName: "person.badge.plus.fill")
                                            .resizable()
                                            
                                            .aspectRatio(UIImage(systemName: "person.badge.plus.fill")!.size,contentMode: .fit)
                                            .foregroundColor(Color.secondPrimary)
                                    }.frame(height:25)
                                        .padding(2.5)
                                    
                                    
                                    Text("Add by Username")
                                        .fontWeight(.semibold)
                                        
                                        .foregroundColor(.black)
                                }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            }.buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                            Button(action: {
                                self.inviteFriend()
                            }){
                                HStack {
                                    VStack{
                                        Image(systemName: "link.circle.fill")
                                            .resizable()
                                            
                                            .aspectRatio(UIImage(systemName: "link.circle.fill")!.size,contentMode: .fit)
                                            .foregroundColor(Color.secondPrimary)
                                    }.frame(height:25)
                                        .padding(2.5)
                                    
                                    
                                    Text("Invite Friend")
                                        .fontWeight(.semibold)
                                        
                                        .foregroundColor(.black)
                                }.frame(maxWidth: .infinity,maxHeight: .infinity)
                            }.buttonStyle(SimpleButtonStyle(color: Color.normalGray))
                        }
                    }.listRowBackground(Color.superLightGray)
                }.listStyle(GroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
                
            }
            .background(Color.superLightGray )
            .navigationBarTitle(Text("Add Friend").foregroundColor(Color.secondPrimary), displayMode: .inline)
                
            .navigationBarItems(leading: Button(action: {
                self.isPresented=false
            }) {
                Image(systemName: "chevron.down")
                    .imageScale(.medium)
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                    .foregroundColor(Color.secondPrimary)
            })
        }
    }
    
    func generateQRCodeLink() -> String{
        print("generateQRCodeLink()")
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let name = self.name
        
        var components = URLComponents()
        components.scheme = kSCHEME
        components.host = kHOST
        components.path = kINVITEFRIENDSPATH
        
        components.queryItems = [URLQueryItem(name: kUID, value: uid), URLQueryItem(name: kNAME, value: name)]
        
        guard let linkParameter = components.url else { return "" }
        print("Sharing \(linkParameter.absoluteString)")
        
        // create big dynamic link
        guard let shareLink = DynamicLinkComponents(link: linkParameter, domainURIPrefix: kDOMAINURIPREFIX) else {
            print("Couldn't create FDL components")
            return ""
        }
        
        if let bundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        }
        shareLink.iOSParameters?.appStoreID = kAPPSTOREID
        
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        
        guard let longURL = shareLink.url else { return ""}
        print("The long dynamicURL is \(longURL.absoluteString)")
        return longURL.absoluteString
        
    }
    
    func generateQRCode() -> UIImage {
        
        let link = generateQRCodeLink()
        let data = Data(link.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func scanQRCode() {
        print("scanQRCode()")
        //        let rootView = (UIApplication.shared.windows.last?.rootViewController?.view)!
        
        
        let vc = UINavigationController(rootViewController: QRScannerViewController())
        
        UIApplication.shared.windows.last?.rootViewController?.present(vc,animated: true,completion: nil)
    }
    
    func inviteFriend() {
        print("inviteFriend()")
        let socialMetaTagTitle =  "socialMetaTagTitle"
        let socialMetaTagDescription = "socialMetaTagDescription"
        let promoText = "Hey man, let's be friends!"
        let uid = Auth.auth().currentUser?.uid ?? ""
        let name = self.name
        
        createDynamicLink(path: kINVITEFRIENDSPATH, queryItemName: [kUID, kNAME], queryItemValue: [uid, name], socialMetaTagTitle: socialMetaTagTitle, socialMetaTagDescription: socialMetaTagDescription, promoText: promoText)
    }
    
    func addByUsername() {
        print("addByUsername()")
    }
}



struct AddFriendView_Previews: PreviewProvider {
       @State static var value = false
    static var previews: some View {
        AddFriendView(isPresented: $value, name: .constant("username"))
    }
}
