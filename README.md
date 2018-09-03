# TDTableViewHeaderPager


## Demo

![title](https://github.com/thedahiyaboy/TDTableViewHeaderPager/blob/master/Gifs/1.gif) ![title](https://github.com/thedahiyaboy/TDTableViewHeaderPager/blob/master/Gifs/2.gif)

## Overview
The basic moto of the project is to create horizontal scrollable header at the top of `UITableView` like a pager. Pager is managed with the header of the `UITableView` & vice-versa.

Description of the project is divided into two parts:
1. Identify the header cell of the `UITableView`.
2. Manage the pager with the `UITableView` header and manage header with the pager.

## Support
1. Swift 4.x
2. X-code 9.x

## Resources
I am using local json file as I am not calling any API and taking the entire data from this json for the dynamic feel of the project. Check the json structure from [here](https://github.com/thedahiyaboy/TDTableViewHeaderPager/blob/master/TDTableViewHeaderPager/TDTableViewHeaderPager/Resources/data.json).

## Description
### Part 1. Identify the header cell of the `UITableView`.

#### Properties

```
@IBOutlet weak var pagerTableView: UITableView!

var localJsonData : [Any] = [] // contains jsonData
var allCellMetadata : [CellMetadata] = [] // contains metadata of all cells

var selectctedIndex = 0 // current selected index. Default is 0
var previousSelectctedIndex = 0 // last selected index. Default is 0
var currentIndexPath : IndexPath = IndexPath(row: 0, section: 0) // current indexPath of tableview. Default is row: 0 & section: 0
    
```  
#### Logic Content

- **In `ViewDidLoad`, call the below functions**
```
getLocalJsonData()
setupMetadata()
initilaizer()
```

- **Get the data from the localJson**

```
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
```

- **Setup metadata to maintain the index, section, row for every cell and it contains the bool to check whether the cell is header or not. I am not using `viewForHeaderInSection` as in this case header will sticked to the top but our requirement is to create header of pager & in `UITableView` header will always move like a cell. So don't forget to take another cell for the header.**


```
func setupMetadata() {
    
    var index = 0  // 1
    for section in 0...localJsonData.count-1 {
        
        // 2
        let metadataSection = CellMetadata(index: index, section: section, row: -1, isHeader: true)
        allCellMetadata.append(metadataSection)
        index += 1
        
        // 3
        let sectionData = localJsonData[section] as! [String : Any]
        let rowData = sectionData["data"] as! [Any]
        
        // 4
        if rowData.isEmpty{
            continue
        }
        
        // 5
        for row in 0...rowData.count-1{
            let metadataRow = CellMetadata(index: index, section: section, row: row, isHeader: false)
            allCellMetadata.append(metadataRow)
            index += 1
        }
    }
}

```

1. Index of every cell a/c in the `UITableViewCell`. Whenever metadata is added in allCellMetadata, it should be incremented. 
2. Json have two loops. First for-loop always gives the header. Set the meta data for header & add in allCellMetadata.
3. Parsing the jsondata to get the second loop of data.
4. If there is no data in the second loop then we don't need to loop so we can jump to the section.
5. Set the meta data of every row of that section.

- **Now create a new file with name `CellMetadata` and paste this below struct.**

```
struct CellMetadata {
    let index : Int // 1
    let section : Int // 2
    let row : Int //  3
    let isHeader : Bool // 4
}
```
1. It notifies the position of cell in the tableview.
2. Notifies cell have which section. 
3. Notifies cell offset position in its section. If cell is header then row is -1 as header is not the offset postion of anyother header.
4. Is the cell at the index postion is header or not.

- **Now binds the datasource and delegates of UITableView and reload your UITableView .**
```
func initilaizer()  {
    pagerTableView.dataSource = self
    pagerTableView.delegate = self
    pagerTableView.reloadData()
}
```

- **Now time to set the `UITableView` datasource.**

```
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allCellMetadata.count
}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // 1
    let aMetadata = allCellMetadata[indexPath.row]
        
    if aMetadata.isHeader {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        
        // 2
       let dataAll = localJsonData[aMetadata.section] as! [String : Any]
       cell.title.text = dataAll["title"] as? String
            
       return cell
    }
    else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
            
        // 3
        let dataAll = localJsonData[aMetadata.section] as! [String : Any]
        let contentData = dataAll["data"] as! [Any]
        let rowData = contentData[aMetadata.row] as! [String : Any]
            
       cell.title.text = "\(rowData["dish"]!)"
       cell.detail.text = "\(rowData["price"]!)"        
       return cell
    }        
}
```
1. First get the  cell metadata & check which type of cell it is either it is header or not.  As we managing the cell metadata a/c to the json data now we fetch the data from json by using metadata.
2. Get data from local json for section.
3. Get data from local json & parse the data for row.

- **Now time to identify selected header. `UITableView` is the sub class of `UIScrollView` so we use the `scrollViewDidScroll` delegate method.**

 ```   
func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    // 1
    let visibleCells = pagerTableView.visibleCells
        
    for cell in visibleCells {
        // 2
        let offset = cell.frame.origin.y - scrollView.contentOffset.y
        
        // 3
        let indexPath = pagerTableView.indexPath(for: cell)
        
        // 4
        let isHeader = allCellMetadata[(indexPath?.row)!].isHeader
            
        if isHeader {
           // 5
           if let index = allCellMetadata.index(where: { $0.index == indexPath?.row }) {
               
               // 6
               let section =  allCellMetadata[index].section
               
                // 7
               if offset <= 20 && offset >= -20{
                   selectctedIndex = section
                   currentIndexPath = indexPath!
                }
                else if offset  > 20 {
                    // 8
                    if currentIndexPath == indexPath {
                        selectctedIndex = section - 1
                        
                        // 9
                        if selectctedIndex < 0 {
                            selectctedIndex = 0
                        }
                    }
                }
            }                
        }
        print("Selected Index: \(selectctedIndex)")
    } 
}
```

1. Get all visible cells of tableview.
2. Offset is the difference b/w cell y position & scrollview content offset y position. It is used to check the header postion from the top.
3. Get the indexPath of cell from UITableViewCell.
4. Check current cell is header or not.
5. Get index of header in cells metadata if index is available.
6. Get the section of the header.
7. If offset is b/w 20 to -20 then make it current selected index otherwise previous index as selected index.
8. If header is the current selected index & offset is greater than 20 then make the previous index as selected index. It might be possible there are multiple headers in the so we only manipulate the header which is near to the top point of the cell.
9. UITableViewCell never be in negative so prevention for 0 index cell.
10. Prints the current selected index.

### Part 2. Manage the pager with the UITableView header and manage header with the pager.
#### Properties

Now add the below properties in the existing ViewController.

```
@IBOutlet weak var pagerCollectionView: UICollectionView!
    
var floatingViewUnderline = UIView() // underline floating View
```

#### Logic Content

- **Set the `numberOfItemsInSection` of `UICollectionView`.**

```
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return localJsonData.count // 1
}
```
1. Total cells of the `UICollectionView` is the total header in the jsonData which is the total count of the jsonData.

- **Now  set `cellForItemAt` of `UICollectionView`.**

```
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagerCell", for: indexPath) as! PagerCell
    
    let data = localJsonData[indexPath.row] as! [String : Any]
    
    cell.title.text = data["title"] as? String
    
    if selectctedIndex == indexPath.row {
        cell.title.textColor = UIColor.black
        self.setfloatingViewUnderline(at: cell.frame) 
    }
    else {
        cell.title.textColor = UIColor.black
    }
    
    return cell
}
```

- **Create a new file `String+Extension` & paste below function. It calculates the width of the string with the given font.**

```
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
```

- **Now use `UICollectionViewDelegateFlowLayout` to set the size of the UICollectionView.**

```
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    // 1
    let data = localJsonData[indexPath.row] as! [String : Any]
    let atext = data["title"] as! String
    // 2
    let width = atext.widthOfString(usingFont: UIFont.systemFont(ofSize: 15))
    return CGSize(width: width , height: 40)
}

```
1. Get the string of header.
2. Calculate with of th string so that cell width be according to the string size.

- **Now use below code in `cellForItemAt`.**

```
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagerCell", for: indexPath) as! PagerCell
    
    // 1
    let data = localJsonData[indexPath.row] as! [String : Any]
    
    // 2
    cell.title.text = data["title"] as? String
    cell.title.textColor = UIColor.black

    if selectctedIndex == indexPath.row {

        self.setfloatingViewUnderline(at: cell.frame) // 3
    }
    
    return cell
}
```

1. Get the data from the local json data.
2. Set label text for the cell heaer.
3. If your cell is the selected cell then we have to animate floatingView for that cell. 

- **`setfloatingViewUnderline` is simple function which animanate the floating view for 0.3 sec from the previous cell to the current selected cell.**

```
func setfloatingViewUnderline(at frame : CGRect)  {
    
    UIView.animate(withDuration: 0.3) {
        self.floatingViewUnderline.frame = CGRect(x: frame.origin.x ,
                                                  y: frame.size.height - 5,
                                                  width: frame.size.width ,
                                                  height: 5)
    }
}
```


- **Now replace the `scrollViewDidScroll` with below code.**

```
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // 1
    if scrollView == pagerCollectionView {
        return
    }
    
    
    let visibleCells = pagerTableView.visibleCells
    
    for cell in visibleCells {
        
        let offset = cell.frame.origin.y - scrollView.contentOffset.y
        let indexPath = pagerTableView.indexPath(for: cell)
        let isHeader = allCellMetadata[(indexPath?.row)!].isHeader
        
        if isHeader {
            
            if let index = allCellMetadata.index(where: { $0.index == indexPath?.row }) {
                
                let section =  allCellMetadata[index].section
                
                if offset <= 20 && offset >= -20{
                    selectctedIndex = section
                    currentIndexPath = indexPath!
                }
                else if offset  > 20 {
                    
                    if currentIndexPath == indexPath {
                        selectctedIndex = section - 1
                        if selectctedIndex < 0 {
                            selectctedIndex = 0
                        }
                    }
                }
            }
            
            // 2
            if previousSelectctedIndex != selectctedIndex {
                self.moveToIndex()
            }
        } 
    }
}
```

1. `scrollViewDidScroll` is called for the `UICollectionView` & `UITableView`. We have prevent this delegate method for the `UICollectionView` as have nothing to do is this case.
2. `scrollViewDidScroll` called for every single point for which `UITableView` is chnages and we need to move the header only when our header is changed.


- **Move the `UICollectionView` to the selected index.**

```
func moveToIndex(){
    // 1
    if selectctedIndex > localJsonData.count - 1 || selectctedIndex < 0{
        return
    }
    
    // 2
    pagerCollectionView.reloadData()
    pagerCollectionView.scrollToItem(at: IndexPath(item: selectctedIndex, section: 0), at: .centeredHorizontally, animated: true)
    previousSelectctedIndex = selectctedIndex
}
```

1. Prevent the if our selected indx is out of bounce.
2. Reload our `UICollectionView` and scroll `UICollectionView` to the selected index. Here I used `centeredHorizontally` so that selected index will always be in the middle of the screen.

- **Now we have to add functionality where if user clicks on any header then the UITableView header will moves to top of the `UITableView`. Add below delegate of `UICollectionView`**

```
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let aInt = indexPath.row
    
    // 1
    if aInt > localJsonData.count-1 || aInt < 0{
        return
    }
    selectctedIndex = aInt
    
    // 2
    moveToIndex()
    
    // 3
    let arrIndex = self.allCellMetadata.filter({$0.section == indexPath.row})
    let aindex = arrIndex.first?.index
    pagerTableView.scrollToRow(at: IndexPath(row: aindex!, section: 0), at: .top, animated: true)
}
```
1. Prevent the project to get out of bound.
2. Move the `UICollectionView` for the selected index.
3. Move the `UITableView` for the selected index. I used `.top` so that selected header will shown be at the top of the `UITableView`.

- **Now our project is ready but to make it litle more attractive I just added shadow at `UICollectionView`. Now make just do litle more change.**

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    :
    :
    
    addShadow()
}

func addShadow(){
    pagerCollectionView.layer.shadowColor = UIColor.darkGray.cgColor
    pagerCollectionView.layer.shadowRadius = 10
    pagerCollectionView.layer.shadowOpacity = 0.2
    pagerCollectionView.layer.shadowOffset = CGSize(width: 0, height: 30)
    pagerCollectionView.clipsToBounds = false
    pagerCollectionView.layer.masksToBounds = false
}
```

