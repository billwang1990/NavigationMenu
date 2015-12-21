
import UIKit

public class YQNavigationDropDownMenu: UIView, UINavigationControllerDelegate {
    
    private var cellTextLabelColor: UIColor {
        get {
            return configuration.cellTextLabelColor
        }
        set(val) {
            configuration.cellTextLabelColor = val
        }
    }
    
    private var cellTextLabelFont: UIFont {
        get {
            return configuration.cellTextLabelFont
        }
        set(val) {
            configuration.cellTextLabelFont = val
        }
    }
    
    private var animationDuration: NSTimeInterval {
        get {
            return configuration.animationDuration
        }
        set(val) {
            configuration.animationDuration = val
        }
    }
    
    private var maxItemsPerRow: Int {
        get {
            return configuration.maxItemsPerRow
        }
        set(val) {
            configuration.maxItemsPerRow = val
        }
    }
    
    private var arrowImage: UIImage {
        get {
            return configuration.arrowImage
        }
        set(val) {
            configuration.arrowImage = val
        }
    }
    
    private var arrowPadding: CGFloat {
        get {
            return configuration.arrowPadding
        }
        set(val) {
            configuration.arrowPadding = val
        }
    }
    
    private var maskBackgroundOpacity: CGFloat {
        get {
            return configuration.maskBackgroundOpacity
        }
        set(val) {
            configuration.maskBackgroundOpacity = val
        }
    }
    
    private var menuBackgroundColor: UIColor {
        get {
            return configuration.menuBackgroundColor
        }
        set(val) {
            configuration.menuBackgroundColor = val
        }
    }
    
    private var navigationController: UINavigationController?
    private var menuButton: UIButton!
    private var menuTitle: UILabel!
    private var menuArrow: UIImageView!
    private var backgroundView: UIView!
    private var configuration: DropDownMenuConfiguration
    private var collectionView: YQCollectionView!
    private var items: [MenuItemType]!
    private var isShown: Bool!
    private var menuWrapper: UIView!
    private var collectionViewHeight: CGFloat = 0
    private weak var realNavControllerDelegate: UINavigationControllerDelegate?
    
