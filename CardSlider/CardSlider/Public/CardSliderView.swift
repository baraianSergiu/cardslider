
import Foundation
import UIKit

public protocol CardSliderViewDataSource: class {
    func item(for index: Int) -> UIView
    func numberOfItems() -> Int
}

public protocol CardSliderViewDelegate: class {
    func itemSelected(at index: Int)
    func itemDisplayed(at index: Int)
}

public enum ItemWidth: Int {
    case small = 0
    case medium
    case large
}

public class CardSliderView: UIView {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let cellID = "CardCell"
    private let pageControl: UIPageControl = UIPageControl(frame: .zero)
    private let collectionViewLayout = CardsLayout()
    
    private var currentIndex: Int = 0 {
        didSet {
            applyAlphaToVisibleCells()
        }
    }
    
    public weak var dataSource: CardSliderViewDataSource!
    public weak var delegate: CardSliderViewDelegate!
    
    public var useAlphaForVisibleCells: Bool = true
    
    public var itemWidth: ItemWidth = .medium {
        didSet {
            setupCollectionViewItemSize()
        }
    }
    
    public var itemHeight: CGFloat = 200 {
        didSet {
            setupCollectionViewItemSize()
        }
    }
    
    public var visibleItemsCount: Int = 3 {
        didSet {
            collectionViewLayout.visibleItemsCount = visibleItemsCount
        }
    }
    
    // Mark: Page Control costomization
    public var pageIndicatorTintColor: UIColor = .gray {
        didSet {
            setupPageControl()
        }
    }
    
    public var currentPageIndicatorTintColor: UIColor = .red {
        didSet {
            setupPageControl()
        }
    }
    
    public var pageControlYPosition: CGFloat = 0 { // relative to Y axis referenced to view bottom position, 0 = most bottom position
        didSet {
            setupPageControl()
        }
    }
    
    public var pageControlXPosition: CGFloat = 0 { // value in points, 0 == centered, "-" value will move item to left, "+" to right
        didSet {
            setupPageControl()
        }
    }
    
    //    Mark: View Implementation
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupPageControl()
        layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardSliderCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .clear
        setupCollectionViewItemSize()
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupPageControl() {
        pageControl.removeFromSuperview()
        pageControl.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        addSubview(pageControl)
        bringSubviewToFront(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: pageControlXPosition),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: pageControlXPosition),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: pageControlYPosition * -1),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupCollectionViewItemSize() {
        collectionViewLayout.itemSize = CGSize(width: getItemWidth(for: itemWidth), height: itemHeight)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            if pageControl.frame.contains(location) {
                if location.x <= pageControl.center.x && currentIndex > 0 {
                    currentIndex -= 1
                } else if currentIndex < pageControl.numberOfPages - 1 {
                    currentIndex += 1
                }
                var frame: CGRect = collectionView.frame
                frame.origin.x = frame.size.width * CGFloat(currentIndex)
                frame.origin.y = 0
                collectionView.scrollRectToVisible(frame, animated: true)
            }
        }
    }
    
    private func getAlphaForCell(cellIndex: Int) -> CGFloat {
        
        if currentIndex == cellIndex {
            return 1
        }
        
        let minIndex = currentIndex - visibleItemsCount > 0 ? currentIndex - visibleItemsCount : 0
        let maxIndex = currentIndex - 1
        let alphaPercent = 80 / visibleItemsCount
        
        if minIndex <= cellIndex && maxIndex >= cellIndex {
            return CGFloat(alphaPercent * (cellIndex - minIndex)) / 100
        }
        return 1
    }
    
    private func applyAlphaToVisibleCells() {
        
        if useAlphaForVisibleCells {
            let minIndex = currentIndex - visibleItemsCount + 1 > 0 ? currentIndex - visibleItemsCount + 1 : 0
            
            for index in minIndex...currentIndex {
                let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CardSliderCell
                cell?.view.alpha = getAlphaForCell(cellIndex: index)
                cell?.layoutSubviews()
            }
        }
    }
    
    private func getItemWidth(for item: ItemWidth) -> CGFloat {
        switch item {
        case .small:
            return bounds.width / 2 - collectionViewLayout.spacing * 2
        case .medium:
            return bounds.width / 1.5 - collectionViewLayout.spacing * 2
        case .large:
            return bounds.width - collectionViewLayout.spacing * 2
        }
    }
}

extension CardSliderView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = dataSource.numberOfItems()
        return dataSource.numberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CardSliderCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CardSliderCell else { return }
        let item = dataSource.item(for: indexPath.row)
        cell.view = item
        if useAlphaForVisibleCells && indexPath.row < currentIndex {
            cell.view.alpha = 0.1
        }
        cell.layoutIfNeeded()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.itemSelected(at: indexPath.row)
        
        if CGFloat(indexPath.item) != collectionView.contentOffset.x / collectionView.bounds.width {
            collectionView.setContentOffset(CGPoint(x: collectionView.bounds.width * CGFloat(indexPath.item), y: 0), animated: true)
            return
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int( (collectionView.contentOffset.x / collectionView.frame.width).rounded(.toNearestOrAwayFromZero))
        
        if currentIndex != pageControl.currentPage {
            currentIndex = pageControl.currentPage
            delegate?.itemDisplayed(at: currentIndex)
        }
    }
}
