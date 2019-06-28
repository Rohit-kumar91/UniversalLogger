//
//  NewEntryVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/1/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton
import SearchTextField

class NewEntryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var dbNameLabel: UILabel!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    
    var createUserDBArray = JSON()
    var staticCategoryArray = [JSON]()
    var textfieldTagValue = 0
    
    lazy var categoryArray = [JSON]()
    let newEntryModel = NewEntryModel()
    var flagBool = Bool()
    var array = [String]()
    
    var pickerView : UIPickerView!
    var pickerData =  [String]()
    var pickerSelectedData = String()
    var textFieldTagValue = Int()
    var isPickerVisible = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        isPickerVisible = true
        print("createUserDBArray ", createUserDBArray)
        
        dbNameLabel.text = createUserDBArray["ULRDB"]["DatabaseName"].stringValue
        staticCategoryArray = createUserDBArray["ULStaticCategory"].arrayValue
        let dynamicCategoryArray = createUserDBArray["UL_Category"].arrayValue
        
        
        print(staticCategoryArray)
        print(dynamicCategoryArray)
        categoryArray = staticCategoryArray + dynamicCategoryArray
        print("categoryArray ", categoryArray)


        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewEntryTableViewCell
        
        var categoryName = String()
        if indexPath.row < staticCategoryArray.count {
            categoryName = categoryArray[indexPath.row]["SFieldName"].stringValue
        } else {
            categoryName = categoryArray[indexPath.row]["CategoryName"].stringValue
        }
        
        cell.categoryLabel.text = categoryName
        cell.categoryTextfield.placeholder = categoryName
        cell.categoryTextfield.tag = indexPath.row
        

