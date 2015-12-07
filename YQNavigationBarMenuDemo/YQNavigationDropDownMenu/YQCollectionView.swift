import UIKit

public protocol MenuItemType{
    var icon: String { get }
    var title: String { get }
}

public struct MenuItem: MenuItemType {
    public var icon: String
    public var title: String
}

class YQCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items: [MenuItemType]!
    var selectItemAtIndexPathHandler: ((indexPath: Int) -> ())?
    var configuration: DropDownMenuConfiguration!
    
    init(frame: CGRect, collectionViewLayout: UICollectionViewLayout, items: [MenuItemType], config: DropDownMenuConfiguration) {
        
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        
        configuration = config
        
        let nib = UINib(nibName: "YQCollectionViewCell", bundle: nil)
        registerNib(nib, forCellWithReuseIdentifier: YQCollectionViewCell.CellIdentifier)
        self.items = items
        dataSource = self
        delegate = self
        backgroundColor = configuration.menuBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UICollection View delegate and datasource
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectItemAtIndexPathHandler!(indexPath: indexPath.item)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(YQCollectionViewCell.CellIdentifier, forIndexPath: indexPath) as! YQCollectionViewCell
        cell.menuItem = items[indexPath.item]
        cell.configuration = configuration
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
}

class YQCollectionViewCell: UICollectionViewCell {
    
    static let CellIdentifier = "YQCollectionViewCell"
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var menuItem:MenuItemType!{
        didSet{
            //TODO: config subviews
            image.image = UIImage(named: menuItem.icon)
            title.text = menuItem.title
        }
    }
    
    var configuration:DropDownMenuConfiguration!{
        didSet{
            title.textColor = configuration.cellTextLabelColor
            title.font = configuration.cellTextLabelFont
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
}
