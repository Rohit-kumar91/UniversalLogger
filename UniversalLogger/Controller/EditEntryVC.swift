//
//  EditEntryVC.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 13/11/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton

class EditEntryVC: UIViewController {
    
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var newEntryTitleLabel: UILabel!
    @IBOutlet weak var spinner: SSSpinnerButton!

    lazy var editValueJson = [[JSON]]()
    lazy var finalEditArray = [JSON]()
    lazy var tableviewDataArray = [JSON]()
    lazy var falseValueArray = [JSON]()
    lazy var dbName = String()
    
    var jsonStaticCategoryArray = [JSON]()
    var jsonOtherCategoryArray = [JSON]()
    let editEntryModel = EditEntryModel()
    
    var databaseID = String()
    var ULID = String()
    
    var pickerView : UIPickerView!
    var pickerData =  [String]()
    var pickerSelectedData = String()
    var textFieldTagValue = Int()
    var isPickerVisible = Bool()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newEntryTitleLabel.text = dbName

//        let filteredCategoryArray = editValueJson.filter({
//            $0["VFChecked"] == true
//        })

        //databaseID = editValueJson["data"]["DatabaseID"].stringValue
        //ULID = editValueJson["data"]["UL_ID"].stringValue
        
        
        print(editValueJson)
        
        for saticCategory in editValueJson[0] {
            var tempDict = JSON()
            tempDict["SFID"] = saticCategory["SFID"]
            tempDict["SFieldName"] = saticCategory["SFieldName"]
            tempDict["SF_Value"] = saticCategory["SF_Value"]
            tempDict["VFChecked"] = saticCategory["VFChecked"]
            tempDict["SubCategoryValue"] = saticCategory["SubCategoryValue"]
            jsonStaticCategoryArray.append(tempDict)
        }
        
        
       
        for otherCategory in editValueJson[1] {
            var tempDict = JSON()
            tempDict["CategoryID"] = otherCategory["CategoryID"]
            tempDict["CategoryName"] = otherCategory["CategoryName"]
            tempDict["CategoryValue"] = otherCategory["CategoryValue"]
            tempDict["VFChecked"] = otherCategory["VFChecked"]
            tempDict["SubCategoryValue"] = otherCategory["SubCategoryValue"]
            jsonOtherCategoryArray.append(tempDict)
        }
        
        
        
        finalEditArray = jsonStaticCategoryArray + jsonOtherCategoryArray
        
        print(finalEditArray)
        tableviewDataArray = finalEditArray.filter { $0["VFChecked"].boolValue }
        print(tableviewDataArray)
        
        for element in finalEditArray {
            if !element["VFChecked"].boolValue {
                falseValueArray.append(element)
            }
        }

        
    }
    

    
    @IBAction func backButtontapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func finishedButtonTapped(_ sender: Any) {
        
        if databaseID != "" && ULID != "" {
            saveDatabaseEntryAfterEdit(databaseId: databaseID, ULID: ULID)
        } else {
             AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "DatabaseID and ULID cannot be nil.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
        
    }
    
    
    func saveDatabaseEntryAfterEdit(databaseId: String, ULID: String) {
        
        
        //toDatabaseInfoVC
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        let token = UserDefaults.standard.string(forKey: "token")
        let bearerToken = "Bearer \(String(describing: token!))"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        var staticCategoryArray = [Any]()
        var otherCategoryArray = [Any]()
        
        
        let finalDataArray = tableviewDataArray + falseValueArray
        
        for field in finalDataArray {
            
            if field["SFieldName"].exists() {
                
                var tempDict = [String: Any]()
                tempDict["SFID"] = field["SFID"].stringValue
                tempDict["SF_Value"] = field["SF_Value"].stringValue
                tempDict["VFChecked"] = field["VFChecked"].boolValue
    
                staticCategoryArray.append(tempDict)
                
            } else  {
                
                var tempDict = [String: Any]()
                tempDict["CategoryID"] = field["CategoryID"].stringValue
                tempDict["CategoryValue"] = field["CategoryValue"].stringValue
                tempDict["VFChecked"] = field["VFChecked"].boolValue
                
                otherCategoryArray.append(tempDict)
            }
            

        }
        
        var dataDictionary = [String: Any]()
        dataDictionary["DatabaseID"] = databaseId
        dataDictionary["UL_ID"] = ULID
        dataDictionary["UL_StaticCategoryValue"] = staticCategoryArray
        dataDictionary["UL_CategoryValue"] = otherCategoryArray
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        print(dict)
        
        
        editEntryModel.saveDatabaseEntryAfterEdit(dataDictionary: dict, header: header).done { json in
            
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            //let jsonDictionary = JSON(json)
            self.performSegue(withIdentifier: "toDatabaseInfoVC", sender: self)
            
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                print("error is ", error.localizedDescription)
        }
    }
    
}

