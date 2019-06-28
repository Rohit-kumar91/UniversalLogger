//
//  EditDatabaseInfoVC.swift
//  UniversalLogger
//
//  Created by Puspank Kumar on 27/10/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SSSpinnerButton
import SwiftyJSON
import SearchTextField


class DatabaseEntryField: UITableViewCell {
    
    @IBOutlet weak var checkOrUncheck: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
}

class EditDatabaseInfoVC: UIViewController {
    
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var spinner: SSSpinnerButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataBaseEntry: [JSON]? = []
    lazy var blurViewEffect : UIView = UIView()
    lazy var customAlert : UIView = UIView()
    let newCategoryTitleLabel = UILabel()
    let addnewCategoryTextfield = SearchTextField()
    let newDatabaseModel = NewDatabaseModel()
    
    let editDatabaseInfoModel = EditDatabaseInfoVCModel()
    let section = ["Static Databse Field", "Others Database field"]
    
    lazy var dbFields = [JSON]()
    lazy var otherFields = [JSON]()
    
    var items = [[JSON]]()
    var searchableItemArray = [JSON]()
    var searchableFieldItems = [String]()
    var dbName = String()
    var searchedFieldName = String()
    var isSearchableAdd = false
    var isNewValueAdded = Bool()
    var newItemToBeAdded = JSON()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        blurViewEffect.frame = self.view.frame
        blurViewEffect.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 0.9)
        self.view.addSubview(blurViewEffect)
        blurViewEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurViewEffect.isHidden = true


        showCustomAlert()
        customAlert.isHidden = true
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isSearchableAdd {
            //This condition is true when the user search the field from the searchable field screen.
            
            print(searchedFieldName)
            print(searchableItemArray)
            print(newItemToBeAdded)
            
            if isNewValueAdded {
                isNewValueAdded = false
                searchableItemArray.append(newItemToBeAdded)
            }
            
            print(searchableItemArray)
            
            
            for var element in searchableItemArray {
                print("Element",element)
                
                if element["SFieldName"].exists() {
                    
                    if element["SFieldName"].stringValue == searchedFieldName {
                        
                        print("Items",items[0])
                        
                        for items in items[0] {
                            if items["SFieldName"].stringValue == element["SFieldName"].stringValue{
                                
                                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "Item already present.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                                
                                return
                                
                            }
                        }
                        
                        print(element)
                        element["VFChecked"] = true
                        
                        // self.dbFields.append(element)
                        // print("Items===", self.items)
                        self.items[0].append(element)
                        self.tableView.reloadData()
                        
                        
                    }
                } else {
                    
                    if element["CategoryName"].stringValue == searchedFieldName {
                        
                        print(element)
                        for items in items[1] {
                            print(items)
                            if items["CategoryName"].stringValue == element["CategoryName"].stringValue {
                                
                                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "Item already present.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                                
                                return
                                
                            }
                        }
                        
                        
                        print("dfjhdfjdfghdgdfjjdfg",element)
                        element["VFChecked"] = true
                        print("retertrete",element)
                        
                        self.otherFields.append(element)
                        
                        self.items[1].append(element)
                        self.tableView.reloadData()
                    }
                }
            }
            
        } else {
            
            if let databaseID = dataBaseEntry?[0]["DatabaseID"].stringValue, let ULID = dataBaseEntry?[0]["UL_ID"].stringValue {
                getAllUserDataBaseEntry(databaseId: databaseID, ULID: ULID)
            }
        }
        
    }
    
    @IBAction func unwindToEntryDatabaseInfoVC(segue:UIStoryboardSegue) { }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        
        let section = (sender as AnyObject).tag % 1000
        let row = (sender as AnyObject).tag / 1000
        let selectedIndexPath = IndexPath(row: row, section: section)
        
        if items[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"].boolValue {
            items[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"] = false
        } else {
            items[selectedIndexPath.section][selectedIndexPath.row]["VFChecked"] = true
        }
        
       
        
        let indexPath = IndexPath(item: selectedIndexPath.row, section: selectedIndexPath.section)
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    
    @IBAction func addNewFieldButtonTapped(_ sender: Any) {
        //customAlert.isHidden = false
        //blurViewEffect.isHidden = false
        //addnewCategoryTextfield.text = ""
        
        self.performSegue(withIdentifier: "searchField", sender: nil)
    }
    
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showEditDatabaseEntry", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditDatabaseEntry" {
            
            if let vc = segue.destination as? EditEntryVC {
                vc.editValueJson = items
                vc.dbName = dbName
                
                if let databaseId = dataBaseEntry?[0]["DatabaseID"].stringValue {
                    vc.databaseID = databaseId
                }
                
                if let UL_ID = dataBaseEntry?[0]["UL_ID"].stringValue {
                    vc.ULID = UL_ID
                }
            }
            
        } else if segue.identifier == "searchField" {
            if let vc = segue.destination as? SearchFieldsVC {
                vc.searchableFieldArray = searchableFieldItems
            }
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension EditDatabaseInfoVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
      
        
        return self.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DatabaseEntryField
        
        
        if self.items[indexPath.section][indexPath.row]["SFieldName"].exists() {
            cell.itemNameLabel.text = self.items[indexPath.section][indexPath.row]["SFieldName"].stringValue
        } else {
            cell.itemNameLabel.text = self.items[indexPath.section][indexPath.row]["CategoryName"].stringValue
        }
        
        
        if self.items[indexPath.section][indexPath.row]["VFChecked"].boolValue {
            cell.checkOrUncheck.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        } else {
            cell.checkOrUncheck.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        
        cell.checkOrUncheck.tag = indexPath.row * 1000 + indexPath.section

        
        return cell
    }
}



extension EditDatabaseInfoVC {
    
    
    func showCustomAlert() {
        
        print("showCustomAlert")
        
//        blurViewEffect.isHidden = false
        
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
    
    
    @objc func noButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        
    }
    
    
    @objc func okButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        
 
    }
    
    /*
    func createDatabaseEntryForEdit(databaseId: String, ULID: String) {
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        let token = UserDefaults.standard.string(forKey: "token")
        let bearerToken = "Bearer \(String(describing: token!))"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        var jsonStaticCategoryArray = [Any]()
        var jsonOtherCategoryArray = [Any]()
        
        print(items[0])
        for saticCategory in items[0] {
            var tempDict = [String: String]()
            tempDict["SFID"] = saticCategory["SFID"].stringValue
            tempDict["SFieldName"] = saticCategory["SFieldName"].stringValue
            tempDict["VFChecked"] = saticCategory["VFChecked"].stringValue
            
            jsonStaticCategoryArray.append(tempDict)
        }
        
        
        print(items[1])
        for otherCategory in items[1] {
            var tempDict = [String: String]()
            tempDict["CategoryID"] = otherCategory["CategoryID"].stringValue
            tempDict["CategoryName"] = otherCategory["CategoryName"].stringValue
            tempDict["VFChecked"] = otherCategory["VFChecked"].stringValue
            
            jsonOtherCategoryArray.append(tempDict)
        }
        
        
        
        var dataDictionary = [String: Any]()
        dataDictionary["DatabaseID"] = databaseId
        dataDictionary["UL_ID"] = ULID
        dataDictionary["UL_StaticCategoryValue"] = jsonStaticCategoryArray
        dataDictionary["UL_CategoryValue"] = jsonOtherCategoryArray
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        print(dict)
        
        
        editDatabaseInfoModel.createDatabaseEntryAfterEdit(dataDictionary: dict, header: header).done { json in
            
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            print("json ", jsonDictionary)
            
            
            
            
            self.performSegue(withIdentifier: "showEditDatabaseEntry", sender: jsonDictionary)
            
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                print("error is ", error.localizedDescription)
        }
        
        
    }
    */
    
    func getAllUserDataBaseEntry(databaseId: String, ULID: String) {
        
        // handle spinner
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        
        let token = UserDefaults.standard.string(forKey: "token")
        let bearerToken = "Bearer \(String(describing: token!))"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        var dataDictionary = [String: Any]()
        dataDictionary["DatabaseID"] = databaseId
        dataDictionary["UL_ID"] = ULID
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        editDatabaseInfoModel.getDatabaseEntryForEdit(dataDictionary: dict, header: header).done { json in
            
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            print("json ", jsonDictionary)
            
            self.items = [jsonDictionary["data"]["UL_StaticCategoryValue"].arrayValue, jsonDictionary["data"]["UL_CategoryValue"].arrayValue]
            
            
            print(self.items)
            
            self.searchableItemArray = jsonDictionary["data"]["UL_StaticCategory"].arrayValue + jsonDictionary["data"]["UL_Category"].arrayValue

            
            print(self.searchableItemArray)
            self.tableView.reloadData()
            self.searchableFieldItems.removeAll()
            for element in self.searchableItemArray {

                if element["SFieldName"].exists() {
                    self.searchableFieldItems.append(element["SFieldName"].stringValue)
                } else {
                    //cell.itemNameLabel.text = self.items[indexPath.section][indexPath.row]["CategoryName"].stringValue
                    self.searchableFieldItems.append(element["CategoryName"].stringValue)
                }
            }

            
            
            //For Searchable alertbox.
//            var searchableFieldItems = [SearchTextFieldItem]()
//            for element in self.searchableItemArray {
//
//                if element["SFieldName"].exists() {
//                    searchableFieldItems.append(SearchTextFieldItem(title: element["SFieldName"].stringValue))
//                } else {
//                    //cell.itemNameLabel.text = self.items[indexPath.section][indexPath.row]["CategoryName"].stringValue
//                    searchableFieldItems.append(SearchTextFieldItem(title: element["CategoryName"].stringValue))
//                }
//            }
//
//            self.addnewCategoryTextfield.filterItems(searchableFieldItems)
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                print("error is ", error.localizedDescription)
        }
        
        
        

        
        
     /*   newDatabaseModel.getULNewEntryDB(header: header).done { json in
            
            let jsonDictionary = JSON(json)
            print("json ", jsonDictionary)
            let staticData = jsonDictionary[globalConstants.apiUrl.kData][globalConstants.apiUrl.kUL_StaticCategory].arrayValue
            print("static Data ", staticData)
            let otherData = jsonDictionary[globalConstants.apiUrl.kData]["UL_Category"].arrayValue
            
            self.searchableItemArray = staticData + otherData
            
            print(self.searchableItemArray)
            var searchableFieldItems = [SearchTextFieldItem]()
            
            for element in self.searchableItemArray {
                
                if element["SFieldName"].exists() {
                    searchableFieldItems.append(SearchTextFieldItem(title: element["SFieldName"].stringValue))
                } else {
                    //cell.itemNameLabel.text = self.items[indexPath.section][indexPath.row]["CategoryName"].stringValue
                    searchableFieldItems.append(SearchTextFieldItem(title: element["CategoryName"].stringValue))
                }
                
            }
            
           self.addnewCategoryTextfield.filterItems(searchableFieldItems)
            
            
            }.catch { error in
                
                print("error is ", error.localizedDescription)
        } */
        
    }
}
