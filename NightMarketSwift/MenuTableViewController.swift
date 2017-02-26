//
//  MenuTableViewController.swift
//  NightMarketSwift
//
//  Created by Hank on 2017/2/9.
//  Copyright © 2017年 Anderson. All rights reserved.
//

import UIKit
import MessageUI

class MenuTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                print("open mail")
                let subject = "對夜市App的意見"
                let recepts = ["hsiu0305@gmail.com"]
                let mfMailVC = MFMailComposeViewController()
                mfMailVC.mailComposeDelegate = self
                mfMailVC.setSubject(subject)
                mfMailVC.setToRecipients(recepts)
                self.present(mfMailVC, animated: true, completion: nil)
            }
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let destVC = segue.destination
            let nextVC = destVC.childViewControllers.first as? LocationTableViewController
            if indexPath.section == 0 {
                switch indexPath.row {
  
                case 1:
                    nextVC!.title = "北部地區"
                    
                    break
                case 2:
                    nextVC!.title = "中部地區"
                    
                    break
                case 3:
                    nextVC!.title = "南部地區"
                    
                    break
                case 4:
                    nextVC!.title = "東部地區"
                    
                    break
                default:
                    break
                }
            }
            
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

}
