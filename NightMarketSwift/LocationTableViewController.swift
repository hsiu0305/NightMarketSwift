//
//  LocationTableViewController.swift
//  NightMarketSwift
//
//  Created by Hank on 2017/2/9.
//  Copyright © 2017年 Anderson. All rights reserved.
//

import UIKit

//
//Mark -Section Data Structure
//

struct Section {
    var name: String!
    var items: [[String]]!
    var collapsed : Bool!
    init(name: String, items:[[String]], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
    
}

class LocationTableViewController: UITableViewController {
    
    var sections = [Section]()
    var dataArr = [[[String]]]()
    var sectionArr = [String]()
    var expandedSections = NSMutableIndexSet()
    
    @IBOutlet weak var slideBt: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            slideBt.target = self.revealViewController()
            slideBt.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialize the sections array
        switch self.navigationItem.title! {
        case "北部地區":
            dataArr = self.dataFromPlistFile(fileName: "NorthInfo")
            sectionArr = ["基隆市","臺北市","新北市","桃園市","新竹市","新竹縣"]
            sections = [
                Section(name: "基隆市", items: dataArr[0]),
                Section(name: "臺北市", items: dataArr[1]),
                Section(name: "新北市", items: dataArr[2]),
                Section(name: "桃園市", items: dataArr[3]),
                Section(name: "新竹市", items: dataArr[4]),
                Section(name: "新竹縣", items: dataArr[5])
            ]
            break
        case "中部地區":
            dataArr = self.dataFromPlistFile(fileName: "CenterInfo")
            sectionArr = ["苗栗縣","臺中市","彰化縣","南投縣","雲林縣"]
            sections = [
                Section(name: "苗栗縣", items: dataArr[0]),
                Section(name: "臺中市", items: dataArr[1]),
                Section(name: "彰化縣", items: dataArr[2]),
                Section(name: "南投縣", items: dataArr[3]),
                Section(name: "雲林縣", items: dataArr[4])
            ]
            break
        case "南部地區":
            dataArr = self.dataFromPlistFile(fileName: "SouthInfo")
            sectionArr = ["嘉義市","嘉義縣","臺南市","高雄市","屏東縣","澎湖縣"]
            sections = [
                Section(name: "嘉義市", items: dataArr[0]),
                Section(name: "嘉義縣", items: dataArr[1]),
                Section(name: "臺南市", items: dataArr[2]),
                Section(name: "高雄市", items: dataArr[3]),
                Section(name: "屏東縣", items: dataArr[4]),
                Section(name: "澎湖縣", items: dataArr[5])
            ]
            break
        case "東部地區":
            dataArr = self.dataFromPlistFile(fileName: "EastInfo")
            sectionArr = ["宜蘭縣","花蓮縣","臺東縣"]
            sections = [
                Section(name: "宜蘭縣", items: dataArr[0]),
                Section(name: "花蓮縣", items: dataArr[1]),
                Section(name: "臺東縣", items: dataArr[2])
            ]
            break
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func dataFromPlistFile(fileName: String) ->[[[String]]] {
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        return (NSArray.init(contentsOfFile: path!))! as! [[[String]]]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Lcell", for: indexPath)
        
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row][0]

        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].collapsed! ? 0 : 44.0
    }
    
    // Header
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(collapsed: sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        destVC.information = sections[indexPath.section].items[indexPath.row]
        self.navigationController?.pushViewController(destVC, animated: true)
    }

}

//
// MARK: - Section Header Delegate
//
extension LocationTableViewController : CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed: collapsed)
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {

            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
}

