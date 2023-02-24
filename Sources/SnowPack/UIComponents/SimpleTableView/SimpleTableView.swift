import UIKit

public protocol SimpleTableViewLayoutDelegate {
    func height(for cell: UITableViewCell, at: IndexPath) -> CGFloat
    func height(for section: Int) -> CGFloat
}

open class SimpleTableView<T: UIView & Hydratable>:
    UITableView,
    UITableViewDelegate,
    UITableViewDataSource,
    UITableViewDataSourcePrefetching
{
    typealias ContainerCell = ViewContainerTableViewCell<T>
    
    public var approachingEndOfSection: RemoteTypedAction<Int>?
    
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
                staticHeaderHeight: CGFloat? = nil
    ) {
        self.data = elements
        self.staticCellHeight = staticCellHeight
        self.staticHeaderHeight = staticHeaderHeight
        super.init(frame: .zero, style: .plain)
        separatorStyle = .none
        showsVerticalScrollIndicator = showsScrollIndicator
        showsHorizontalScrollIndicator = showsScrollIndicator
        insetsContentViewsToSafeArea = false
        contentInsetAdjustmentBehavior = .never
        self.contentInset = contentInsets
        delegate = self
        dataSource = self
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
        data[section].header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        data[section].footer
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == data[indexPath.section].elements.count - 3 {
            approachingEndOfSection?(indexPath.section)
        }
        
        let targetData = data[indexPath.section].elements[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContainerCell.identifier,
                                                       for: indexPath) as? ContainerCell
        else { return UITableViewCell() }
        cell.tag = indexPath.row
        cell.hydrate(with: targetData)
        cellAtIndexPath?(cell.mainView, indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) else { return .zero }
        return staticCellHeight ?? layoutDelegate?.height(for: cell, at: indexPath) ?? 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return staticHeaderHeight ?? layoutDelegate?.height(for: section) ?? 12.0
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchAction?(indexPaths)
    }
}
