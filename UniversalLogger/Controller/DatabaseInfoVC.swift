//
//  DatabaseInfoVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/10/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//  

import UIKit
import SwiftyJSON
import SSSpinnerButton

struct DatabaseEnteriesData {
    var opened = Bool()
    
    var staticField1 = String()
    var dynamicField1 = String()
    
    var staticField2 = String()
    var dynamicField2 = String()
    
    var sectionData : [JSON]?
}



class DatabaseInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var dbNameView: UIView!
    @IBOutlet var dbNamelabel: UILabel!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    lazy var dataDictionary = [String: Any]()
    lazy var surgeryDictionary = [String: Any]()
    fileprivate var index = Int()
    
    let databaseInfoModel = DatabaseInfoModel()
    lazy var categoryJson = JSON()
    
    lazy var allEntriesRelation = [[JSON]]()
    lazy var allEntriesRelationData = [DatabaseEnteriesData]()
    lazy var allCategories = Int()
    var flag = Bool()
    
    lazy var databaseID = Int()
    lazy var sp_UserId = Int()
    
    var isSupervisiorIndex = Int()
    var twoRowsOnly = Bool()
    var singleRowOnly = Bool()
    var isSuperVisior = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flag = true
        index = 0
        print("databaseID ", databaseID)
        
        // shadow line under dbNameView
        dbNameView.shadowUnderView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
