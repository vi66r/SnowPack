import UIKit

public protocol SimpleTableViewLayoutDelegate {
    func height(for indexPath: IndexPath) -> CGFloat
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
    
    public var scrolled: RemoteAction?
    
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
        register(ContainerCell.self, forCellReuseIdentifier: ContainerCell.identifier)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContainerCell.identifier,
                                                       for: indexPath) as? ContainerCell
        else { return UITableViewCell() }
        cell.tag = indexPath.row
        cell.hydrate(with: targetData)
        cellAtIndexPath?(cell.mainView, indexPath)
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
        guard let cell = tableView.cellForRow(at: indexPath) as? ContainerCell else { return }
        cellSelected?(cell.mainView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ContainerCell else { return }
        cellWillAppear?(cell.mainView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ContainerCell else { return }
        cellDidDisappear?(cell.mainView, indexPath)
    }
    
    // MARK: - ScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrolled?()
    }
}
