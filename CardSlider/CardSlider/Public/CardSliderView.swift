
import Foundation
import UIKit

public protocol CardSliderViewDataSource: class {
    func item(for index: Int) -> UIView
    func numberOfItems() -> Int
}

public protocol CardSliderViewDelegate: class {
    func itemSelected(for index: Int)
}

public class CardSliderView: UIView {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let cellID = "CardCell"
    private let pageControl: UIPageControl = UIPageControl(frame: .zero)
    private var itemSize: CGSize = CGSize()
    
    public weak var dataSource: CardSliderViewDataSource!
    public weak var delegate: CardSliderViewDelegate!
    
    // Mark: Page Control costomization
    public var pageIndicatorTintColor: UIColor = .gray { didSet { setupPageControl() }}
    public var currentPageIndicatorTintColor: UIColor = .red { didSet { setupPageControl() }}
    public var pageControlHeight: CGFloat = 100 { didSet { setupPageControl() }} // height is relative to Y axis and fixed bottom position
    public var pageControlPosition: CGFloat = 0 { didSet { setupPageControl() }} // value in points, 0 == centered, "-" value will move item to left, "+" to right
    
    public init(frame: CGRect, itemSize: CGSize) {
        super.init(frame: frame)
        self.itemSize = itemSize
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
        let layout = CardsLayout()
        collectionView.collectionViewLayout = layout
        layout.itemSize = itemSize
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardSliderCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
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
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: pageControlPosition),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: pageControlPosition),
            pageControl.topAnchor.constraint(equalTo: self.bottomAnchor, constant: pageControlHeight * -1),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
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
        cell.layoutIfNeeded()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.itemSelected(for: indexPath.row)
        
        if CGFloat(indexPath.item) != collectionView.contentOffset.x / collectionView.bounds.width {
            collectionView.setContentOffset(CGPoint(x: collectionView.bounds.width * CGFloat(indexPath.item), y: 0), animated: true)
            return
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int( (collectionView.contentOffset.x / collectionView.frame.width).rounded(.toNearestOrAwayFromZero))
    }
}