//        dataDictionary["surgery"] = surgeryDictionary
//        surgeryDictionary["identifier"] = "203";
//        surgeryDictionary["dob"] = "10-May-2012"
//        surgeryDictionary ["supervisior"] = "subodh"
//        surgeryDictionary["age"] = "32"
//        surgeryDictionary["procedure"] = "Abdominoplasty"
//        surgeryDictionary["hours"] = "2"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorColor = UIColor.clear

        // Do any additional setup after loading the view.
        if isSupervisiorIndex == 1 {
           addButtonOutlet.isHidden = true
        } else {
            addButtonOutlet.isHidden = false
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
//        pageNumber = 1
//        print("page number ", pageNumber)
        
        var pageInfoDictionary = [String: Any]()
        pageInfoDictionary["pageNumber"] = 1
        pageInfoDictionary["pageSize"] = 10
        pageInfoDictionary["TotalCount"] = "0"
        pageInfoDictionary["CurrentPage"] = "1"
        pageInfoDictionary["TotalPages"] = "0"
        pageInfoDictionary["PreviousPage"] = true
        pageInfoDictionary["NextPage"] = true
        pageInfoDictionary["QuerySearch"] = ""
        
        
        var ULRDB = [String:Any]()
        if sp_UserId == 0 {
            
            ULRDB["DatabaseID"] = databaseID

        }else{
            
            ULRDB["SP_User_ID"] = sp_UserId
            ULRDB["DatabaseID"] = databaseID
        }
        
        var dataDictionary = [String:Any]()
        dataDictionary["UL_RDB"] = ULRDB
        dataDictionary["PagingInfo"] = pageInfoDictionary
        
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        print("user datadictionary ", dict)
        self.getAllUserDataBase(dataDictionary: dict)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToDatabaseInfoVC(segue:UIStoryboardSegue) { }
    
    
    func getAllUserDataBase(dataDictionary:[String:Any]) {
        
        // self.dbArray.removeAll()
        
//        blurView.isHidden = false
//        spinner.isHidden = false
//        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            
            return
        }
        
        let bearerToken = "Bearer \(token)"
        
        print("token is ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        databaseInfoModel.getUserDatabaseAllEntries(dataDictionary: dataDictionary, header: header, userApi: sp_UserId ).done { json-> Void in
            
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            
            print(jsonDictionary)
            
            self.allEntriesRelation.removeAll()
            self.allEntriesRelationData.removeAll()
            
            
            for elementData in jsonDictionary["data"]["ULAllEntriesRelation"].arrayValue {
                var categoryArray = [JSON]()
                
                //Getting UL_ID and DatabaseID
                
                for elementStaticInnerdata in elementData["UL_StaticCategoryValue"].arrayValue {
                    categoryArray.append(elementStaticInnerdata)
                }
                
                for elementCategoryInnerdata in elementData["UL_CategoryValue"].arrayValue {
                    categoryArray.append(elementCategoryInnerdata)
                }
                
                self.allEntriesRelation.append(categoryArray)
            }
            
            print(self.allEntriesRelation)
            
            //Creating the final array for collapsing tableview.
           for var element in self.allEntriesRelation {
            
            print("Element of the array",element, element.count)
            
                if element.count > 2 {
                    let firstIndexValue = element[0]
                    let secondIndexValue = element[1]
                    
                    element.remove(at: 0)
                    element.remove(at: 0)
                    
                    print("fistIndex", firstIndexValue)
                    print("SecondIndex",secondIndexValue)
                    
                    
                    var firstStaticValue = String()
                    var firstDynamicValue = String()
                    var secondStaticValue = String()
                    var secondDynamicValue = String()
                    
                    if firstIndexValue["SFieldName"].exists() {
                        firstStaticValue = firstIndexValue["SFieldName"].stringValue
                        firstDynamicValue = firstIndexValue["SF_Value"].stringValue
                    } else {
                        firstStaticValue = firstIndexValue["CategoryName"].stringValue
                        firstDynamicValue = firstIndexValue["CategoryValue"].stringValue
                    }
                    
                    
                    if secondIndexValue["SFieldName"].exists() {
                        secondStaticValue = secondIndexValue["SFieldName"].stringValue
                        secondDynamicValue = secondIndexValue["SF_Value"].stringValue
                    } else {
                        secondStaticValue = secondIndexValue["CategoryName"].stringValue
                        secondDynamicValue = secondIndexValue["CategoryValue"].stringValue
                    }
                    
                    
                    self.allEntriesRelationData.append(DatabaseEnteriesData(opened: false,
                                                                             staticField1: firstStaticValue,
                                                                             dynamicField1: firstDynamicValue,
                                                                             staticField2: secondStaticValue,
                                                                             dynamicField2: secondDynamicValue,
                                                                             sectionData: element))
                    
                } else {
                    
                    if element.count == 1 {
                        let firstIndexValue = element[0]
                        
                        var firstStaticValue = String()
                        var firstDynamicValue = String()
                        
                        if firstIndexValue["SFieldName"].exists() {
                            firstStaticValue = firstIndexValue["SFieldName"].stringValue
                            firstDynamicValue = firstIndexValue["SF_Value"].stringValue
                        } else {
                            firstStaticValue = firstIndexValue["CategoryName"].stringValue
                            firstDynamicValue = firstIndexValue["CategoryValue"].stringValue
                        }
                        
                        self.allEntriesRelationData.append(DatabaseEnteriesData(opened: false,
                                                                                 staticField1: firstStaticValue,
                                                                                 dynamicField1: firstDynamicValue,
                                                                                 staticField2: "",
                                                                                 dynamicField2: "",
                                                                                 sectionData: []))
                    } else {
                        
                        if element.count != 0 {
                            let firstIndexValue = element[0]
                            let secondIndexValue = element[1]
                            
                            print("First", firstIndexValue)
                            print("Second", secondIndexValue)
                            
                            var firstStaticValue = String()
                            var firstDynamicValue = String()
                            var secondStaticValue = String()
                            var secondDynamicValue = String()
                            
                            if firstIndexValue["SFieldName"].exists() {
                                firstStaticValue = firstIndexValue["SFieldName"].stringValue
                                firstDynamicValue = firstIndexValue["SF_Value"].stringValue
                            } else {
                                firstStaticValue = firstIndexValue["CategoryName"].stringValue
                                firstDynamicValue = firstIndexValue["CategoryValue"].stringValue
                            }
                            
                            if secondIndexValue["SFieldName"].exists() {
                                secondStaticValue = secondIndexValue["SFieldName"].stringValue
                                secondDynamicValue = secondIndexValue["SF_Value"].stringValue
                            } else {
                                secondStaticValue = secondIndexValue["CategoryName"].stringValue
                                secondDynamicValue = secondIndexValue["CategoryValue"].stringValue
                            }
                            
                            self.allEntriesRelationData.append(DatabaseEnteriesData(opened: false,
                                                                                    staticField1: firstStaticValue,
                                                                                    dynamicField1: firstDynamicValue,
                                                                                    staticField2: secondStaticValue,
                                                                                    dynamicField2: secondDynamicValue,
                                                                                    sectionData: []))
                            
                            
                            
                            print("All Enteries", self.allEntriesRelationData)
                        }
                       
                    }
                }
            }
            
            print("categoryJson ", self.categoryJson)
            print("all enteries ", self.allEntriesRelation)
            print(self.allEntriesRelationData)
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                self.tableView.reloadData()
                
                if self.flag {
                    self.flag = false
                    self.dbNamelabel.text = jsonDictionary[globalConstants.apiUrl.kData]["ULAllEntriesRelation"][0]["DatabaseName"].stringValue

                }
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            }.catch { error in
                
                // stop spinner
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
        }
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 0
        } else {
            return 20
        }
    }
    
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allEntriesRelationData.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allEntriesRelationData[section].opened == true {
            
            if allEntriesRelationData[section].sectionData!.count == 0 {
                if allEntriesRelationData[section].staticField2 == "" {
                    return 1
                } else {
                    return 2
                }
            } else {
               
                return allEntriesRelationData[section].sectionData!.count + 3
            }
        } else {
            
            print("All Entry relation",allEntriesRelationData)
            print("First Section",allEntriesRelationData[section])
            print("SF1 Section",allEntriesRelationData[section].staticField1)
            print("SF2 Section",allEntriesRelationData[section].staticField2)
            print("Section Data Count", allEntriesRelationData[section].sectionData?.count)
            print("Section is -----\(section)")
            
            if allEntriesRelationData[section].sectionData?.count == 0 {
                
                if allEntriesRelationData[section].staticField2 == "" {
                    
                    if isSupervisiorIndex == 1 {
                        singleRowOnly = true
                        return 1 //1
                    } else {
                        singleRowOnly = true
                        print("Single Rows")
                        return 2 //1
                    }
                    
                   
                    
                } else {
                    
                    if isSupervisiorIndex == 1 {
                        twoRowsOnly = true
                        return 2 //2
                    } else {
                        
                        print("Two Rows")
                        twoRowsOnly = true
                        //singleRowOnly = false
                        return 3 //2
                        
                        
                    }
                    
                    
                }
            } else {
                
                print("Multiple Rows")
                singleRowOnly = false
                twoRowsOnly = false
                return 3
            }
        }
    }
    
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DatabaseInfoTableViewCell

        cell.editButtonOutlet.tag = indexPath.section
        cell.deleteButtonOutlet.tag = indexPath.section
        
        if indexPath.row == 0 {
            
            cell.dynamicIdentifierLabel.isHidden = false
            cell.staticIdentifierLabel.text = allEntriesRelationData[indexPath.section].staticField1
            cell.dynamicIdentifierLabel.text = allEntriesRelationData[indexPath.section].dynamicField1
            cell.editButtonOutlet.isHidden = true
            cell.deleteButtonOutlet.isHidden = true
            cell.seeMoreButtonOutlet.isHidden = true
            cell.staticIdentifierLabel.isHidden = false
            
            return cell
            
        } else if indexPath.row == 1 {
            
            print("Bool Value",singleRowOnly)
            
            if singleRowOnly {

                cell.staticIdentifierLabel.text = ""
                cell.dynamicIdentifierLabel.isHidden = true
                cell.editButtonOutlet.isHidden = false
                cell.deleteButtonOutlet.isHidden = false
                //cell.isUserInteractionEnabled = false
                cell.seeMoreButtonOutlet.isHidden = true
                cell.staticIdentifierLabel.isHidden = false
                
            } else {
                
                cell.dynamicIdentifierLabel.isHidden = false
                cell.staticIdentifierLabel.text = allEntriesRelationData[indexPath.section].staticField2
                cell.dynamicIdentifierLabel.text = allEntriesRelationData[indexPath.section].dynamicField2
                cell.editButtonOutlet.isHidden = true
                cell.deleteButtonOutlet.isHidden = true
                //cell.isUserInteractionEnabled = false
                cell.seeMoreButtonOutlet.isHidden = true
                cell.staticIdentifierLabel.isHidden = false
            }
            
           
            return cell
            
        }
        
        else if indexPath.row == 2 && !allEntriesRelationData[indexPath.section].opened {
            
            if twoRowsOnly {
                //twoRowsOnly = false
                
                if isSupervisiorIndex == 1 {
                    cell.staticIdentifierLabel.text = ""
                    cell.dynamicIdentifierLabel.isHidden = true
                    cell.editButtonOutlet.isHidden = true
                    cell.deleteButtonOutlet.isHidden = true
                    //cell.isUserInteractionEnabled = false
                    cell.seeMoreButtonOutlet.isHidden = true
                    cell.staticIdentifierLabel.isHidden = false
                } else {
                    cell.staticIdentifierLabel.text = ""
                    cell.dynamicIdentifierLabel.isHidden = true
                    cell.editButtonOutlet.isHidden = false
                    cell.deleteButtonOutlet.isHidden = false
                    //cell.isUserInteractionEnabled = false
                    cell.seeMoreButtonOutlet.isHidden = true
                    cell.staticIdentifierLabel.isHidden = false
                }
                
                
                
                
            } else {
                
                cell.seeMoreButtonOutlet.isHidden = false
                cell.staticIdentifierLabel.isHidden = true
                cell.seeMoreButtonOutlet.setTitle("See More ▼", for: .normal)
                cell.seeMoreButtonOutlet.tag = indexPath.row * 1000 + indexPath.section
                
                //cell.staticIdentifierLabel.text = "See More ▼"
                cell.dynamicIdentifierLabel.isHidden = true
                cell.editButtonOutlet.isHidden = true
                cell.deleteButtonOutlet.isHidden = true
                //cell.isUserInteractionEnabled = true
            }
            
           
            return cell
            
        } else {
            
            print("Else Indepath Row", indexPath.row)
          
            print(allEntriesRelationData[indexPath.section].sectionData!.count + 2)
            
            if indexPath.row ==  allEntriesRelationData[indexPath.section].sectionData!.count + 2 {
                
                cell.seeMoreButtonOutlet.isHidden = false
                cell.staticIdentifierLabel.isHidden = true
                cell.seeMoreButtonOutlet.setTitle("See Less ▲", for: .normal)
                cell.seeMoreButtonOutlet.tag = indexPath.row * 1000 + indexPath.section
                cell.dynamicIdentifierLabel.isHidden = true
                
                if isSupervisiorIndex == 1 {
                    cell.editButtonOutlet.isHidden = true
                    cell.deleteButtonOutlet.isHidden = true
                } else {
                    cell.editButtonOutlet.isHidden = false
                    cell.deleteButtonOutlet.isHidden = false
                }
                
                
                
                return cell
            } else {
                
                if allEntriesRelationData[indexPath.section].sectionData?.count ?? 0 == 0 {
                    
                    return cell
                    
                } else {
                    
                    print("Open",allEntriesRelationData[indexPath.section].opened);
                    print("Indexpath Section", indexPath.section);
                    print("Indexpath row", indexPath.row);
                    print("open")
                    print("Section Data Count", allEntriesRelationData[indexPath.section].sectionData!.count);
                    print("Section Data", allEntriesRelationData[indexPath.section].sectionData![indexPath.row - 2]);
                    
                   if let cellValue = allEntriesRelationData[indexPath.section].sectionData?[indexPath.row - 2] {
                        
                        cell.dynamicIdentifierLabel.isHidden = false
                        cell.editButtonOutlet.isHidden = true
                        cell.deleteButtonOutlet.isHidden = true
                        cell.seeMoreButtonOutlet.isHidden = true
                        cell.staticIdentifierLabel.isHidden = false
                        
                        if cellValue["SFieldName"].stringValue != "" {
                            cell.staticIdentifierLabel.text = cellValue["SFieldName"].stringValue
                            cell.dynamicIdentifierLabel.text = cellValue["SF_Value"].stringValue
                        } else {
                            cell.staticIdentifierLabel.text = cellValue["CategoryName"].stringValue
                            cell.dynamicIdentifierLabel.text = cellValue["CategoryValue"].stringValue
                        }
                        
                    }
                    return cell
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (cell.responds(to: #selector(getter: UIView.tintColor))) {
            
            let cornerRadius: CGFloat = 5
            cell.backgroundColor = UIColor.clear
            let layer: CAShapeLayer  = CAShapeLayer()
            let pathRef: CGMutablePath  = CGMutablePath()
            let bounds: CGRect  = cell.bounds.insetBy(dx: 10, dy: 0)
            var addLine: Bool  = false
            
            if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            } else if (indexPath.row == 0) {
                pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.maxY))
                pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.minY), tangent2End: CGPoint(x:bounds.midX,y:bounds.minY), radius: cornerRadius)
                
                pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.minY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.maxY))
                addLine = true;
            } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                
                pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.minY))
                pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: cornerRadius)
                pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.minY))
                
            } else {
                pathRef.addRect(bounds)
                addLine = true
            }
            
            layer.path = pathRef
            //CFRelease(pathRef)
            layer.strokeColor = UIColor.lightGray.cgColor;
            //set the border width
            layer.lineWidth = 1
            layer.fillColor = UIColor(white: 1, alpha: 1.0).cgColor
            
            if (addLine == true) {
                let lineLayer: CALayer = CALayer()
                let lineHeight: CGFloat  = (1 / UIScreen.main.scale)
                lineLayer.frame = CGRect(x:bounds.minX, y:bounds.size.height-lineHeight, width:bounds.size.width, height:lineHeight)
                lineLayer.backgroundColor = tableView.separatorColor!.cgColor
                layer.addSublayer(lineLayer)
            }
            
            let testView: UIView = UIView(frame:bounds)
            testView.layer.insertSublayer(layer, at: 0)
            testView.backgroundColor = UIColor.clear
            cell.backgroundView = testView
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    

    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonTapped(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        print("Edit Index", sender.tag)
        print(allEntriesRelation)
        self.performSegue(withIdentifier: "editDatabaseEntry", sender: allEntriesRelation[sender.tag])
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        print("delete Index", sender.tag)
        print(allEntriesRelation[sender.tag])
        print(allEntriesRelationData[0])
        
        //deleteDatabaseEntry
        var dataDictionary = [String: Any]()
        
        dataDictionary["DatabaseID"] = allEntriesRelation[sender.tag][0]["DatabaseID"].stringValue
        dataDictionary["UL_ID"] = allEntriesRelation[sender.tag][0]["UL_ID"].stringValue
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        self.deleteDataBaseEntry(dataDictionary: dict, tagValue: sender.tag)
        
        
    }
    
    
    
    //MARK: Deletedatabase
    func deleteDataBaseEntry(dataDictionary:[String:Any], tagValue: Int) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        
        let bearerToken = "Bearer \(token)"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        databaseInfoModel.deleteDatabaseEntry(dataDictionary: dataDictionary, header: header ).done { json-> Void in
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
//
            let jsonDictionary = JSON(json)
            
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            if responseStatus {
                
                self.allEntriesRelationData.remove(at: tagValue)
                self.allEntriesRelation.remove(at: tagValue)
                
                let indexSet = IndexSet(arrayLiteral: tagValue)
                self.tableView.deleteSections(indexSet, with: .automatic)
                
                if self.allEntriesRelationData.count == 0 {
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            }.catch { error in
                
                // stop spinner
//                self.spinner.stopAnimate(complete: {
//                    self.blurView.isHidden = true
//                    self.spinner.isHidden = true
//                })
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
        }
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editDatabaseEntry" {
            // pass data to next view

            let senderValue = sender as? [JSON]
            
            if let editDatabaseViewController = segue.destination as? EditDatabaseInfoVC {
                editDatabaseViewController.dataBaseEntry = senderValue
                editDatabaseViewController.dbName = self.dbNamelabel.text!
            }
        } else if segue.identifier == "toAddNewEnteries" {
            //NewEntryVC
            if let newEntryVC = segue.destination as? NewEntryVC {
                newEntryVC.createUserDBArray = sender as! JSON
            }
            
        }
    }
    
    @IBAction func unwindToEditDatabaseInfoVC(segue:UIStoryboardSegue) {
        
        // Do nothing here
        // its use for exit from another VC
        
    }
    
    
    @IBAction func seeMoreButtonTapped(_ sender: Any) {
       
        let section = (sender as AnyObject).tag % 1000
        let row = (sender as AnyObject).tag / 1000
        let selectedIndexPath = IndexPath(row: row, section: section)
        
        
        print(row,selectedIndexPath)
        print("ISOPENED", allEntriesRelationData[section].opened)
        
        
        if allEntriesRelationData[section].opened == true {
            allEntriesRelationData[section].opened = false
            let section = IndexSet.init(integer: section)
            tableView.reloadSections(section, with: .none)
            
        } else {
            
            allEntriesRelationData[section].opened = true
            let section = IndexSet.init(integer: section)
            tableView.reloadSections(section, with: .none)
            
        }
    }
    
    
    @IBAction func addDatabaseEntryButton(_ sender: Any) {
        
        var dataDictionary = [String: Any]()
        
        
        dataDictionary["DatabaseID"] = allEntriesRelation[0][0]["DatabaseID"].stringValue
        
        var dict = [String:Any]()
        dict["ULRDB"] = dataDictionary
        
        var dictdata = [String: Any]()
        dictdata[globalConstants.apiUrl.kData] = dict
        
        //globalConstants.apiUrl.kData
        self.getNewEntryInExistingDatabase(dataDictionary: dictdata)
    }
    
    
    func getNewEntryInExistingDatabase(dataDictionary:[String:Any]) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        
        let bearerToken = "Bearer \(token)"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        databaseInfoModel.getNewEntryInDatabase(dataDictionary: dataDictionary, header: header ).done { json-> Void in
            // stop spinner
            //            self.spinner.stopAnimate(complete: {
            //                self.blurView.isHidden = true
            //                self.spinner.isHidden = true
            //            })
            //
            let jsonDictionary = JSON(json)
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                print(jsonDictionary["data"])
                
               self.performSegue(withIdentifier: "toAddNewEnteries", sender: jsonDictionary["data"])
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            }.catch { error in
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
        }
    }
    
    @IBAction func unwindToDatabaseInformationVC(segue:UIStoryboardSegue) { }

}



