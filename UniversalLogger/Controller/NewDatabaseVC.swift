//
//  NewDatabaseVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/31/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import SSSpinnerButton


class NewDatabaseVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var newDashboardTitleView: UIView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var databaseNameTextfield: UITextField!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    
    let section = ["Select Databse Field", "Others"]
    lazy var dbFields = [String]()
    lazy var otherFields = [String]()
    lazy var staticCategoriesDictionary = [String:String]()
    lazy var staticCategories = [[String:String]]()
    lazy var anotherCategoriesDictionary = [String:Any]()
    lazy var anotherCategories = [[String:Any]]()
    lazy var createUserDBArray = JSON()
    lazy var futureUseArray = [Any]()

    let newDatabaseModel = NewDatabaseModel()
    var items = [[String]]()
    var itemData = [[JSON]]()
    
    // for Testing
    lazy var selectedRows:[IndexPath] = []
    lazy var selectedItems:[String] = [String]()
    lazy var customAlert : UIView = UIView()
    lazy var blurViewEffect : UIView = UIView()

    let newCategoryTitleLabel = UILabel()
    let addnewCategoryTextfield = UITextField()
    var flag = Bool()
    var isCategoryExist = Bool()
    var newSubcategoryNameArray = [String]()
    var checkForCategorySelection = Bool()
    var addNewCategory = String()
    
    @IBAction func unwindToNewDatabaseVC(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addnewCategoryTextfield.delegate = self
        
        print("New vC")
        flag = true
        
        blurViewEffect.frame = self.view.frame
        blurViewEffect.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 0.9)
        self.view.addSubview(blurViewEffect)
        blurViewEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // shadow line under New Dashboard Title View
        newDashboardTitleView.shadowUnderView()
        
        // Remove extra cell from tableView
        tableview.tableFooterView = UIView()
        
        // for Testing
        tableview.allowsSelection = false
        showCustomAlert()
        customAlert.isHidden = true
        
        getAllUserDataBase()
        blurViewEffect.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    
   @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        databaseNameTextfield.resignFirstResponder()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //check if the newSubcategoryNameArray has a value then change the suncategory array.
        
        if newSubcategoryNameArray.count != 0 {
            guard var otherCategorylastIndexValue = itemData[1].last else {
                return
            }
            otherCategorylastIndexValue["SubCategoryValue"] = JSON(newSubcategoryNameArray)
            var otherCategoryArray = itemData[1]
            let endIndex = otherCategoryArray.endIndex
            print(endIndex)
            otherCategoryArray[endIndex - 1] = otherCategorylastIndexValue
            itemData[1] = otherCategoryArray
            newSubcategoryNameArray.removeAll()
        }
        
        print("Item Array", itemData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // handle spinner
        if flag {
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        }
    }
    
    
    
    func getAllUserDataBase() {
        
        flag = false
        guard  let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        //let token = UserDefaults.standard.string(forKey: "token") as! String
        let bearerToken = "Bearer \(token)"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        newDatabaseModel.getULNewEntryDB(header: header).done { json in
            
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            print("json ", jsonDictionary)
            
            var staticData = jsonDictionary[globalConstants.apiUrl.kData][globalConstants.apiUrl.kUL_StaticCategory].arrayValue
            print("static Data ", staticData)
            
            for (index, _) in staticData.enumerated() {
                
                staticData[index]["VFChecked"] = false
              
                self.dbFields.append(jsonDictionary[globalConstants.apiUrl.kData][globalConstants.apiUrl.kUL_StaticCategory][index][globalConstants.apiUrl.kSFieldName].stringValue)
            }
            
            print(staticData)
            
            var otherData = jsonDictionary[globalConstants.apiUrl.kData]["UL_Category"].arrayValue
            if otherData.count != 0 {
                
                for (index,_) in otherData.enumerated() {
                    
                    otherData[index]["VFChecked"] = false
                    
                    self.otherFields.append(jsonDictionary[globalConstants.apiUrl.kData]["UL_Category"][index][globalConstants.apiUrl.kCategoryName].stringValue)
                }
            }
            
            print(otherData)
            
            //self.items = [self.dbFields, self.otherFields]
            self.itemData = [staticData, otherData]
            print(self.itemData)
            self.tableview.reloadData()

            }.catch { error in
                print("error is ", error.localizedDescription)
        }
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
 // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.itemData[section].count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NewdatabaseTableViewCell
        
        if itemData[indexPath.section][indexPath.row]["SFieldName"].exists() {
            cell.itemNameLabel.text = self.itemData[indexPath.section][indexPath.row]["SFieldName"].stringValue
        } else {
            cell.itemNameLabel.text = self.itemData[indexPath.section][indexPath.row]["CategoryName"].stringValue
        }
        
        
        if itemData[indexPath.section][indexPath.row]["VFChecked"].boolValue {
            cell.checkOrUncheck.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        } else {
            cell.checkOrUncheck.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        
        cell.checkOrUncheck.tag = indexPath.row * 1000 + indexPath.section
        cell.checkOrUncheck.addTarget(self, action: #selector(checkBoxSelection(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func checkBoxSelection(_ sender:UIButton)
    {
        
        let section = (sender as AnyObject).tag % 1000
        let row = (sender as AnyObject).tag / 1000
        let selectedIndexPath = IndexPath(row: row, section: section)
        
        if itemData[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"].boolValue {
            itemData[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"] = false
        } else {
            itemData[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"] = true
        }
        
        let indexPath = IndexPath(item: selectedIndexPath.row, section: selectedIndexPath.section)
        tableview.reloadRows(at: [indexPath], with: .none)
        
    }
    
  

    
    @IBAction func addNewFieldTapped(_ sender: UIButton) {
        
        customAlert.isHidden = false
        blurViewEffect.isHidden = false
        addnewCategoryTextfield.text = ""

    }
    

    
    func showCustomAlert() {

        print("showCustomAlert")
        
        blurViewEffect.isHidden = false
        
        self.view.addSubview(customAlert)
        customAlert.backgroundColor = UIColor.white
        customAlert.alpha = 1.0
        customAlert.layer.cornerRadius = 8.0
        customAlert.translatesAutoresizingMaskIntoConstraints = false
        customAlert.addSubview(addnewCategoryTextfield)
        
        addnewCategoryTextfield.placeholder = "new field name"
        addnewCategoryTextfield.borderStyle = .none
        addnewCategoryTextfield.autocorrectionType = UITextAutocorrectionType.no
        addnewCategoryTextfield.returnKeyType = .done
        addnewCategoryTextfield.translatesAutoresizingMaskIntoConstraints = false

        customAlert.addSubview(newCategoryTitleLabel)
        newCategoryTitleLabel.text = "New Category"
        newCategoryTitleLabel.numberOfLines = 0
        newCategoryTitleLabel.font = UIFont(name: "helvetica-bold", size: 15)
        newCategoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let lineLabel = UILabel()
        customAlert.addSubview(lineLabel)
        lineLabel.backgroundColor = UIColor.black
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let noButton:UIButton = UIButton()
        noButton.backgroundColor = UIColor.init(red: 105/255, green: 144/255, blue: 221/255, alpha: 1)
        noButton.setTitle("Cancel", for: .normal)
        noButton.addTarget(self, action:#selector(self.noButtonTapped), for: .touchUpInside)
        customAlert.addSubview(noButton)
        noButton.titleLabel?.font =  UIFont(name: "helvetica-bold", size: 15)
        noButton.clipsToBounds = true
        noButton.layer.cornerRadius = 8.0
        noButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        noButton.translatesAutoresizingMaskIntoConstraints = false
        
        let yesButton:UIButton = UIButton()
        yesButton.backgroundColor = UIColor.init(red: 117/255, green: 218/255, blue: 152/255, alpha: 1)
        yesButton.setTitle("OK", for: .normal)
        yesButton.addTarget(self, action:#selector(self.okButtonTapped), for: .touchUpInside)
        customAlert.addSubview(yesButton)
        yesButton.clipsToBounds = true
        yesButton.titleLabel?.font =  UIFont(name: "helvetica-bold", size: 15)
        yesButton.clipsToBounds = true
        yesButton.layer.cornerRadius = 8.0
        yesButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let constraints:[NSLayoutConstraint] = [
            
            customAlert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            customAlert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            customAlert.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            customAlert.widthAnchor.constraint(equalToConstant: 260),
            customAlert.heightAnchor.constraint(equalToConstant: 180),
            
            newCategoryTitleLabel.topAnchor.constraint(equalTo: customAlert.topAnchor, constant: 18.0),
            newCategoryTitleLabel.heightAnchor.constraint(equalToConstant: 44.0),
            newCategoryTitleLabel.centerXAnchor.constraint(equalTo: customAlert.centerXAnchor),
            
            addnewCategoryTextfield.topAnchor.constraint(equalTo: newCategoryTitleLabel.bottomAnchor, constant: 10.0),
            addnewCategoryTextfield.heightAnchor.constraint(equalToConstant: 30.0),
            addnewCategoryTextfield.widthAnchor.constraint(equalToConstant: 200.0),
            addnewCategoryTextfield.centerXAnchor.constraint(equalTo: customAlert.centerXAnchor),
            
            lineLabel.topAnchor.constraint(equalTo: addnewCategoryTextfield.bottomAnchor, constant: -2),
            lineLabel.leadingAnchor.constraint(equalTo: addnewCategoryTextfield.leadingAnchor),
            lineLabel.trailingAnchor.constraint(equalTo: addnewCategoryTextfield.trailingAnchor),
            lineLabel.heightAnchor.constraint(equalToConstant: 1),
        
            noButton.leadingAnchor.constraint(equalTo: customAlert.leadingAnchor, constant: 0),
            noButton.bottomAnchor.constraint(equalTo: customAlert.bottomAnchor, constant: 0.0),
            noButton.widthAnchor.constraint(equalTo: customAlert.widthAnchor, multiplier: 0.5, constant: 0.0),
            noButton.heightAnchor.constraint(equalToConstant: 44.0),
            
            yesButton.trailingAnchor.constraint(equalTo: customAlert.trailingAnchor, constant: 0),
            yesButton.bottomAnchor.constraint(equalTo: customAlert.bottomAnchor, constant: 0.0),
            yesButton.widthAnchor.constraint(equalTo: customAlert.widthAnchor, multiplier: 0.5, constant: 0.0),
            yesButton.heightAnchor.constraint(equalToConstant: 44.0)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    

    
    @IBAction func createButtonTapped(_ sender: UIButton) {

        let dataBaseName = databaseNameTextfield.text?.trimmingCharacters(in: .whitespaces)
        
        print("staticCategories array ", staticCategories)
        print("anotherCategories array ", anotherCategories)
        print("other array ", items)
        print("other array ", selectedItems)
        
        staticCategories.removeAll()
        anotherCategories.removeAll()
        
        if dataBaseName?.count == 0 {
             AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: globalConstants.validation.kEmptyDBAlert, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        }  else {
            
            if itemData[0].count != 0  {
                for element in itemData[0] {
                    if element["VFChecked"].boolValue {
                        var temp = [String: String]()
                        temp["SFieldName"] = element["SFieldName"].stringValue
                        
                        staticCategories.append(temp)
                    }
                }
            }
            
           
            if itemData[1].count != 0  {
                for element in itemData[1] {
                    
                    print(element)
                    
                    if element["VFChecked"].boolValue {
                        
                        var temp = [String: Any]()
                        temp["CategoryName"] = element["CategoryName"].stringValue
                        temp["EnableField"] = element["VFChecked"].boolValue
                        temp["SubCategoryValue"] = element["SubCategoryValue"].arrayObject
                        anotherCategories.append(temp)
                    }
                }
            }
            
            
            if (staticCategories.count + anotherCategories.count) == 0 {
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: globalConstants.validation.kSelectOneCategoryAlert, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            } else {
                // handle spinner
                blurView.isHidden = false
                spinner.isHidden = false
                spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
                
                print(staticCategories)
                print(anotherCategories)
                
                var universalLoggerDB = [String:Any]()
                universalLoggerDB[globalConstants.apiUrl.kDatabaseName] = dataBaseName
                
                var dataDictionary = [String:Any]()
                dataDictionary[globalConstants.apiUrl.kULRDB] = universalLoggerDB
                dataDictionary[globalConstants.apiUrl.kULStaticCategory] = staticCategories
                dataDictionary[globalConstants.apiUrl.kUL_Category] = anotherCategories
                
                var createUserDatabaseDict = [String:Any]()
                createUserDatabaseDict[globalConstants.apiUrl.kData] = dataDictionary
                
                print("dataDictionary ", createUserDatabaseDict)
                print("dataDictJson",JSON(createUserDatabaseDict))
                
                self.createUserDatabase(dataDictionary: createUserDatabaseDict)
            }
            
        }
 
    }
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 27 July 2018
     * Textfield delegates to handle the keyboard
     **********************************************
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
      if(textField == databaseNameTextfield)
        {
            databaseNameTextfield.resignFirstResponder()
        }
        else if (textField == addnewCategoryTextfield)
        {
            addnewCategoryTextfield.resignFirstResponder()
            
        }
        return true
    }
    
    
    func createUserDatabase(dataDictionary:[String:Any]){
        
        // stop spinner
        self.spinner.stopAnimate(complete: {
            self.blurView.isHidden = true
            self.spinner.isHidden = true
        })
        
        
        guard  let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        //let token = UserDefaults.standard.string(forKey: "token") as! String
        
        let bearerToken = "Bearer \(token)"
        
        print("token ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        newDatabaseModel.createUserDatabase(dataDictionary: dataDictionary, header: header).done { json in
            
            let jsonDictionary = JSON(json)
            
            print("createUserDatabase response ", jsonDictionary)
            
              let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                
                self.createUserDBArray = jsonDictionary["data"]
                
                let responseCode = jsonDictionary[globalConstants.apiUrl.kResponse]["ResponseCode"].intValue
                
                if responseCode == 200 {
                    
                    self.performSegue(withIdentifier: globalConstants.stroryboard.stroryboardSegueId.kNewEntryVC, sender: nil)

                } else {
                    
                    let errorMessage = jsonDictionary[globalConstants.apiUrl.kResponse]["ResponseMessage"].stringValue
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: errorMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
  
                }

                
            } else {
                
                // Do something here..
                // If status is false
                
            }
            
            }.catch { (error) in
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
    }
    
    
        
    @objc func noButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        
    }
    
    
    
    @objc func okButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()

        customAlert.isHidden = true
        blurViewEffect.isHidden = true

        addNewCategory = addnewCategoryTextfield.text ?? ""
        addNewCategory = addNewCategory.trimmingCharacters(in: .whitespaces)
        
        if (addNewCategory.isEmpty) {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: globalConstants.validation.kBlankCategory, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        } else {
        
            //Check the category is already present in the other category array or not.
            print("item data ====\(itemData)");
            var otherCategoryArray = itemData[1]
            
            if itemData[1].count == 0 {
                
                isCategoryExist = true

            } else{
            for element in otherCategoryArray {
                
                if element["CategoryName"].stringValue.lowercased() == addNewCategory.lowercased() {
                   //Showing Alert if exist.
                    isCategoryExist = false
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: "Category alreay exist, try with new name.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                    break
                } else {
                    isCategoryExist = true
                }
             }
            
            }
            
            
            //Newly Added category is not exist in the array than add the value in the array.
            if isCategoryExist {
                
                var tempOtherCategory = [String: Any]()
                tempOtherCategory["SubCategoryValue"] = []
                tempOtherCategory["CategoryName"] = addNewCategory
                tempOtherCategory["VFChecked"] = false
                
                //Now Appending the new category data in the other category array.
                let tempOtherCategoryInJson = JSON(tempOtherCategory)
                otherCategoryArray.append(tempOtherCategoryInJson)
                itemData[1] = otherCategoryArray
                tableview.reloadData()

                
                print(otherCategoryArray)
                //Show Alert for adding the subcategory in the newly created field.
                let alertcontroller = UIAlertController(title: "Universal Logger", message: "Do you want to make options for \(addNewCategory)?", preferredStyle: .alert)
                
                let cancelAction  = UIAlertAction(title: "No", style: .default) { _ in
                }
                
                let okAction  = UIAlertAction(title: "Yes", style: .default) { _ in
                    self.performSegue(withIdentifier: "toAddSubCategoryVC", sender: nil)
                }
                alertcontroller.addAction(cancelAction)
                alertcontroller.addAction(okAction)
                self.present(alertcontroller, animated: true, completion: nil)
                
                
            }
        }
    }
    
    @IBAction func unwindToNewEntry(segue:UIStoryboardSegue) {
        
        // Do nothing here
        // its use for exit from another VC
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == globalConstants.stroryboard.stroryboardSegueId.kNewEntryVC {
            
            let newEntryVC = segue.destination as! NewEntryVC
            newEntryVC.createUserDBArray = createUserDBArray
            
        } else if segue.identifier == "toAddSubCategoryVC" {
        
            let addSubCategoryVC = segue.destination as! AddSubCategoryListVC
            
            let endIndex = self.itemData[1].endIndex
            
            let lastArrayValue = self.itemData[1][endIndex - 1]["CategoryName"].stringValue
            addSubCategoryVC.categoryName = lastArrayValue
            
        }
    }

}


//MARK: NewDataBaseTableViewCell 
class NewdatabaseTableViewCell: UITableViewCell  {
    
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var checkOrUncheck: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
