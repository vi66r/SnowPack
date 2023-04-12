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
/// var approachingEnd: Action?
/// var refreshRequested: Action?
/// var cellAtIndexPath: Typed2DAction<T, IndexPath>?
/// var cellWillAppear: Typed2DAction<T, IndexPath>?
/// var cellDidDisappear: Typed2DAction<T, IndexPath>?
/// var cellSelected: Typed2DAction<T, IndexPath>?
/// var cellFocused: Typed2DAction<CollectionViewContainerCell, IndexPath>?
/// var cellDefocused: TypedAction<CollectionViewContainerCell>?
/// var cellRepositioned: Typed2DAction<T, IndexPath>?
/// var focusedTouchBeganAction: Typed2DAction<CollectionViewContainerCell, IndexPath>?
/// var focusedTouchEndedAction: Typed2DAction<CollectionViewContainerCell, IndexPath>?
/// var defocusedTouchBeganAction: TypedAction<[CollectionViewContainerCell]>?
/// var defocusedTouchEndedAction: TypedAction<[CollectionViewContainerCell]>?
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
    public typealias CollectionViewContainerCell = ViewContainerCollectionViewCell<T>
    
    private var performingAutomaticUpdates = false
    
    public var focusesOnCenterCell = false
    
    public var approachingEnd: Action?
    
    public var refreshRequested: Action?
    
    public var cellAtIndexPath: Typed2DAction<T, IndexPath>?
    public var cellWillAppear: Typed2DAction<T, IndexPath>?
    public var cellDidDisappear: Typed2DAction<T, IndexPath>?
    
    public var cellSelected: Typed2DAction<T, IndexPath>?
    public var cellFocused: Typed2DAction<CollectionViewContainerCell, IndexPath>?
    public var cellDefocused: TypedAction<CollectionViewContainerCell>?
    public var cellRepositioned: Typed2DAction<T, IndexPath>?
    
    public var focusedTouchBeganAction: Typed2DAction<CollectionViewContainerCell, IndexPath>?
    public var focusedTouchEndedAction: Typed2DAction<CollectionViewContainerCell, IndexPath>?
    public var defocusedTouchBeganAction: TypedAction<[CollectionViewContainerCell]>?
    public var defocusedTouchEndedAction: TypedAction<[CollectionViewContainerCell]>?
    
    public var scrolled: Action?
    
    public var focusedCell: (CollectionViewContainerCell, IndexPath)?
    public var defocusedCells: [CollectionViewContainerCell]?
    
    public var prefetchAction: TypedAction<[IndexPath]>? {
        didSet { prefetchDataSource = self }
    }
    
    public var prefetchCancellation: TypedAction<[IndexPath]>?
    
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
    
    public var interitemSpacing: CGFloat
    public var lineSpacing: CGFloat
    
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
                staticCellSize: CGSize? = nil,
                interItemSpacing: CGFloat = 0.0,
                lineSpacing: CGFloat = 0.0
    ) {
        self.elements = elements
        self.interitemSpacing = interItemSpacing
        self.lineSpacing = lineSpacing
        super.init(frame: .zero, collectionViewLayout: layout)
        register(CollectionViewContainerCell.self, forCellWithReuseIdentifier: CollectionViewContainerCell.identifier)
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
    
    public func addRefreshControl() {
        alwaysBounceVertical = true
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .textBrand
        refreshControl?.addTarget(self, action: #selector(requestedRefresh), for: .valueChanged)
        addSubview(refreshControl!)
    }
    
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    @objc func requestedRefresh() {
        refreshControl?.beginRefreshing()
        refreshRequested?()
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
        guard let cell = cell as? CollectionViewContainerCell else { return }
        cellWillAppear?(cell.mainView, indexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? CollectionViewContainerCell else { return }
        cellDidDisappear?(cell.mainView, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchAction?(indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetchCancellation?(indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewContainerCell else { return }
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
            withReuseIdentifier: CollectionViewContainerCell.identifier,
            for: indexPath
        ) as? CollectionViewContainerCell else { return UICollectionViewCell() }
        cell.tag = indexPath.row
        cellAtIndexPath?(cell.mainView, indexPath)
        cell.hydrate(with: target)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        interitemSpacing
    }
    
    // MARK: - ScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrolled?()
        updateCenterFocus()
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
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let focusedCell = focusedCell, let defocusedCells = defocusedCells else { return }
        focusedTouchBeganAction?(focusedCell.0, focusedCell.1)
        defocusedTouchBeganAction?(defocusedCells)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let focusedCell = focusedCell, let defocusedCells = defocusedCells else { return }
        focusedTouchEndedAction?(focusedCell.0, focusedCell.1)
        defocusedTouchEndedAction?(defocusedCells)
    }
}

public extension SimpleCollectionView {
    
    enum SpotlightStyle {
        case dim
        case blur
    }
    
    func spotlightCell(at indexPath: IndexPath, style: SpotlightStyle = .dim) {
        guard let cell = cellForItem(at: indexPath) as? CollectionViewContainerCell,
              let containedViewImage = cell.mainView.snapshot,
              let window = SnowPackUI.currentWindow
        else { return }
        
        let targetRect = layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        let absoluteRect = convert(targetRect, to: superview)
        
        let containedView = PassthroughImageView(image: containedViewImage)
        containedView.frame = absoluteRect
        containedView.accessibilityIdentifier = "Overlay.Cell"
        
        let overlay = PassthroughView(frame: window.bounds)
        overlay.accessibilityIdentifier = "Overlay.Spotlight"
        
        superview?.addSubview(overlay)
        superview?.addSubview(containedView)
        
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


public extension SimpleCollectionView {
    
    func updateCenterFocus() {
        guard focusesOnCenterCell else { return }
        let centerPoint = CGPoint(x: frame.size.width / 2 + contentOffset.x,
                                  y: frame.size.height / 2 + contentOffset.y)
        
        guard let indexPath = indexPathForItem(at: centerPoint),
              let cell = cellForItem(at: indexPath) as? CollectionViewContainerCell
        else { return }
        focusedCell = (cell, indexPath)
        cellFocused?(cell, indexPath)
        let defocusedCells = visibleCells.filter({ $0 !== cell })
            .compactMap({ $0 as? CollectionViewContainerCell })
        self.defocusedCells = defocusedCells
        defocusedCells.forEach({
            cellDefocused?($0)
        })
    }
    
}
