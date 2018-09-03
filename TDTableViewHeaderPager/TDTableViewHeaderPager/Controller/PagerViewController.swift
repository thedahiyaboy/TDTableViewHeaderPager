//
//  PagerViewController.swift
//  TDTableViewHeaderPager
//
//  Created by Tinu Dahiya on 30/08/18.
//  Copyright © 2018 dahiyaboy. All rights reserved.
//

import UIKit

class PagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var pagerTableView: UITableView!
    @IBOutlet weak var pagerCollectionView: UICollectionView!
    
    var floatingViewUnderline = UIView() // underline floating View
    var localJsonData : [Any] = [] // contains jsonData
    var allCellMetadata : [CellMetadata] = [] // contains metadata of all cells
    var selectctedIndex = 0 // current selected index
    var previousSelectctedIndex = 0 // last selected index
    var currentIndexPath : IndexPath = IndexPath(row: 0, section: 0) // current indexPath
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocalJsonData()
        setupMetadata()
        initilaizer()
        
        floatingViewUnderline.layer.cornerRadius = 1
        floatingViewUnderline.backgroundColor = UIColor.black
        self.pagerCollectionView.addSubview(floatingViewUnderline)
        
        addShadow()
    }
    
    // MARK: - Methods
    // MARK: -
    
    func addShadow(){
        pagerCollectionView.layer.shadowColor = UIColor.darkGray.cgColor
        pagerCollectionView.layer.shadowRadius = 10
        pagerCollectionView.layer.shadowOpacity = 0.2
        pagerCollectionView.layer.shadowOffset = CGSize(width: 0, height: 30)
        pagerCollectionView.clipsToBounds = false
        pagerCollectionView.layer.masksToBounds = false
    }
    
    func getLocalJsonData()  {
        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let result = jsonResult["Result"] as? [Any] {
                    self.localJsonData = result
                }
            } catch {
                // handle error
            }
        }
    }
    
    /// Setup the metadata of everycell
    func setupMetadata() {
        
        var index = 0
        for section in 0...localJsonData.count-1 {
            
            // for header
            let metadataSection = CellMetadata(index: index, section: section, row: -1, isHeader: true)
            allCellMetadata.append(metadataSection)
            index += 1
            
            let sectionData = localJsonData[section] as! [String : Any]
            let rowData = sectionData["data"] as! [Any]
            
            if rowData.isEmpty{
                continue
            }
            
            // for each row
            for row in 0...rowData.count-1{
                let metadataRow = CellMetadata(index: index, section: section, row: row, isHeader: false)
                allCellMetadata.append(metadataRow)
                index += 1
            }
        }
    }
    
    /// Binds delegates & datasource
    func initilaizer()  {
        pagerTableView.dataSource = self
        pagerTableView.delegate = self
        pagerCollectionView.delegate = self
        pagerCollectionView.dataSource = self
        pagerTableView.reloadData()
    }
    
    /// Set floating view for selected header
    ///
    /// - Parameters:
    ///   - frame: to set position of floatingViewUnderline
    func setfloatingViewUnderline(at frame : CGRect)  {
        
        UIView.animate(withDuration: 0.3) {
            self.floatingViewUnderline.frame = CGRect(x: frame.origin.x ,
                                                      y: frame.size.height - 5,
                                                      width: frame.size.width ,
                                                      height: 5)
        }
    }
    
    /// Move collectionView to selected index
    func moveToIndex(){
        if selectctedIndex > localJsonData.count - 1 || selectctedIndex < 0{
            return
        }
        
        pagerCollectionView.reloadData()
        pagerCollectionView.scrollToItem(at: IndexPath(item: selectctedIndex, section: 0), at: .centeredHorizontally, animated: true)
        previousSelectctedIndex = selectctedIndex
    }
    
    // MARK: - ScrollView
    // MARK: -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // if scroller is collectionview then return
        if scrollView == pagerCollectionView {
            return
        }
        
        // Get all visible cells of tableview
        let visibleCells = pagerTableView.visibleCells
        
        for cell in visibleCells {
            // difference b/w cell y position & scrollview content offset y position.
            // It is used to check the header postion from the top.
            let offset = cell.frame.origin.y - scrollView.contentOffset.y
            let indexPath = pagerTableView.indexPath(for: cell)
            let isHeader = allCellMetadata[(indexPath?.row)!].isHeader
            
            if isHeader {
                // Get index of header in cells metadata
                if let index = allCellMetadata.index(where: { $0.index == indexPath?.row }) {
                    // Get the section of the header.
                    let section =  allCellMetadata[index].section
                    // if offset is b/w 20 to -20 then make it current selected index otherwise previous index as selected index.
                    if offset <= 20 && offset >= -20{
                        selectctedIndex = section
                        currentIndexPath = indexPath!
                    }
                    else if offset  > 20 {
                        // if header is the current selected index & offset is greater than 20 then make the previous index as selected index.
                        if currentIndexPath == indexPath {
                            selectctedIndex = section - 1
                            if selectctedIndex < 0 {
                                selectctedIndex = 0
                            }
                        }
                    }
                }
                
                // Move the collectionView to the selected indexpath
                if previousSelectctedIndex != selectctedIndex {
                    DispatchQueue.main.async {
                        self.moveToIndex()
                    }
                }
                
            } // ISHEADER Ends
        }
    }
    
    // MARK: - TableView
    // MARK: -
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCellMetadata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aMetadata = allCellMetadata[indexPath.row]
        
        if aMetadata.isHeader {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
            
            // Get data from local json from section
            let dataAll = localJsonData[aMetadata.section] as! [String : Any]
            cell.title.text = dataAll["title"] as? String
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
            
            // Get data from local json
            let dataAll = localJsonData[aMetadata.section] as! [String : Any]
            let contentData = dataAll["data"] as! [Any]
            let rowData = contentData[aMetadata.row] as! [String : Any]
            
            cell.title.text = "\(rowData["dish"]!)"
            cell.detail.text = "\(rowData["price"]!)"
            
            return cell
        }
        
    }
}

// MARK: - CollectionView
// MARK: -
extension PagerViewController :  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = localJsonData[indexPath.row] as! [String : Any]
        let atext = data["title"] as! String
        
        let width = atext.widthOfString(usingFont: UIFont.systemFont(ofSize: 15))
        return CGSize(width: width , height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localJsonData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagerCell", for: indexPath) as! PagerCell
        
        let data = localJsonData[indexPath.row] as! [String : Any]
        
        cell.title.text = data["title"] as? String
        cell.title.textColor = UIColor.black
        
        if selectctedIndex == indexPath.row {
            self.setfloatingViewUnderline(at: cell.frame)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aInt = indexPath.row
        
        if aInt > localJsonData.count-1 || aInt < 0{
            return
        }
        selectctedIndex = aInt
        
        // move collectionView to selected Index
        moveToIndex()
        
        // Move tableView to selected index
        let arrIndex = self.allCellMetadata.filter({$0.section == indexPath.row})
        let aindex = arrIndex.first?.index
        pagerTableView.scrollToRow(at: IndexPath(row: aindex!, section: 0), at: .top, animated: true)
    }
    
}