    public var didSelectItemAtIndexHandler: ((index: Int) -> ())?
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(title: String, items: [MenuItemType], navigationController: UINavigationController, configuration:DropDownMenuConfiguration = DropDownMenuConfiguration.shareInstance) {
        // Navigation controller
        self.navigationController = navigationController
        
        // Setup configuration
        self.configuration = configuration
        
        // Get titleSize
        let titleSize = (title as NSString).sizeWithAttributes([NSFontAttributeName:configuration.cellTextLabelFont])
        
        // Set frame
        let frame = CGRectMake(0, 0, titleSize.width + (configuration.arrowPadding + configuration.arrowImage.size.width)*2, self.navigationController!.navigationBar.frame.height)
        
        super.init(frame:frame)
        
        self.realNavControllerDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = self
        self.navigationController?.view.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        
        isShown = false
        self.items = items
        
        setupButtonAndTitle(title)
        setupDropDownMenu()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            // Set up DropdownMenu
            menuWrapper.frame.origin.y = navigationController!.navigationBar.frame.maxY
            collectionView.reloadData()
        }
    }
    
    override public func layoutSubviews() {
        menuTitle.sizeToFit()
        menuTitle.center = CGPointMake(frame.size.width/2, frame.size.height/2)
        menuArrow.sizeToFit()
        menuArrow.center = CGPointMake(CGRectGetMaxX(menuTitle.frame) + arrowPadding, frame.size.height/2)
    }
    
    func setupButtonAndTitle(title:String) {
        // Init button as navigation title
        menuButton = UIButton(frame: frame)
        menuButton.addTarget(self, action: "menuButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(menuButton)
        
        menuTitle = UILabel(frame: frame)
        menuTitle.text = title
        if let titleColor =  navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor {
            menuTitle.textColor = titleColor
        }
        menuTitle.textAlignment = NSTextAlignment.Center
        menuTitle.font = cellTextLabelFont
        menuButton.addSubview(menuTitle)
        
        menuArrow = UIImageView(image: arrowImage)
        menuButton.addSubview(menuArrow)
    }
    
    func setupDropDownMenu() {
        let window = UIApplication.sharedApplication().delegate!.window!
        let menuWrapperBounds = window!.bounds
        
        // Set up DropdownMenu
        menuWrapper = UIView(frame: CGRectMake(menuWrapperBounds.origin.x, 0, menuWrapperBounds.width, menuWrapperBounds.height))
        menuWrapper.clipsToBounds = true
        menuWrapper.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        
        // Init background view (under table view)
        backgroundView = UIView(frame: menuWrapperBounds)
        backgroundView.backgroundColor = .blackColor()
        backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        
        // Init collection view
        let itemWidth = (menuWrapperBounds.width - 30 ) / CGFloat(maxItemsPerRow)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(itemWidth, itemWidth)
        layout.minimumInteritemSpacing = 0
        
        if items.count < maxItemsPerRow {
            layout.minimumInteritemSpacing = (menuWrapperBounds.width - 20 - itemWidth * CGFloat(items.count)) / CGFloat(items.count - 1)
        } else {
            layout.minimumInteritemSpacing = 1
        }
        layout.minimumLineSpacing = 5
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        var rows = CGFloat(items.count / maxItemsPerRow)
        rows = rows + (items.count % maxItemsPerRow > 0 ? 1 : 0)
        collectionViewHeight = (rows * itemWidth) + (rows + 1) * layout.minimumLineSpacing + 20
        
        collectionView = YQCollectionView(frame:  CGRectMake(menuWrapperBounds.origin.x, menuWrapperBounds.origin.y, menuWrapperBounds.width, collectionViewHeight), collectionViewLayout: layout, items: items, config: configuration)
        
        collectionView.selectItemAtIndexPathHandler = {[unowned self] (index: Int) -> () in
            self.didSelectItemAtIndexHandler!(index: index)
            self.menuTitle.text = self.items[index].title
            self.hideMenu()
            self.isShown = false
            self.layoutSubviews()
        }
        
        // Add background view & table view to container view
        menuWrapper.addSubview(backgroundView)
        menuWrapper.addSubview(collectionView)
        
        // Add Menu View to container view
        window!.addSubview(menuWrapper)
        
        // By default, hide menu view
        menuWrapper.hidden = true
    }
    
    func showMenu() {
        
        window!.bringSubviewToFront(menuWrapper)
        
        menuWrapper.frame.origin.y = navigationController!.navigationBar.frame.maxY
        
        // Rotate arrow
        rotateArrow()
        
        // Visible menu view
        menuWrapper.hidden = false
        
        // Change background alpha
        backgroundView.alpha = 0
        
        // Animation
        collectionView.frame.origin.y = -collectionView.frame.height
        
        // Reload data to dismiss highlight color of selected cell
        collectionView.reloadData()
        
        UIView.animateWithDuration(
            animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: { [unowned self] in
                self.collectionView.frame.origin.y = CGFloat(0)
                self.backgroundView.alpha = self.maskBackgroundOpacity
            }, completion: {[unowned self] _ in
                self.menuButton.enabled = true
            }
        )
    }
    
    func hideMenu() {
        
        // Rotate arrow
        rotateArrow()
        
        // Change background alpha
        backgroundView.alpha = maskBackgroundOpacity
        
        UIView.animateWithDuration(
            animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: { [unowned self] in
                self.collectionView.frame.origin.y = CGFloat(50)
            }, completion: nil
        )
        
        // Animation
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {[unowned self] in
            self.collectionView.frame.origin.y = -self.collectionViewHeight
            self.backgroundView.alpha = 0
            }, completion: {[unowned self] _ in
                self.menuWrapper.hidden = true
                self.menuButton.enabled = true
            })
    }
    
    func rotateArrow() {
        UIView.animateWithDuration(animationDuration, animations: {[unowned self] () -> () in
            self.menuArrow.transform = CGAffineTransformRotate(self.menuArrow.transform, 180 * CGFloat(M_PI/180))
            })
    }
    
    func menuButtonTapped(sender: UIButton) {
        isShown = !isShown
        self.menuButton.enabled = false
        if isShown == true {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    //NavigationController delegate
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if isShown == true {
            hideMenu()
        }
        if let _  = realNavControllerDelegate {
            realNavControllerDelegate?.navigationController?(navigationController, willShowViewController: viewController, animated: animated)
        }
    }
}

