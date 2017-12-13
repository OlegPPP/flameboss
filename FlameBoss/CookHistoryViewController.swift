//
//  CookHistoryViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/27/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class CookHistoryViewController : FBViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editTableButton: UIButton!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDetailLabel: UILabel!
    
    fileprivate var cookHistory = [Cook]()
    fileprivate var searchingForCooks = false
    
    fileprivate var headerScrollAdjuster: HeaderScrollAdjuster!

    fileprivate var tapCnt : Int = 0
    fileprivate var lastTapSec : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configure()

        let tap = UITapGestureRecognizer(target: self, action: #selector(CookHistoryViewController.tappedMe))
        headerImage.addGestureRecognizer(tap)
        headerImage.isUserInteractionEnabled = true
    }

    @objc private func tappedMe()
    {
        let now = Int(Date().timeIntervalSince1970)
        let diff = now - lastTapSec

        if (diff < 30)
        {
            tapCnt += 1
            if (tapCnt == 5)
            {
                showDevAlert()
            }
            else if (tapCnt == 7)
            {
                var serverIndex = UserDataStore.getServerIndex()
                serverIndex = (serverIndex == 0) ? 1 : 0
                UserDataWriter.saveServerIndex(serverIndex)
                tapCnt = 0
                showDevAlert()
            }
        }
        else{
            tapCnt = 1
        }
        print(tapCnt)

        lastTapSec = now
    }

    private func showDevAlert()
    {
        let serverIndex = UserDataStore.getServerIndex()
        var message = ""

        if (tapCnt == 0)
        {
            if (serverIndex == 0)
            {
                message = "Congrats, you are back to being a regular joe!"
            }
            else
            {
                message = "Congrats, you are a developer!"
            }
        }
        else
        {
            if (serverIndex == 0)
            {
                message = "You are 2 taps away from becoming a developer"
            }
            else
            {
                message = "You are 2 taps away from becoming a regular joe"
            }
        }
        let devAlert = UIAlertController(title: "Dev Server Access", message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        devAlert.addAction(okAction)

        present(devAlert, animated: true, completion: nil)
    }
    
    private func configure()
    {
        headerScrollAdjuster = HeaderScrollAdjuster(headerImageView: headerImage,
                               headerHeightConstraint: headerHeightConstraint, headerDetailLabel: headerDetailLabel)
        configureTableView()
        
        editTableButton.titleLabel?.minimumScaleFactor = 0.5
        editTableButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func configureTableView()
    {
        tableView.backgroundColor = UIColor.clear
        editTableButton.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        let infoCellNib = UINib(nibName: "InfoCell", bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: "InfoCell")
        removeEmptyCellsAtBottomOfTable(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchAllCooksForUser()
    }
    
    fileprivate func fetchAllCooksForUser()
    {
        self.searchingForCooks = true
        self.reloadTableOnMainThread()
        FlameBossAPI.getUserCookHistory { (cooks: [Cook]?, error: Error?) in
            guard error == nil else
            {
                print("Error gettting cooks: \(String(describing: error?.localizedDescription))")
                self.searchingForCooks = false
                self.reloadTableOnMainThread()
                return
            }
            
            if let cooks = cooks
            {
                self.cookHistory.removeAll()
                
                if cooks.count <= 0
                {
                    self.searchingForCooks = false
                    DispatchQueue.main.async { self.editTableButton.isHidden = true }
                    self.reloadTableOnMainThread()
                    return
                }
                
                for cook in cooks { self.cookHistory.append(cook) }
                
                self.cookHistory.sort {$0.id > $1.id}
                self.searchingForCooks = false
                DispatchQueue.main.async { self.configureEditButton() }
                self.reloadTableOnMainThread()
            }
        }
    }
    
    fileprivate func configureEditButton()
    {
        if cookHistory.count > 0
        {
            editTableButton.isHidden = false
            editTableButton.isUserInteractionEnabled = true
        }
        else
        {
            editTableButton.isHidden = true
            editTableButton.isUserInteractionEnabled = false
            editTableButton.setTitle("Edit", for: .normal)
        }
    }
    
    private func reloadTableOnMainThread()
    {
        DispatchQueue.main.async
            { self.tableView.reloadData() }
    }
    
    fileprivate func showCookViewController(cook: Cook)
    {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let cookController = storyboard.instantiateViewController(withIdentifier: "CookViewController") as! CookViewController
        cookController.cook = cook
        
        navigationController?.pushViewController(cookController, animated: true)
    }
    
    @IBAction func editTableButtonPressed()
    {
        let title = tableView.isEditing ? "Edit" : "Done"
        editTableButton.setTitle(title, for: .normal)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

extension CookHistoryViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if cookHistory.count <= 0 { return 1 }
            
        else { return cookHistory.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if cookHistory.count > 0
        {
            let cook = cookHistory[indexPath.row]
            return cookCellForCook(cook)
        }
        
        else
        {
            return getInfoCell(searchingTitle: "Searching for your cook history",
                               notSearchingTitle: "No cook history found")
        }
    }
    
    private func cookCellForCook(_ cook: Cook) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookTableCell") as! CookTableCell
        cell.configureWithCook(cook)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func getInfoCell(searchingTitle: String, notSearchingTitle: String) -> UITableViewCell
    {
        var text = searchingTitle
        var searching = true
        
        if !searchingForCooks
        {
            text = notSearchingTitle
            searching = false
        }
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
        infoCell.configure(text: text, showLoadingIndicator: searching, showBorder: false)
        infoCell.selectionStyle = .none
        
        return infoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < cookHistory.count
        {
            let cook = self.cookHistory[indexPath.row]
            showCookViewController(cook: cook)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        // Only show the delete button on a swipe gesture if there are valid cooks to delete
        return (self.cookHistory.count > 0) ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let message = "Are you sure you want to permanently delete this cook?"
            let alertController = UIAlertController(title: "Delete Cook", message: message, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
                self.deleteCook(indexPath: indexPath)
            })
            
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
                self.animateDeleteButtonHiding()
                self.editTableButton.setTitle("Edit", for: .normal)
            })
            
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func deleteCook(indexPath: IndexPath)
    {
        let cook = cookHistory[indexPath.row]
        
        FlameBossAPI.deleteCook(cookID: UInt(cook.id)) { (error) in
            if error == nil
            {
                DispatchQueue.main.sync
                {
                    self.cookHistory.remove(at: indexPath.row)
                    
                    if self.cookHistory.count > 0 { self.tableView.deleteRows(at: [indexPath], with: .automatic) }
                    
                    else
                    {
                        self.configureEditButton()
                        self.tableView.setEditing(false, animated: false)
                        self.fetchAllCooksForUser()
                    }
                }
            }
            else
            {
                let alertController = UIAlertController(title: "Error Deleting Cook",
                                                        message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                    self.animateDeleteButtonHiding()
                })
                
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func animateDeleteButtonHiding()
    {
        self.tableView.beginUpdates()
        self.tableView.setEditing(false, animated: true)
        self.tableView.endUpdates()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        headerScrollAdjuster.updateHeaderForScrollView(scrollView)
    }
}
