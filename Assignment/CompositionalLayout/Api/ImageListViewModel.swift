import Foundation

class ImageListViewModel {
    
    private let unsplashAPIService = UnsplashAPIService()
    var images: [UnsplashImage] = []
    
    var onImagesFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    var onLoadingNextPage: ((Bool) -> Void)?
    
    private var currentPage = 1
    var isLoadingNextPage = false
    private var isLoading = false
    private let imagesPerPage = 30
    private var currentQuery: String?

    // Fetch images, or fetch next page for both initial and pagination
    private func fetchImages(page: Int, query: String?) {
        guard !isLoading else { return }
        
        isLoading = true
        onLoadingStatusChanged?(true)
        
        let completionHandler: (Result<[UnsplashImage], Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.onLoadingStatusChanged?(false)
            self.isLoadingNextPage = false
            
            switch result {
            case .success(let newImages):
                if page == 1 {
                    self.images = newImages // For new searches or first fetch
                } else {
                    self.images.append(contentsOf: newImages) // For pagination
                }
                self.onImagesFetched?()
                
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
        
        if let query = query {
            unsplashAPIService.searchImages(query: query, page: page, perPage: imagesPerPage, completion: completionHandler)
        } else {
            unsplashAPIService.fetchImages(page: page, perPage: imagesPerPage, completion: completionHandler)
        }
    }
    
    // Public method to initiate fetching of the first page
    func fetchImages() {
        currentPage = 1
        fetchImages(page: currentPage, query: currentQuery)
    }
    
    // Public method to fetch next page
    func fetchNextPage() {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        onLoadingNextPage?(true)
        currentPage += 1
        fetchImages(page: currentPage, query: currentQuery)
    }
    
    // Fetch images based on search query
    func searchImages(query: String) {
        currentQuery = query
        fetchImages()
    }
}
