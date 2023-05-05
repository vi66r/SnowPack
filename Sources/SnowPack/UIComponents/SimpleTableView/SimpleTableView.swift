import UIKit

public protocol SimpleTableViewLayoutDelegate {
    func height(for indexPath: IndexPath) -> CGFloat
    func height(for section: Int) -> CGFloat
}

open class SimpleTableView<T: UIView & Hydratable>:
    UITableView,
    UITableViewDelegate,
    UITableViewDataSource,
    UITableViewDataSourcePrefetching,
    UITableViewDragDelegate
{
    typealias TableViewContainerCell = ViewContainerTableViewCell<T>
    
    public var approachingEndOfSection: TypedAction<Int>?
    
    public var cellAtIndexPath: Typed2DAction<ViewContainerTableViewCell<T>, IndexPath>?
    public var cellWillAppear: Typed2DAction<T, IndexPath>?
    public var cellDidDisappear: Typed2DAction<T, IndexPath>?
    
    public var cellSelected: Typed2DAction<T, IndexPath>?
    public var cellFocused: Typed2DAction<T, IndexPath>?
    public var cellDefocused: Typed2DAction<T, IndexPath>?
    public var cellRepositioned: Typed2DAction<T, IndexPath>?
    
    public var cellMoved: TypedAction<(to: IndexPath, from: IndexPath)>?
    
    public var scrolled: Action?
    
    public var prefetchAction: TypedAction<[IndexPath]>? {
        didSet { prefetchDataSource = self }
    }
    
    public var layoutDelegate: SimpleTableViewLayoutDelegate?
    public var staticCellHeight: CGFloat?
    public var staticHeaderHeight: CGFloat?
    
    public var data: [SimpleTableViewSection<T>] {
        didSet {
            reloadData()
        }
    }
    
    public init(elements: [SimpleTableViewSection<T>],
                showsScrollIndicator: Bool = false,
                contentInsets: UIEdgeInsets = .zero,
                backgroundColor: UIColor = .clear,
                staticCellHeight: CGFloat? = nil,
                staticHeaderHeight: CGFloat? = nil,
                dragDropEnabled: Bool = false
    ) {
        self.data = elements
        self.staticCellHeight = staticCellHeight
        self.staticHeaderHeight = staticHeaderHeight
        super.init(frame: .zero, style: .plain)
        register(TableViewContainerCell.self, forCellReuseIdentifier: TableViewContainerCell.identifier)
        separatorStyle = .none
        showsVerticalScrollIndicator = showsScrollIndicator
        showsHorizontalScrollIndicator = showsScrollIndicator
        insetsContentViewsToSafeArea = false
        contentInsetAdjustmentBehavior = .never
        tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        sectionHeaderTopPadding = 0.0
        self.contentInset = contentInsets
        delegate = self
        dataSource = self
        dragDelegate = self
        dragInteractionEnabled = dragDropEnabled
        self.backgroundColor = backgroundColor
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data[section].elements.count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        data[section].header ??
        UIView(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        data[section].footer ??
        UIView(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == data[indexPath.section].elements.count - 3 {
            approachingEndOfSection?(indexPath.section)
        }
        
        let targetData = data[indexPath.section].elements[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewContainerCell.identifier,
                                                       for: indexPath) as? TableViewContainerCell
        else { return UITableViewCell() }
        cell.tag = indexPath.row
        cell.hydrate(with: targetData)
        cellAtIndexPath?(cell, indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return staticCellHeight ?? layoutDelegate?.height(for: indexPath) ?? 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return staticHeaderHeight ?? layoutDelegate?.height(for: section) ?? CGFloat(CGFLOAT_MIN)
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchAction?(indexPaths)
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewContainerCell else { return }
        cellSelected?(cell.mainView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TableViewContainerCell else { return }
        cellWillAppear?(cell.mainView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TableViewContainerCell else { return }
        cellDidDisappear?(cell.mainView, indexPath)
    }
    
    // MARK: - ScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrolled?()
    }
    
    // MARK: - DragDelegate
    
    public func tableView(_ tableView: UITableView,
                          itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath
    ) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = data[indexPath.section].elements[indexPath.row]
        return [dragItem]
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = self.data[sourceIndexPath.section].elements.remove(at: sourceIndexPath.row)
        self.data[sourceIndexPath.section].elements.insert(mover, at: destinationIndexPath.row)
        cellMoved?((sourceIndexPath, destinationIndexPath))
    }
}
