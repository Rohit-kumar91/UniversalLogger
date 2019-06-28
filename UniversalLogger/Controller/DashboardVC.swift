//
//  DashboardVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/27/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton
import StoreKit
import SwiftyStoreKit

class DashboardVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet var dashboardTitleView: UIView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    @IBOutlet var noDatabaseFoundLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var verticleSpacinginTableViewandTitle: NSLayoutConstraint!
    lazy var dbArray = [String]()
    lazy var universalLoggerDB = [JSON]()
    lazy var universalLoggerSupervisorDB = [JSON]()
    lazy var segmentIndex = Int()
    
    lazy var databaseID = Int()
    lazy var userID = Int()
    lazy var sp_emailId:String = String()
    lazy var sp_User_ID : Int = Int()
    lazy var deleted_IndexPath = IndexPath()
    
    lazy var selectedDatabase = JSON()
    let dashboardModel = DashboardModel()
    var userInformation = Bool()
    
    // test
    private lazy var totalCount = Int()
    private lazy var pageNumber = Int()
    private lazy var currentPage = Int()
    private let pageSize = 10
    private var actvitySpinner = UIActivityIndicatorView()
    
    // Testing
    private var isDataLoading:Bool=false
    private let refreshController = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //========================================..............................==============================//
        //Refresh Controller
        tableView.refreshControl = refreshController
        refreshController.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)]
        refreshController.attributedTitle = NSAttributedString(string: "Fetching Database ...", attributes: attributes)

        
        refreshController.addTarget(self, action: #selector(refreshSDatabaseData(_:)), for: .valueChanged)
        
        //Menu RevealController.
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 80
        menuButtonOutlet.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())


        dashboardTitleView.shadowUnderView()
        
        // disable tableview selection
        tableView.allowsSelection = false
        
        // Remove extra cell from tableView
        tableView.tableFooterView = UIView()
        
        segmentControl.isHidden = true
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @objc private func refreshSDatabaseData(_ sender: Any) {
        self.universalLoggerDB.removeAll()
        getTheAllDatabse(showSpinner: false)
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        
        // self.dbArray.removeAll()
        self.universalLoggerDB.removeAll()
        //segmentControl.selectedSegmentIndex = 0
        getTheAllDatabse(showSpinner: true)

    }
    
    
    func getTheAllDatabse(showSpinner: Bool) {
        
        if showSpinner {
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        }
       
        
        dbArray.removeAll()
        pageNumber = 1
        
        print("page number ", pageNumber)
        
        var dataDictionary = [String: Any]()
        dataDictionary["pageNumber"] = pageNumber
        dataDictionary["pageSize"] = pageSize
        dataDictionary["TotalCount"] = "0"
        dataDictionary["CurrentPage"] = "1"
        dataDictionary["TotalPages"] = "0"
        dataDictionary["PreviousPage"] = true
        dataDictionary["NextPage"] = true
        dataDictionary["QuerySearch"] = ""
        
        var dict = [String:Any]()
        dict[globalConstants.apiUrl.kData] = dataDictionary
        
        print(dict)
        self.getAllUserDataBase(dataDictionary: dict)
        
    }
    
    
    
    func getAllUserDataBase(dataDictionary:[String:Any]) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }

        let bearerToken = "Bearer \(token)"
        print("token is ", bearerToken)
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        
        print(header)
        
        dashboardModel.getAllUserDataBase(dataDictionary: dataDictionary, header: header ).done { json-> Void in
            // stop spinner
            //
            self.refreshController.endRefreshing()
            
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                self.totalCount = jsonDictionary[globalConstants.apiUrl.kData]["PagingInfo"]["TotalCount"].intValue
                self.currentPage = jsonDictionary[globalConstants.apiUrl.kData]["PagingInfo"]["CurrentPage"].intValue
                print("paging counter ", self.totalCount)
                
                //self.universalLoggerDB.removeAll()

                self.universalLoggerDB =  self.universalLoggerDB + jsonDictionary[globalConstants.apiUrl.kData]["UL_RDB"].arrayValue
                self.tableView.reloadData()
                print(type(of: self.universalLoggerDB))
                print("universalLoggerDB ", self.universalLoggerDB)
                
                self.userInformation = jsonDictionary[globalConstants.apiUrl.kData]["UL_Users"]["IsSupervisor"].boolValue
                
                self.appDelegate.currentUserEmail = jsonDictionary[globalConstants.apiUrl.kData]["UL_Users"]["EmaiIId"].stringValue
                
                self.appDelegate.currentThumbInfoBool = jsonDictionary[globalConstants.apiUrl.kData]["UL_DeviceThumb"]["Status"].boolValue
                
                if self.userInformation {
                    
                    self.segmentControl.isHidden = false
                    
                } else {
                    
                    self.verticleSpacinginTableViewandTitle.constant = 10.0
                    self.segmentControl.isHidden = true
                }
                
                if self.universalLoggerDB.count == 0 {
                    self.noDatabaseFoundLabel.isHidden = false
                    self.tableView.isHidden = true

                } else {
                    
                    print("universalLoggerDB counter", self.universalLoggerDB.count)
                    print("json print.....\(jsonDictionary)")
                    for (index,_) in self.universalLoggerDB.enumerated() {
                        
                        let dbName = jsonDictionary[globalConstants.apiUrl.kData]["UL_RDB"][index]["DatabaseName"].stringValue
                        self.dbArray.append(dbName)
                    }
                    
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
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
    
    
    
    
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        /*
        let alert = UIAlertController(title: globalConstants.alertController.kAlertTitle, message: "Please select an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Touch Enable", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))
  
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive , handler:{ (UIAlertAction)in
            
            UserDefaults.standard.removeObject(forKey: globalConstants.touchSensor.kTouchSensor)
            Helper.removeUserDefault(key: "token")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
 */
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         if segmentIndex == 0 {
            
            print("counter is ", dbArray.count)
            print("db array ", dbArray)
            return universalLoggerDB.count
            
         } else {
            
            return universalLoggerSupervisorDB.count
        }
    }

    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("dbarray counter",dbArray.count)
        print("total counter", totalCount)
        
        print("scrollViewDidEndDragging")
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if dbArray.count < totalCount {
                
                if !isDataLoading{
                    isDataLoading = true
                    self.pageNumber=self.currentPage + 1
                    
                    print("array counter", dbArray.count)
                    print("total coun", totalCount)
                    
                        var dataDictionary = [String: Any]()
                        dataDictionary["pageNumber"] = pageNumber
                        dataDictionary["pageSize"] = pageSize
                        dataDictionary["TotalCount"] = totalCount
                        dataDictionary["CurrentPage"] = self.currentPage
                        dataDictionary["TotalPages"] = "0"
                        dataDictionary["PreviousPage"] = true
                        dataDictionary["NextPage"] = true
                        dataDictionary["QuerySearch"] = ""
                        
                        var dict = [String:Any]()
                        dict[globalConstants.apiUrl.kData] = dataDictionary
                        self.getAllUserDataBase(dataDictionary: dict)

                }
            }
            
           else {
                
                print("end index")
                actvitySpinner.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if segmentIndex == 0 {
            
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                
            }
        }
    }
    

    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DashboardTableViewCell
        if segmentIndex == 0 {
            
            cell.databaseName.text = universalLoggerDB[indexPath.row]["DatabaseName"].stringValue//dbArray[indexPath.row]

            let isLinkedSupervisor = universalLoggerDB[indexPath.row]["SP_EmailID"].stringValue
            
            if isLinkedSupervisor == "0"{
                cell.linkSupervisorButton.selectedButton(title: "Link supervisor", iconName: "link-email-icon.png")
                cell.linkSupervisorButton.setTitleColor(#colorLiteral(red: 0.4156862745, green: 0.8352941176, blue: 0.5529411765, alpha: 1), for: .normal)

            }else{
                cell.linkSupervisorButton.selectedButton(title: "Link supervisor", iconName: "link-email-icon-blue.png")
                cell.linkSupervisorButton.setTitleColor(#colorLiteral(red: 0.368627451, green: 0.5215686275, blue: 0.8470588235, alpha: 1), for: .normal)
            }

            
            cell.linkSupervisorButton.tag = indexPath.row
            cell.linkSupervisorButton.addTarget(self, action: #selector(linkSupervisor(_:)), for: .touchUpInside)
            cell.linkSupervisorButton.isEnabled = true
            cell.linkSupervisorButton.contentHorizontalAlignment = .center

            cell.sendDatabase.selectedButton(title: "Export database", iconName: "send-database-icon.png")
            cell.sendDatabase.tag = indexPath.row
            cell.sendDatabase.addTarget(self, action: #selector(sendDatabase(_:)), for: .touchUpInside)
            cell.sendDatabase.isHidden = false

            cell.showDBButtonTapped.tag = indexPath.row
            cell.showDBButtonTapped.addTarget(self, action: #selector(showDatabaseInfo(_:)), for: .touchUpInside)

            cell.cellBackgroundView?.layer.borderWidth = 1.0
            cell.cellBackgroundView?.layer.borderColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0).cgColor
            cell.cellBackgroundView.layer.cornerRadius = 4.0
            
            
        } else {
            
            let linkBy = universalLoggerSupervisorDB[indexPath.row]["EmaiIId"].stringValue
            cell.databaseName.text = universalLoggerSupervisorDB[indexPath.row]["DatabaseName"].stringValue
            cell.linkSupervisorButton.selectedButton(title: "Link supervisor", iconName: "")

            cell.linkSupervisorButton.setTitle(linkBy, for: .normal)
            cell.linkSupervisorButton.isEnabled = false
            cell.linkSupervisorButton.contentHorizontalAlignment = .left
            cell.sendDatabase.isHidden = true
            
            cell.showDBButtonTapped.tag = indexPath.row
            cell.showDBButtonTapped.addTarget(self, action: #selector(showDatabaseInfo(_:)), for: .touchUpInside)

        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted Call...")
            
        
            //Need to be call the delete web service to delete the data.
            // Right it handle only locally.
            if segmentIndex == 0 {
                //universalLoggerDB.remove(at: indexPath.row)
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: "Are you sure you want to delete?", actionTitles: [globalConstants.alertController.kCancel,globalConstants.alertController.kOK], actions: [
                    {()->() in
                       print("1")
                    },
                    {()->() in
                        print("2")
                        var dataDictionary = [String: Any]()
                        self.deleted_IndexPath = indexPath
                        dataDictionary["DatabaseID"] = self.universalLoggerDB[self.deleted_IndexPath.row]["DatabaseID"].stringValue
        
                        var dict = [String:Any]()
                        dict[globalConstants.apiUrl.kData] = dataDictionary
                        self.deleteDataBase(dataDictionary: dict)
                    }
                    
                    ]
                )
            
                
                
//                var dataDictionary = [String: Any]()
//                deleted_IndexPath = indexPath
//                dataDictionary["DatabaseID"] = universalLoggerDB[deleted_IndexPath.row]["DatabaseID"].stringValue
//
//                var dict = [String:Any]()
//                dict[globalConstants.apiUrl.kData] = dataDictionary
//                self.deleteDataBase(dataDictionary: dict)
                
            } else {
                universalLoggerSupervisorDB.remove(at: indexPath.row)
            }
        }
    }
    
    
    
    
    
    
    
    @objc func linkSupervisor(_ sender:UIButton)
    {
        
        print("link SupervisorVC")
        
        databaseID = universalLoggerDB[sender.tag]["DatabaseID"].intValue
        userID = universalLoggerDB[sender.tag]["User_ID"].intValue
        sp_emailId = universalLoggerDB[sender.tag]["SP_EmailID"].stringValue
        self.performSegue(withIdentifier: "linkSupervisorVCId", sender: nil)
   
    }
    
    @IBAction func addNewButtonTapped(_ sender: UIButton) {
        
       self.performSegue(withIdentifier: "newDatabaseId", sender: nil)
        
    }
    
    
    @objc func showDatabaseInfo(_ sender:UIButton) {
        
        print("show info")
        print(sender.tag)
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            databaseID = universalLoggerDB[sender.tag][globalConstants.apiUrl.kDatabaseID].intValue
            sp_User_ID = 0


        }else{
            
            databaseID = universalLoggerSupervisorDB[sender.tag][globalConstants.apiUrl.kDatabaseID].intValue
            sp_User_ID = universalLoggerSupervisorDB[sender.tag]["SP_User_ID"].intValue
            
            
        }
        
        print("Database id is \(databaseID)")
        self.performSegue(withIdentifier: "databaseInfoVCID", sender: nil)

    }
    
    
    @objc func sendDatabase(_ sender:UIButton) {
        
        print("send db")
        
        databaseID = universalLoggerDB[sender.tag][globalConstants.apiUrl.kDatabaseID].intValue

        var dataDictionary = [String:Any]()
        dataDictionary[globalConstants.apiUrl.kDatabaseID] = databaseID

        var sendDBDictionary = [String:Any]()
        sendDBDictionary[globalConstants.apiUrl.kData] = dataDictionary

        print("send db ", sendDBDictionary)

        self.sendDB(dataDictionary: sendDBDictionary)
        
    }
    
    
    func sendDB(dataDictionary:[String:Any])  {
        
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            
            return
        }
        
        let bearerToken = "Bearer \(token)"
        
        print("token is ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        dashboardModel.sendDatabase(dataDictionary:dataDictionary, header: header).done { json-> Void in
            
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            
            print("json", json)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                let responseCode = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseCode].intValue
                
                if responseCode == globalConstants.apiUrl.kResponseCodeValue {
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "The Database has been sent to your email.", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                    
                } else {
                    
                    let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                    
                    
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
    
    
    @IBAction func segementControlTapped(_ sender: UISegmentedControl) {
        
        segmentIndex = segmentControl.selectedSegmentIndex
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            
            self.universalLoggerDB.removeAll()
            dbArray.removeAll()
            pageNumber = 1

            
            var dataDictionary = [String: Any]()
            dataDictionary["pageNumber"] = pageNumber  
            dataDictionary["pageSize"] = pageSize
            dataDictionary["TotalCount"] = "0"
            dataDictionary["CurrentPage"] = "1"
            dataDictionary["TotalPages"] = "0"
            dataDictionary["PreviousPage"] = true
            dataDictionary["NextPage"] = true
            dataDictionary["QuerySearch"] = ""
            
            var dict = [String:Any]()
            dict[globalConstants.apiUrl.kData] = dataDictionary
            
            print("user json data dictionary ", dict)

            self.getAllUserDataBase(dataDictionary: dict)
            
            
            
        } else if segmentControl.selectedSegmentIndex == 1 {
            
            var dataDictionary = [String: Any]()
            dataDictionary["pageNumber"] = "1" as String
            dataDictionary["pageSize"] = pageSize
            dataDictionary["TotalCount"] = "0"
            dataDictionary["CurrentPage"] = "1"
            dataDictionary["TotalPages"] = "0"
            dataDictionary["PreviousPage"] = true
            dataDictionary["NextPage"] = true
            dataDictionary["QuerySearch"] = ""
            
            var dict = [String:Any]()
            dict[globalConstants.apiUrl.kData] = dataDictionary
            
            print("supervisor data ", dataDictionary)
//            tableView.reloadData()

            
            self.getSupervisorDatabase(dataDictionary: dict)

        }
        
        print("segment index", segmentControl.selectedSegmentIndex)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "linkSupervisorVCId" {
            
            let linkSupervisorVC = segue.destination as! LinkSupervisorVC
            linkSupervisorVC.databaseID = databaseID
            linkSupervisorVC.userID = userID
            linkSupervisorVC.sp_emailId = sp_emailId
            
        }
        
        else if segue.identifier == "databaseInfoVCID" {
            
            let databaseInfoVC = segue.destination as! DatabaseInfoVC
            databaseInfoVC.databaseID = databaseID
            databaseInfoVC.sp_UserId = sp_User_ID
            databaseInfoVC.isSupervisiorIndex = segmentControl.selectedSegmentIndex
            databaseInfoVC.isSuperVisior = userInformation
            
        }
    }
    
    
    func getSupervisorDatabase(dataDictionary:[String:Any]) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            
            return
        }
        
        let bearerToken = "Bearer \(token)"
        
        print("token ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        print(dataDictionary)
        
        dashboardModel.getSupervisorDatabase(dataDictionary: dataDictionary, header: header ).done { json-> Void in
            
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            
            print("supervisor  json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            
            if responseStatus {
                
                self.universalLoggerSupervisorDB = jsonDictionary[globalConstants.apiUrl.kData]["ULUsers"].arrayValue
                
                self.tableView.reloadData()

                if self.universalLoggerSupervisorDB.count == 0 {
                    
                    self.noDatabaseFoundLabel.isHidden = false
                    self.tableView.isHidden = true
                    
                } else {
                    
                    for (index,_) in self.universalLoggerSupervisorDB.enumerated() {
                        
                        let dbName = jsonDictionary[globalConstants.apiUrl.kData]["UL_RDB"][index]["DatabaseName"].stringValue
                        self.dbArray.append(dbName)
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        
                    }
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
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    

    
    @IBAction func unwindToNewDatabse(segue:UIStoryboardSegue) {
        
        // Do nothing here
        // its use for exit from another VC
        
    }
    
    
    @IBAction func unwindToDashboardFromNewEntry(segue:UIStoryboardSegue) {
        
        viewWillAppear(true)

    }
    
    //MARK: Deletedatabase
    func deleteDataBase(dataDictionary:[String:Any]) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        
        let bearerToken = "Bearer \(token)"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        dashboardModel.deleteDatabase(dataDictionary: dataDictionary, header: header ).done { json-> Void in
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            if responseStatus {
                
                self.universalLoggerDB.remove(at: self.deleted_IndexPath.row)
                
                if self.universalLoggerDB.count == 0 {
                    self.noDatabaseFoundLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                    self.noDatabaseFoundLabel.isHidden = true
                    self.tableView.reloadData()
                }
                
                
            
               // self.tableView.deleteRows(at: [self.deleted_IndexPath], with: .automatic)
                
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
}




//MARK: NewDataBaseTableViewCell
class DashboardTableViewCell: UITableViewCell  {
    
    @IBOutlet var databaseName: UILabel!
    @IBOutlet var linkSupervisorButton: UIButton!
    @IBOutlet var sendDatabase: UIButton!
    @IBOutlet var cellBackgroundView: UIView!
    @IBOutlet var showDBButtonTapped: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}



