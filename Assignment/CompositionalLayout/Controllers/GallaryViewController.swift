import UIKit

class GallaryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator:
    UIActivityIndicatorView!
    @IBOutlet weak var userInfoButton: UIButton!
    
    let searchController = UISearchController()
    
    private let viewModel = ImageListViewModel()
    private var images: [UnsplashImage] = []
    private var loadingFooter: UIView? // Track the footer directly
    private var isLoadingFooterVisible = false
    private var searchDebouncer: Debouncer?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Search"
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        bindViewModel()
        viewModel.fetchImages()
        searchDebouncer = Debouncer()
        userInfoButton.layer.cornerRadius = 10
        
    }

    private func bindViewModel() {
           viewModel.onLoadingStatusChanged = { isLoading in
               DispatchQueue.main.async {
                   if isLoading {
                       self.loadingIndicator.startAnimating()
                   } else {
                       self.loadingIndicator.stopAnimating()
                   }
               }
           }
           
           viewModel.onLoadingNextPage = { isLoadingNextPage in
               DispatchQueue.main.async {
                   if isLoadingNextPage {
                       self.showLoadingFooter()
                   } else {
                       self.hideLoadingFooter()
                   }
               }
           }

           viewModel.onImagesFetched = {
               DispatchQueue.main.async {
                   self.images = self.viewModel.images
                   self.collectionView.reloadData()
               }
           }

           viewModel.onError = { errorMessage in
               DispatchQueue.main.async {
                   self.showErrorAlert(message: errorMessage)
               }
           }
       }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(0.5), height: .fractionalHeight(1), spacing: 1)
        
        let fullItem = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 1)
        let verticalGroup = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(0.5), height: .fractionalHeight(1), item: fullItem, count: 2)
        
        let horizontalGroup = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.6), items: [item, verticalGroup])
        
        let mainItem = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(0.4), spacing: 1)
        let mainGroup = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1), height: .fractionalHeight(0.5), items: [mainItem, horizontalGroup])
        
        let section = NSCollectionLayoutSection(group: mainGroup)
        
        // Footer layout for loading indicator
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [footer]

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func showLoadingFooter() {
           guard !isLoadingFooterVisible else { return }
           
           isLoadingFooterVisible = true
           let loadingFooter = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 60))
           let spinner = UIActivityIndicatorView(style: .medium)
           spinner.center = loadingFooter.center
           spinner.startAnimating()
           
           loadingFooter.addSubview(spinner)
           collectionView.addSubview(loadingFooter)
           collectionView.contentInset.bottom = 60 // Add space for the footer
       }
       
       private func hideLoadingFooter() {
           isLoadingFooterVisible = false
           collectionView.contentInset.bottom = 0 // Reset content inset
           collectionView.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() } // Remove footer spinner
       }


}

extension GallaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        let unsplashImage = images[indexPath.row]
        cell.setup(imageUrl: unsplashImage.urls.small)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height

            if offsetY > contentHeight - scrollView.frame.size.height {
                viewModel.fetchNextPage() // Trigger loading more images when reaching the bottom
            }
        }

    func updateSearchResults(for searchController: UISearchController) {
           if let query = searchController.searchBar.text, !query.isEmpty {
               searchDebouncer?.debounce(delay: 0.5) {
                   self.viewModel.searchImages(query: query)
               }
           }
       }
    
    @IBAction func didTapUserInfoButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }


}

//to prevent frequent apicall
class Debouncer {
    private var timer: Timer?
    
    func debounce(delay: TimeInterval, action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }
}


