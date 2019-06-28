//
//  AddSubCategoryListVC.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 06/12/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SSSpinnerButton


class AddSubCategoryListVC: UIViewController {
    
    lazy var blurViewEffect : UIView = UIView()
    lazy var customAlert : UIView = UIView()
    let addnewCategoryTextfield = UITextField()
    let newCategoryTitleLabel = UILabel()
    var subCategoryName = [String]()
    var categoryName = String()
    var isCommingFromSearchVC = Bool()
    
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var spinner: SSSpinnerButton!
    @IBOutlet weak var subCategoryTableView: UITableView!
    @IBOutlet weak var messageLabelOutlet: UILabel!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    
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
        blurViewEffect.isHidden = true
        doneButtonOutlet.isHidden = true
        categoryNameLabel.text = categoryName
        
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
     
        customAlert.isHidden = false
        blurViewEffect.isHidden = false
        addnewCategoryTextfield.text = ""
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func doneButtonClick(_ sender: Any) {
        
        if subCategoryName.count == 0 {
             AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: globalConstants.validation.KSubCategoryBlankMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        } else {
            //backToNewDatabaseVC
            
            if isCommingFromSearchVC {
                isCommingFromSearchVC = false
                self.performSegue(withIdentifier: "backToSearchFields", sender: nil)
            } else {
                self.performSegue(withIdentifier: "backToNewDatabaseVC", sender: nil)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToNewDatabaseVC" {
            let vc = segue.destination as! NewDatabaseVC
            vc.newSubcategoryNameArray = subCategoryName
        } else if segue.identifier == "backToSearchFields" {
            let vc = segue.destination as! SearchFieldsVC
            vc.subCategoryArray = subCategoryName
            vc.isCommingFormAddSubCategoryListVC = true
        }
    }
    
}


extension AddSubCategoryListVC  {
    
    
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
        newCategoryTitleLabel.text = "Add SubCategory"
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

        subCategoryName.append(addnewCategoryTextfield.text!)
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
        subCategoryTableView.isHidden = false
    
        messageLabelOutlet.isHidden = true
        subCategoryTableView.reloadData()
        doneButtonOutlet.isHidden = false
        self.addnewCategoryTextfield.resignFirstResponder()
        
    }
    
    
    @objc func noButtonTapped() {
        self.addnewCategoryTextfield.resignFirstResponder()
        customAlert.isHidden = true
        blurViewEffect.isHidden = true
    }
    
}


extension AddSubCategoryListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryName.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = subCategoryName[indexPath.row]
        return cell!
    }
    
}


