
import UIKit
import CardSlider

class ViewController: UIViewController {
    
    override func viewDidLoad() {
		super.viewDidLoad()
        let cardSlider: CardSliderView = CardSliderView.init(frame: view.bounds)
        cardSlider.dataSource = self
        cardSlider.delegate = self
        view.addSubview(cardSlider)
        
    // Mark: cutomize optional values
        cardSlider.visibleItemsCount = 3
        cardSlider.useAlphaForVisibleCells = true
        cardSlider.pageIndicatorTintColor = .gray
        cardSlider.currentPageIndicatorTintColor = .red
        cardSlider.pageControlYPosition = 50
        cardSlider.pageControlXPosition = 0
        cardSlider.itemHeight = 200
        cardSlider.itemWidth = .large
        
        cardSlider.reloadData()
	}
}

extension ViewController: CardSliderViewDataSource, CardSliderViewDelegate {
	func item(for index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
		return view
	}
	
	func numberOfItems() -> Int {
		return 10
	}
    
    func itemSelected(at index: Int) {
        
    }
    
    func itemDisplayed(at index: Int) {
        
    }

}