extension EditEntryVC : UITableViewDelegate, UITableViewDataSource {
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableviewDataArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditEntryTableViewCell
        cell.categoryTextfield.tag = indexPath.row
    
        var categoryName = String()
        
        if tableviewDataArray[indexPath.row]["VFChecked"].boolValue {
            
            if tableviewDataArray[indexPath.row]["SFieldName"].exists() {
                
                categoryName = self.tableviewDataArray[indexPath.row]["SFieldName"].stringValue
                cell.categoryTextfield.text = self.tableviewDataArray[indexPath.row]["SF_Value"].stringValue
                
            } else  {
                categoryName = self.tableviewDataArray[indexPath.row]["CategoryName"].stringValue
                
                if self.tableviewDataArray[indexPath.row]["CategoryValue"].stringValue == "0" {
                    cell.categoryTextfield.text =  ""
                } else {
                    cell.categoryTextfield.text =  self.tableviewDataArray[indexPath.row]["CategoryValue"].stringValue
                }
            }
            
            cell.categoryLabel.text = categoryName
            cell.categoryTextfield.placeholder = categoryName
            
            if categoryName == "Age" || categoryName == "Hours" {
                cell.categoryTextfield.keyboardType = .numberPad
            }
        }

        
        
      
        
        return cell
    }
}







//MARK: NewDataBaseTableViewCell
class EditEntryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryTextfield: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension EditEntryVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelectedData = pickerData[row]
    }
    
    
    
    func pickUp(_ textField : UITextField) {
        
        // UIPickerView
        pickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        textField.inputView = pickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 106/255, green: 213/255, blue: 141/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NewEntryVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewEntryVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        
    }
    
    
    @objc func doneClick() {
        //txt_pickUpData.resignFirstResponder()
        
        let indexPath = IndexPath(row: textFieldTagValue, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! EditEntryTableViewCell
        
        if pickerSelectedData == "Other" {
            isPickerVisible = false
            cell.categoryTextfield.resignFirstResponder()
            cell.categoryTextfield.inputView = nil
            cell.categoryTextfield.inputAccessoryView = nil
            cell.categoryTextfield.becomeFirstResponder()
        } else {
            isPickerVisible = true
            //pickerData.removeAll()
            cell.categoryTextfield.text = pickerSelectedData
            cell.categoryTextfield.resignFirstResponder()
        }
        
        
    }
    
    @objc func cancelClick() {
        //txt_pickUpData.resignFirstResponder()
        self.view.endEditing(true)
    }
}

extension EditEntryVC : UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if tableviewDataArray[textField.tag]["SFieldName"].exists() {
            tableviewDataArray[textField.tag]["SF_Value"] = JSON(textField.text!)
        } else {
            tableviewDataArray[textField.tag]["CategoryValue"] = JSON(textField.text!)
        }
        
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let subCategoryArray = self.tableviewDataArray[textField.tag]["SubCategoryValue"].arrayValue
        if subCategoryArray.count != 0 {
            pickerData.removeAll()
            for subCategory in subCategoryArray {
                pickerData.append(subCategory.stringValue)
            }
            pickerData.append("Other")
        } else {
            pickerData.removeAll()
        }
        
        
        //Check first the pickerData has a value or not.
        if pickerData.count == 0 {
            isPickerVisible = false
        } else {
            isPickerVisible = true
        }
        
        
        //Condition for checking the picker is available or not.
        if isPickerVisible {
            textFieldTagValue = textField.tag
            pickerSelectedData = pickerData[0]
            let indexPath = IndexPath(row: textField.tag, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! EditEntryTableViewCell
            self.pickUp(cell.categoryTextfield)
        } else {
            isPickerVisible = true
        }
    }
}
