//
//  SearchFieldsVC.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 15/11/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton

class SearchFieldsVC: UIViewController {

    
    var searchableFieldArray = [String]()
    var searching = false
    var searchedField = [String]()
    lazy var customAlert : UIView = UIView()
    lazy var blurViewEffect : UIView = UIView()
    let addnewCategoryTextfield = UITextField()
    let newCategoryTitleLabel = UILabel()
    var addNewCategory = String()
    
    var newFieldArray = [JSON]()
    var subCategoryArray = [String]()
    let searchFieldModel = SearchFieldsModel()
    var isCommingFormAddSubCategoryListVC = Bool()
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var spinner: SSSpinnerButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        blurViewEffect.frame = self.view.frame
        blurViewEffect.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 0.9)
        self.view.addSubview(blurViewEffect)
        blurViewEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        showCustomAlert()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCommingFormAddSubCategoryListVC {
            isCommingFormAddSubCategoryListVC = false
            //Do updating stuff......
            
            var subDictionary = [String : Any]()
            subDictionary["CategoryName"] = self.addNewCategory
            subDictionary["EnableField"] = true
            subDictionary["SubCategoryValue"] = subCategoryArray
            
            var saveEntryDatabaseDictionary = [String : Any]()
            saveEntryDatabaseDictionary["data"] = subDictionary
            self.saveSubCategory(dataDictionary: saveEntryDatabaseDictionary)
        }
    }
    
    
    @IBAction func unwindToSearchFields(segue:UIStoryboardSegue) { }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addNewFieldButtonTapped(_ sender: Any) {
        customAlert.isHidden = false
        blurViewEffect.isHidden = false
        addnewCategoryTextfield.text = ""
    }
    
    
}

extension SearchFieldsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedField.count
        } else {
            return searchableFieldArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if searching {
            cell?.textLabel?.text = searchedField[indexPath.row]
        } else {
            cell?.textLabel?.text = searchableFieldArray[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //entryDatabaseInfoVC
        
        if searching {
            performSegue(withIdentifier: "entryDatabaseInfoVC", sender: searchedField[indexPath.row])
        } else {
            performSegue(withIdentifier: "entryDatabaseInfoVC", sender: searchableFieldArray[indexPath.row])
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryDatabaseInfoVC" {
            if let vc = segue.destination as? EditDatabaseInfoVC {
                
                print(newFieldArray)
                
                for element in newFieldArray {
                    
                    if sender as! String == element["CategoryName"].stringValue {
                        
                       
                        
                        var tempdict = [String : Any]()
                        tempdict["SubCategoryValue"] = element["SubCategoryValue"].arrayValue
                        tempdict["VFChecked"] = element["EnableField"].boolValue
                        tempdict["CategoryName"] = element["CategoryName"].stringValue
                        tempdict["CategoryID"] = element["CategoryID"].intValue
                        
                        vc.isNewValueAdded = true
                        vc.newItemToBeAdded = JSON(tempdict)
                    }
                }
                
                vc.searchedFieldName = sender as! String
                vc.isSearchableAdd = true
            }
        } else if segue.identifier == "addSubCategorySegue" {
            
            let addSubCategoryVC = segue.destination as! AddSubCategoryListVC
            addSubCategoryVC.categoryName = addNewCategory
            addSubCategoryVC.isCommingFromSearchVC = true
            
        }
    }

}

extension SearchFieldsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedField = searchableFieldArray.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
        self.view.endEditing(true)

    }
}

extension SearchFieldsVC {
    
    
    func showCustomAlert() {
        
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
    
    
    
    @objc func okButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        
        addNewCategory = addnewCategoryTextfield.text ?? ""
        addNewCategory = addNewCategory.trimmingCharacters(in: .whitespaces)
        
        if (addNewCategory.isEmpty) {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: globalConstants.validation.kBlankCategory, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        } else {
            
            //Show Alert for adding the subcategory in the newly created field.
            let alertcontroller = UIAlertController(title: "Universal Logger", message: "Do you want to make options for \(addNewCategory)?", preferredStyle: .alert)

            let cancelAction  = UIAlertAction(title: "No", style: .default) { _ in
                
                var subDictionary = [String : Any]()
                subDictionary["CategoryName"] = self.addNewCategory
                subDictionary["EnableField"] = true
                subDictionary["SubCategoryValue"] = []
                
                var saveEntryDatabaseDictionary = [String : Any]()
                saveEntryDatabaseDictionary["data"] = subDictionary
                self.saveSubCategory(dataDictionary: saveEntryDatabaseDictionary)
                
            }

            let okAction  = UIAlertAction(title: "Yes", style: .default) { _ in
                self.performSegue(withIdentifier: "addSubCategorySegue", sender: nil)
            }
            alertcontroller.addAction(cancelAction)
            alertcontroller.addAction(okAction)
            self.present(alertcontroller, animated: true, completion: nil)
            
        }
    }
    
    
    @objc func noButtonTapped() {
        
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
    
    }
    
    
    func saveSubCategory(dataDictionary:[String:Any]) {
        
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        
        let bearerToken = "Bearer \(token)"
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        searchFieldModel.saveSubCategory(dataDictionary: dataDictionary, header: header ).done { json-> Void in
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
                
                print("Success")
                self.searchableFieldArray.append(jsonDictionary["data"]["CategoryName"].stringValue)
                self.newFieldArray.append(jsonDictionary["data"])
                self.tableView.reloadData()
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            }.catch { error in
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
        }
    }
}

    
    




