
import UIKit
import CardSlider

class ViewController: UIViewController {
    
    override func viewDidLoad() {
		super.viewDidLoad()
        let cardSlider: CardSliderView = CardSliderView.init(frame: view.bounds, itemSize: CGSize(width: 250, height: 200))
        cardSlider.dataSource = self
        cardSlider.delegate = self
        view.addSubview(cardSlider)
        cardSlider.reloadData()
        
    // Mark: cutomize optional values
        cardSlider.visibleItemsCount = 3
        cardSlider.pageIndicatorTintColor = .gray
        cardSlider.currentPageIndicatorTintColor = .red
        cardSlider.pageControlYPosition = 0
        cardSlider.pageControlXPosition = 0
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
    
    func itemSelected(for index: Int) {
        
    }

}
