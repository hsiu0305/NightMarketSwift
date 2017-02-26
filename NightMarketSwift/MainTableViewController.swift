//
//  MainTableViewController.swift
//  NightMarketSwift
//
//  Created by Hank on 2017/2/8.
//  Copyright © 2017年 Anderson. All rights reserved.
//

import UIKit



class MainTableViewController: UITableViewController {

    var totalNightMarketInfo = [[String]]()
    var nightMarketName = [String]()
    var filteredName = [String]()
    var showSearchResult = false
    
    @IBOutlet weak var slideBt: UIBarButtonItem!
    var searchVC : UISearchController!
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            slideBt.target = self.revealViewController()
            slideBt.action = #selector(SWRevealViewController.revealToggle(_:))
            //slideBt.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void) // Swift 3 fix
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.configureSearchController()
        
        self.addInfoFromPlist(fileName: "NorthInfo")
        self.addInfoFromPlist(fileName: "CenterInfo")
        self.addInfoFromPlist(fileName: "SouthInfo")
        self.addInfoFromPlist(fileName: "EastInfo")
        
        for info in totalNightMarketInfo {
            nightMarketName.append(info[0])
        }
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
    }
    
    func addInfoFromPlist(fileName: String) {
        
        let resultArr = self.plistArray(fileName: fileName)
        for items in (resultArr as? [[[String]]])! {
            for informations in items {
                
                totalNightMarketInfo.append(informations)
            }
        }
    }
    
    func plistArray(fileName: String) -> NSArray{
        
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        let fileArr = NSArray.init(contentsOfFile: path!)
        return fileArr!
    }
    
    func configureSearchController() {
        searchVC = UISearchController(searchResultsController: nil)
        searchVC.searchResultsUpdater = self
        //默认情况下，UISearchController暗化前一个view，这在我们使用另一个view controller来显示结果时非常有用，但当前情况我们并不想暗化当前view，即设置开始搜索时背景是否显示
        searchVC.dimsBackgroundDuringPresentation = false
        //设置definesPresentationContext为true，.hidesNavigationBarDuringPresentation = false
        //確保UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上。
        searchVC.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        searchVC.searchBar.placeholder = "夜市搜尋"
        searchVC.searchBar.delegate = self
        searchVC.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchVC.searchBar
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResult {
            return filteredName.count
        }else {
            return nightMarketName.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdenfifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdenfifier, for: indexPath)
        
        if showSearchResult {
            cell.textLabel?.text = filteredName[indexPath.row]
        }else {
            cell.textLabel?.text = nightMarketName[indexPath.row]
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        
        if showSearchResult {
            print("search")
            let selectedMarketIndex = nightMarketName.index(of: filteredName[indexPath.row])
            destVC.information = totalNightMarketInfo[selectedMarketIndex!]
        }else {
            print("normal")
            destVC.information = totalNightMarketInfo[indexPath.row]
            
        }
        searchVC.searchBar.resignFirstResponder()
        
        self.navigationController?.pushViewController(destVC, animated: true)
        
    }
    
}

extension MainTableViewController : UISearchResultsUpdating, UISearchBarDelegate {
    
    //点击搜索按钮，触发该代理方法，如果已经显示搜索结果，那么直接去除键盘，否则刷新列表
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("done bt clicked")

        if !showSearchResult {
            showSearchResult = true
            self.tableView.reloadData()
            searchVC.searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showSearchResult = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    
        showSearchResult = true
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // 取得搜尋文字
        guard let searchText = searchController.searchBar.text else {
            return
        }
        // 使用陣列的 filter() 方法篩選資料
        filteredName =  nightMarketName.filter({ (name) -> Bool in
            // 將文字轉成 NSString 型別
            let nameText : NSString = name as NSString
            
            // 比對這筆資訊有沒有包含要搜尋的文字
            return (nameText.range(of: searchText, options: .caseInsensitive).location) != NSNotFound
        })
        self.tableView.reloadData()
    }
    
}
