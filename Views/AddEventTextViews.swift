//
//  AddEventTextViews.swift
//  ayrendoo
//
//  Created by Philipp Ahrendt on 23.06.20.
//  Copyright © 2020 Philipp Ahrendt. All rights reserved.
//

import UIKit
import MapKit
import SwiftUI


class AddEventTextField: UITextField {
    var datePicker: UIDatePicker?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }
}

extension AddEventTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

          if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
             nextField.becomeFirstResponder()
          } else {
             // Not found, so remove keyboard.
             textField.resignFirstResponder()
          }
          // Do not add a line break
          return false
       }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    override func becomeFirstResponder() -> Bool {
        if let vc = self.parentContainerViewController() as? AddEventTableViewController
        {
            vc.tableView.beginUpdates()
            datePicker?.isHidden = true
            vc.tableView.endUpdates()
        }
        return super.becomeFirstResponder()
    }
}

class AddEventNameTextField: AddEventTextField {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.autocapitalizationType = .sentences
        self.delegate = self
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 25
    }
}

//extension AddEventNameTextField: UITextFieldDelegate {
//
//}
class AddEventTextView: UITextView, UITextViewDelegate {
    var cellDelegate: ExpandingCellDelegate?
    var cellIndex: IndexPath?
    var datePicker: UIDatePicker?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }
    
    override func becomeFirstResponder() -> Bool {
        if let vc = self.parentContainerViewController() as? AddEventTableViewController
        {
            vc.tableView.beginUpdates()
            datePicker?.isHidden = true
            vc.tableView.endUpdates()
        }
        return super.becomeFirstResponder()
    }
    
        
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        
        if let vc = self.parentContainerViewController() as? AddEventTableViewController
        {
            vc.textFieldChanged()
        }
        
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = textView.frame

        // Our base height
        let baseHeight: CGFloat = 50
        /* Our new height should never be smaller than our base height, so use the larger of the two */
        let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        
        cellDelegate?.updated(height: height, index: cellIndex!)
        
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        if #available(iOS 13.0, *) {
            placeholderLabel.textColor = UIColor.placeholderText
        } else {
            placeholderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}

class EventTypeTextField: AddEventTextField {
    var selectedEventType: String?
    var icon: UIImageView?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createPickerView()
        dismissPickerView()
    }
    
}

extension EventTypeTextField: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // number of session
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kEVENTTYPELIST.count // number of dropdown items
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return kEVENTTYPELIST[row] // dropdown item
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEventType = kEVENTTYPELIST[row] // selected item
        
        self.text = selectedEventType
        if (icon != nil) {
//            var image: String!
//            if self.text == "Social" {image = "Drinks"}
//            else if self.text == "Sports" {image = "Football"}
//            else if self.text == "Games" {image = "AceOfSpades"}
//            else if self.text == "Culture" {image = "Leaf"}
//            else if self.text == "Tourism" {image = "PersonWithLuggage"}
//            else if self.text == "Study" {image = "Book"}
//            else {image = "Questionmark"}
            guard let type = self.text else { icon?.image = UIImage(named: "Other"); return }
            icon?.image = UIImage(named: type)
        }
        
        if let vc = self.parentContainerViewController() as? AddEventTableViewController
        {
            vc.textFieldChanged()
        }
    }
    
    func createPickerView(){
        let pickerView = UIPickerView()
        self.delegate = self
        pickerView.delegate = self
        self.inputView = pickerView
    }
    
    func dismissPickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneAction))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        if self.text == "" {
            self.text = kEVENTTYPELIST[0]
            icon?.image = UIImage(named: self.text!)
            if let vc = self.parentContainerViewController() as? AddEventTableViewController
            {
                vc.textFieldChanged()
            }
        }
    }
    @objc func doneAction() {
        self.endEditing(true)
    }
}

class ParticipientNumberTextField: AddEventTextField {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.keyboardType = .numberPad
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Unlimited Participients", style: .plain, target: self, action: #selector(self.unlimitedParticipients))
        let flexibleSpace = UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: nil,
        action: nil)
        toolBar.setItems([flexibleSpace,button,flexibleSpace], animated: true)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
}
extension ParticipientNumberTextField {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    @objc func unlimitedParticipients() {
        // TODO: check if infinity symbol doesn't cause problems
        self.text = "∞"
        self.endEditing(true)
    }
}

class StreetTextField: AddEventTextField {

    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        searchCompleter.delegate = self
        self.delegate = self
     
        //createSearchBar()
    }

    override func textFieldDidBeginEditing(_ textField: UITextField) {
            print("begin editing")
            super.textFieldDidBeginEditing(textField)
            let vc = UITableViewController()
            let searchBar = UISearchBar()
            searchBar.sizeToFit()
            searchBar.becomeFirstResponder()
            searchBar.delegate = self
            searchBar.showsCancelButton = true
            
            vc.tableView.tableHeaderView = searchBar
            vc.tableView.delegate = self
            vc.tableView.dataSource = self
        findViewController()?.present(vc, animated: true) {
                searchBar.text = self.text
                print("present")
            }
        }
}

extension StreetTextField: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        let table = findViewController()?.presentedViewController?.view as! UITableView
        table.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error or remove this function
        print("completer")
    }
    
}

extension StreetTextField: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        self.text = searchText
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCompleter.queryFragment = self.text ?? ""
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancelButtonClicked")
        findViewController()?.presentedViewController?.dismiss(animated: true, completion: {
            // nothing
        })
    }
}

extension StreetTextField: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension StreetTextField: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let completion = searchResults[indexPath.row]

        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            // TODO: store coordinate directly?
            // TODO: show place on map to confirm first? or enough if zoom on event after creation
            self.findViewController()?.presentedViewController?.dismiss(animated: true, completion: nil)
            self.text =  response?.mapItems[0].placemark.title
            if let vc = self.parentContainerViewController() as? AddEventTableViewController {
                vc.textFieldChanged()
            }
        }
    }
}