//MARK: NewDataBaseTableViewCell
class DatabaseInfoTableViewCell: UITableViewCell  {
    
    @IBOutlet var staticIdentifierLabel: UILabel!
    @IBOutlet var staticAgeLabel: UILabel!
    @IBOutlet var dynamicIdentifierLabel: UILabel!
    @IBOutlet var dynamicAgeLabel: UILabel!
    @IBOutlet var customView: UIView!
    
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var seeMoreButtonOutlet: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let dbInfo = DatabaseInfoVC()
        dbInfo.index += 1
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}



//MARK: Searchbar
extension DatabaseInfoVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        
        var pageInfoDictionary = [String: Any]()
        pageInfoDictionary["pageNumber"] = 1
        pageInfoDictionary["pageSize"] = 10
        pageInfoDictionary["TotalCount"] = "0"
        pageInfoDictionary["CurrentPage"] = "1"
        pageInfoDictionary["TotalPages"] = "0"
        pageInfoDictionary["PreviousPage"] = true
        pageInfoDictionary["NextPage"] = true
        pageInfoDictionary["QuerySearch"] = searchText
        
        
        var ULRDB = [String:Any]()
        ULRDB["DatabaseID"] = databaseID
        
        var dataDictionary = [String:Any]()
        dataDictionary["UL_RDB"] = ULRDB
        dataDictionary["PagingInfo"] = pageInfoDictionary
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        print("user datadictionary ", dict)
        self.getAllUserDataBase(dataDictionary: dict)
        
    }
    
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.endEditing(true)
    }
   
    
}






