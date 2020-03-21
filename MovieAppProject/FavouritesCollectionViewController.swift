
import UIKit

private let reuseIdentifier = "CellF"

class FavouritesCollectionViewController: UICollectionViewController {
    var data = [Movie]()
    var helper = Helper()
    var movieVC = SingleMovieViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
            data = helper.getFavorites()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
   
        return 2
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

  
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            as! CustomCell
        let img = cell.viewWithTag(5) as! UIImageView
        helper.downloadAndSetImage(movie:data[indexPath.item],imageView:img)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieVC.movie = data[indexPath.item]
        self.navigationController?.pushViewController(movieVC, animated: true)
    }
}
