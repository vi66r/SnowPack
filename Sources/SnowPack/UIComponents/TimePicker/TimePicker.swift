import UIKit

public final class TimePicker: UIView {
    
    @Event<Date> public var timeChangePublisher
    
    public var font: UIFont
    public var color: UIColor
    public var colonBaselineOffset = 1.0
    public var cellBackground: UIColor = .clear
    
    var hourIndex = 0
    var minuteIndex = 0
    var ampmIndex = 0
    let hours = Array(1...12).map({ "\($0)" })
    let minutes = Array(0...59).map({ $0 < 10 ? "0\($0)" : "\($0)" })
    let ampm = ["AM", "PM"]
    
    public var preferredSize: CGSize {
        return .init(width: hourSize.width + minuteSize.width + ampmSize.width + separatorLabel.intrinsicContentSize.width,
                     height: minuteSize.width)
    }
    lazy var hourSize: CGSize = {
        let intrinsicSize = "00".sizeOfString(usingFont: font)
        return .init(width: intrinsicSize.width + 2.0, height: intrinsicSize.height)
    }()
    lazy var minuteSize: CGSize = {
        let intrinsicSize = "00".sizeOfString(usingFont: font)
        return .init(width: intrinsicSize.width + 2.0, height: intrinsicSize.height)
    }()
    lazy var ampmSize: CGSize = {
        let intrinsicSize = "AM".sizeOfString(usingFont: font)
        return .init(width: intrinsicSize.width + 2.0, height: intrinsicSize.height)
    }()
    
    lazy var hoursCarousel: SimpleCollectionView<TimePickerCell> = {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .vertical
        let collectionView = SimpleCollectionView<TimePickerCell>(elements: hours,
                                                                  layout: layout,
                                                                  backgroundColor: .clear,
                                                                  decelerationRate: .fast,
                                                                  contentInset: .zero,
                                                                  staticCellSize: hourSize,
                                                                  interItemSpacing: 2.0,
                                                                  lineSpacing: 2.0)
        collectionView.focusesOnCenterCell = true
        
        collectionView.cellDefocused = {
            $0?.mainView.animateScale(by: 0.5)
        }
        
        collectionView.cellFocused = { [weak self] cell, index in
            cell?.mainView.animateTransformToIdentity()
            self?.hourIndex = index?.row ?? 0
            self?.assessTime()
        }
        collectionView.width(hourSize.width)
        collectionView.height(hourSize.height)
        return collectionView
    }()
    
    lazy var minutesCarousel: SimpleCollectionView<TimePickerCell> = {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .vertical
        let collectionView = SimpleCollectionView<TimePickerCell>(elements: minutes,
                                                                  layout: layout,
                                                                  backgroundColor: .clear,
                                                                  decelerationRate: .fast,
                                                                  contentInset: .zero,
                                                                  staticCellSize: minuteSize,
                                                                  interItemSpacing: 2.0,
                                                                  lineSpacing: 2.0)
        collectionView.focusesOnCenterCell = true
        
        collectionView.cellDefocused = {
            $0?.mainView.animateScale(by: 0.5)
        }
        
        collectionView.cellFocused = { [weak self] cell, index in
            cell?.mainView.animateTransformToIdentity()
            self?.minuteIndex = index?.row ?? 0
            self?.assessTime()
        }
        collectionView.width(minuteSize.width)
        collectionView.height(minuteSize.height)
        return collectionView
    }()
    
    lazy var ampmCarousel: SimpleCollectionView<TimePickerCell> = {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .vertical
        let collectionView = SimpleCollectionView<TimePickerCell>(elements: ampm,
                                                                  layout: layout,
                                                                  backgroundColor: .clear,
                                                                  decelerationRate: .fast,
                                                                  contentInset: .zero,
                                                                  staticCellSize: ampmSize,
                                                                  interItemSpacing: 2.0,
                                                                  lineSpacing: 2.0)
        collectionView.focusesOnCenterCell = true
        
        collectionView.cellDefocused = {
            $0?.mainView.animateScale(by: 0.5)
        }
        
        collectionView.cellFocused = { [weak self] cell, index in
            cell?.mainView.animateTransformToIdentity()
            self?.ampmIndex = index?.row ?? 0
            self?.assessTime()
        }
        collectionView.width(ampmSize.width)
        collectionView.height(ampmSize.height)
        return collectionView
    }()
    
    lazy var separatorLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: ":",
                                                  attributes: [.baselineOffset : colonBaselineOffset,
                                                               .foregroundColor : color]
        )
        label.textAlignment = .center
        return label
    }()
    
    public init(font: UIFont = .body3,
                color: UIColor = .textSurface,
                alignment: NSTextAlignment = .center,
                cellBackground: UIColor = .clear
    ) {
        self.font = font
        self.color = color
        TimePickerCell.font = font
        TimePickerCell.color = color
        TimePickerCell.alignment = alignment
        super.init(frame: .zero)
        [hoursCarousel, separatorLabel, minutesCarousel, ampmCarousel].forEach(addSubview)
        hoursCarousel.leadingToSuperview()
        separatorLabel.leadingToTrailing(of: hoursCarousel)
        minutesCarousel.leadingToTrailing(of: separatorLabel)
        ampmCarousel.leadingToTrailing(of: minutesCarousel, offset: 2.0)
        [hoursCarousel, separatorLabel, minutesCarousel, ampmCarousel].forEach({ $0.centerYToSuperview() })
    }
    
    func assessTime() {
        let hour = hours[hourIndex]
        let minute = minutes[minuteIndex]
        let ampm = ampm[ampmIndex]
        let timeString = hour + ":" + minute + " " + ampm
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        if let date = dateFormatter.date(from: timeString) {
            timeChangePublisher.send(date)
        }
    }
    
    public func setupCellBackgrounds() {
        let views = (0...2).map({ _ in
            let view = UIView()
            view.backgroundColor = cellBackground
            view.applyRoundedCorners(preferredSize.height * 0.2, curve: .continuous)
            return view
        })
        views.forEach({ insertSubview($0, at: 0) })
        views[0].edges(to: hoursCarousel)
        views[1].edges(to: minutesCarousel)
        views[2].edges(to: ampmCarousel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hoursCarousel.defocusedCells?.forEach({ $0.unhide() })
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hoursCarousel.defocusedCells?.forEach({ $0.hide() })
        super.touchesEnded(touches, with: event)
    }
}