//
//        cell.categoryTextfield.filterStrings(tempSubcategoryArray)
//        cell.categoryTextfield.inlineMode = true
        
        if categoryName == "Age" || categoryName == "Hours" {
            cell.categoryTextfield.keyboardType = .numberPad
        }

        return cell
    }
    
   
    
    @IBAction func finishTapped(_ sender: UIButton) {
        
        self.addDataIntoDB()
    }
    
    
    func addDataIntoDB()  {

        var jsonCategoryArray = [Any]()
        var categoryData = [String:String]()
        var anotherCategoryData = [String: String]()
        var jsonAnotherCategoryArray = [Any]()

        
        print("Category Array", categoryArray)
        
            for (index, _) in categoryArray.enumerated() {
                
                print(index)
                
                let indexPath = IndexPath(row: index, section: 0)
//                guard let cell = tableView.cellForRow(at: indexPath) as? NewEntryTableViewCell else {
//
//                    return
//                }

               let cell = tableView.cellForRow(at: indexPath) as? NewEntryTableViewCell

                
                if let text = cell?.categoryTextfield.text, !text.isEmpty {

                    
                    if index < staticCategoryArray.count {
                        
                        categoryData["SF_Value"] = text
                        
                        let placeholderValue = cell?.categoryTextfield.placeholder!
                        
                        let sFieldName = categoryArray[index]["SFieldName"].stringValue
                        
                        if placeholderValue == sFieldName {
                            
                            categoryData["SFID"] = categoryArray[index]["SFID"].stringValue
                        }
                        jsonCategoryArray.append(categoryData)

                        
                    } else {
                        
                        anotherCategoryData["CategoryValue"] = text
                        
                        let placeholderValue = cell?.categoryTextfield.placeholder!
                        
                        let anotherCategoryFieldName = categoryArray[index]["CategoryName"].stringValue
                        
                        if placeholderValue == anotherCategoryFieldName {
                            
                            anotherCategoryData["CategoryID"] = categoryArray[index]["CategoryID"].stringValue
                        }
                        
                        jsonAnotherCategoryArray.append(anotherCategoryData)
  
                    }
                }
            }
        
        let totalCounter = jsonAnotherCategoryArray.count + jsonCategoryArray.count

        if totalCounter  == categoryArray.count {
                
                var uLRDBDictionary = [String : Any]()
                uLRDBDictionary["DatabaseID"] = createUserDBArray["ULRDB"]["DatabaseID"].intValue
                uLRDBDictionary["User_ID"] = createUserDBArray["ULRDB"]["User_ID"].intValue
                
                var dataDictionary = [String : Any]()
                dataDictionary["ULRDB"] = uLRDBDictionary
                dataDictionary["UL_StaticCategoryValue"] = jsonCategoryArray
                dataDictionary["UL_CategoryValue"] = jsonAnotherCategoryArray
                
                var saveEntryDatabaseDictionary = [String : Any]()
                saveEntryDatabaseDictionary["data"] = dataDictionary
                
                print(saveEntryDatabaseDictionary)
                self.SaveEntryDatabase(dataDictionary: saveEntryDatabaseDictionary)
               

                
            } else {
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "All fields are mandatory.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            print("jsonCategoryArray ", jsonCategoryArray)
        
        }

    
     func SaveEntryDatabase(dataDictionary:[String:Any]) {
        
        // handle spinner
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
    
       // let token = UserDefaults.standard.string(forKey: "token") as! String
        
        let bearerToken = "Bearer \(token)"
        
        print("token ", bearerToken)
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        print("header",header)
        
        newEntryModel.saveEntryDatabase(dataDictionary: dataDictionary, header: header).done { json in
            
            let jsonDictionary = JSON(json)
            
            print("json dictionary ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                // stop spinner
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                                
                let responseCode = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseCode].intValue
                
                if responseCode == 200 {
                 
                    
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: "Do you want to add any more entries?", actionTitles: ["YES", "NO"], actions: [
                        {()->() in
                            
                            for (index, _) in self.categoryArray.enumerated() {
                                
                                let indexPath = IndexPath(row: index, section: 0)
                                guard let cell = self.tableView.cellForRow(at: indexPath) as? NewEntryTableViewCell else{
                                    return
                                }
                                
                                cell.categoryTextfield.text = ""
                                
                            }
                            
//                            self.addDataIntoDB()
                        },
                        {()->() in
                            
                            self.performSegue(withIdentifier: "unwindToDashboard", sender: self)

                        }
                        
                        ]
                    )
                    
                } else {
                    
                    
                    // stop spinner
                    self.spinner.stopAnimate(complete: {
                        self.blurView.isHidden = true
                        self.spinner.isHidden = true
                    })
                    
                    let errorMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: errorMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                    
                }
                
            } else {
                
                // Do something here..
                // If status is false
                
                // stop spinner
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                let errorMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: errorMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }

            
            }.catch { error  in
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
        
    }
  
    
    private func showAlertWith(alertTitle: String, alertMessage: String, isShowOKButton: Bool , isShowNoButton:Bool ) {

        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if isShowOKButton {

            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in

                for (index, _) in self.categoryArray.enumerated() {

                let indexPath = IndexPath(row: index, section: 0)
                    guard let cell = self.tableView.cellForRow(at: indexPath) as? NewEntryTableViewCell else{

                    return
                }

                    cell.categoryTextfield.text = ""

                }

                self.addDataIntoDB()

            }))
        }

        if isShowNoButton {

            alertController.addAction(UIAlertAction(title: "NO", style: .default, handler: { _ in
                print("NO")
            }))
        }

        self.present(alertController, animated: true, completion: nil)

    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}





//MARK: NewDataBaseTableViewCell
class NewEntryTableViewCell: UITableViewCell  {
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryTextfield: SearchTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}



extension NewEntryVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let subCategoryArray = categoryArray[textField.tag]["SubCategoryValue"].arrayValue
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
            
            if pickerSelectedData == "Other" {
                pickerSelectedData = pickerData[0]
                isPickerVisible = false
            } else {
                isPickerVisible = true
            }
            
        }
        
        
        //Condition for checking the picker is available or not.
        if isPickerVisible {
            textFieldTagValue = textField.tag
            pickerSelectedData = pickerData[0]
            let indexPath = IndexPath(row: textField.tag, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! NewEntryTableViewCell
            self.pickUp(cell.categoryTextfield)
        } else {
            isPickerVisible = true
        }
    }
}

extension NewEntryVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
        let cell = tableView.cellForRow(at: indexPath) as! NewEntryTableViewCell
        
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
