import UIKit

public protocol SimpleCollectionViewLayoutDelegate {
    func size(for indexPath: IndexPath) -> CGSize
}

/// A simple wrapper around `UICollectionView` that supports a single section and rapid data changes without having to use DiffableDataSource.
/// The main advantage of this is the ease of setup and overall ergonomics. To create a `UICollectionView`,
/// declare an instance of this class while passing in the intended view to be used as a cell in the generic paramter.
/// The class will take care of the rest as you update it's `elements` array which should contain models used
/// to "hydrate" the cells. Supoorts prefetching. Does not support multiple sections or drag & drop (yet).
///
/// Example of use:
/// ```
/// let collectionView = SimpleCollectionView<MyCellView>()
/// ...
/// // assuming MyCellView requires Int
/// collectionView.elements = [1,2,3]
/// ```
/// The interface for cell customization is fulfilled by a series of delcarative remote actions (escaping functions).
/// They are as follows:
/// ```
/// var cellAtIndexPath: Remote2DTypedAction<T, IndexPath>?
/// var cellWillAppear: Remote2DTypedAction<T, IndexPath>?
/// var cellDidDisappear: Remote2DTypedAction<T, IndexPath>?
/// var cellSelected: Remote2DTypedAction<T, IndexPath>?
/// var cellFocused: Remote2DTypedAction<T, IndexPath>?
/// var cellDefocused: Remote2DTypedAction<T, IndexPath>?
/// var cellRepositioned: Remote2DTypedAction<T, IndexPath>?
/// ```
/// For dynamic cell sizing, implement the delegate `SimpleCollectionViewLayoutDelegate`
///
/// Because this is buitl on top of `UICollectionView` itself, you can take over it's functions and use it like a normal `UICollectionView`.
open class SimpleCollectionView<T: Hydratable & UIView>:
    UICollectionView,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIScrollViewDelegate,
    UICollectionViewDataSourcePrefetching
//    UICollectionViewDragDelegate,
//    UICollectionViewDropDelegate
{
    typealias ContainerCell = ViewContainerCollectionViewCell<T>
    
    private var performingAutomaticUpdates = false
    
    public var approachingEnd: RemoteAction?
    
    public var cellAtIndexPath: Remote2DTypedAction<T, IndexPath>?
    public var cellWillAppear: Remote2DTypedAction<T, IndexPath>?
    public var cellDidDisappear: Remote2DTypedAction<T, IndexPath>?
    
    public var cellSelected: Remote2DTypedAction<T, IndexPath>?
    public var cellFocused: Remote2DTypedAction<T, IndexPath>?
    public var cellDefocused: Remote2DTypedAction<T, IndexPath>?
    public var cellRepositioned: Remote2DTypedAction<T, IndexPath>?
    
    public var prefetchAction: RemoteTypedAction<[IndexPath]>? {
        didSet { prefetchDataSource = self }
    }
    
    public var prefetchCancellation: RemoteTypedAction<[IndexPath]>?
    
    public var elements: [T.ModelType] {
        didSet {
            if !performingAutomaticUpdates {
                reloadData()
                layoutIfNeeded()
            }
        }
    }
    
    public var layoutDelegate: SimpleCollectionViewLayoutDelegate?
    public var staticCellSize: CGSize?
    
    // to be clear, this is not the BEST way of doing this, but it
    public var headerView: UICollectionReusableView? {
        didSet {
            register(UICollectionReusableView.self,
                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                     withReuseIdentifier: "header")
            reloadData()
        }
    }
    
    public var footerView: UICollectionReusableView? {
        didSet {
            register(UICollectionReusableView.self,
                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                     withReuseIdentifier: "header")
            reloadData()
        }
    }
    
    public init(elements: [T.ModelType] = [],
         layout: UICollectionViewLayout = UICollectionViewFlowLayout(),
         backgroundColor: UIColor = .clear,
         decelerationRate: UIScrollView.DecelerationRate = .normal,
         contentInset: UIEdgeInsets = .zero,
         staticCellSize: CGSize? = nil
    ) {
        self.elements = elements
        super.init(frame: .zero, collectionViewLayout: layout)
        register(ContainerCell.self, forCellWithReuseIdentifier: ContainerCell.identifier)
        dataSource = self
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        self.backgroundColor = backgroundColor
        self.decelerationRate = decelerationRate
        self.contentInset = contentInset
        clipsToBounds = false
        self.staticCellSize = staticCellSize
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// A declarative method for updating elements of the collection view at the specified indices. Using this method will animate the changes at specific rows
    /// as opposed to replacing the data wholesale by assigning to the `elements` array.
    ///
    /// This method works by taking the provided indices, and mapping the elements you want to update, sequentially populating the internal `elements` array,
    ///
    /// - Parameters:
    ///   - rows: An array of `Int` values representing the rows to be updated. Since `SimpleCollectionView` only supports a single section,
    ///   this method will assign a section value of `0` for all indices provided.
    ///   - newElements: An array containing the data that needs to be updated. The underlying type, `T.ModelType` is the type of the model
    ///   used to "hydrate" the cells.
    public func update(at rows: [Int], with newElements: [T.ModelType]) {
        performingAutomaticUpdates = true
        var newElements = Array(newElements.reversed())
        let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
        for row in rows {
            if let newElement = newElements.popLast() {
                elements[row] = newElement
            }
        }
        insertItems(at: indexPaths)
        performingAutomaticUpdates = false
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return staticCellSize ?? layoutDelegate?.size(for: indexPath) ?? .zero
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        contentInset
    }
    
    // MARK: - UICollectionViewDelegate

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? ContainerCell else { return }
        cellWillAppear?(cell.mainView, indexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? ContainerCell else { return }
        cellDidDisappear?(cell.mainView, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchAction?(indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetchCancellation?(indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContainerCell else { return }
        cellSelected?(cell.mainView, indexPath)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return headerView ?? UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            return footerView ?? UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == elements.count - 3 {
            approachingEnd?()
        }
        
        let target = elements[indexPath.row]
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: ContainerCell.identifier,
            for: indexPath
        ) as? ContainerCell else { return UICollectionViewCell() }
        cell.tag = indexPath.row
        cell.hydrate(with: target)
        cellAtIndexPath?(cell.mainView, indexPath)
        return cell
    }
    
//    // MARK: - UICollectionViewDragDelegate - TBD
//
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        <#code#>
//    }
//
//    // MARK: - UICollectionViewDropDelegate
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        <#code#>
//    }
}

public extension SimpleCollectionView {
    
    enum SpotlightStyle {
        case dim
        case blur
    }
    
    func spotlightCell(at indexPath: IndexPath, style: SpotlightStyle = .dim) {
        guard let cell = cellForItem(at: indexPath) as? ContainerCell,
              let containedViewImage = cell.mainView.image,
              let window = SnowPackUI.currentWindow
        else { return }
        
        let targetRect = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        let absoluteRect = convert(targetRect, to: window)
        let containerRect = convert(window.bounds, to: self)
        
        let containedView = PassthroughImageView(image: containedViewImage)
        containedView.frame = absoluteRect
        containedView.accessibilityIdentifier = "Overlay.Cell"
        
        let overlay = PassthroughView(frame: containerRect)
        overlay.accessibilityIdentifier = "Overlay.Spotlight"
        
        addSubview(overlay)
        addSubview(containedView)
        
        switch style {
        case .dim:
            overlay.alpha = 0.0
            overlay.backgroundColor = .black.withAlphaComponent(0.5)
            UIView.animate(withDuration: 0.25, delay: 0.0) {
                overlay.alpha = 1.0
            }
        case .blur:
            overlay.applyBlurOverlay(animated: true)
        }
        
        isScrollEnabled = false
    }
    
    func removeSpotlight() {
        guard let window = SnowPackUI.currentWindow,
              let cell = window.allSubviews.first(where: { $0.accessibilityIdentifier == "Overlay.Cell"}),
              let overlay = window.allSubviews.first(where: { $0.accessibilityIdentifier == "Overlay.Spotlight"})
        else { return }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
            overlay.alpha = 0.0
        }, completion: { [weak self] done in
            cell.removeFromSuperview()
            overlay.removeFromSuperview()
            self?.isScrollEnabled = true
        })
    }
    
}
