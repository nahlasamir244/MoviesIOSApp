import UIKit

class SingleMovieViewController: UIViewController {
    
    @IBOutlet weak var MFav: UIImageView!
    @IBOutlet weak var MTrailer: UIView!
    @IBOutlet weak var MDate: UILabel!
    @IBOutlet weak var MRating: UIView!
    @IBOutlet weak var MOverview: UITextView!
    @IBOutlet weak var MPoster: UIImageView!
    @IBOutlet weak var Mtitle: UILabel!
    var movie:Movie!
    var helper = Helper()
    override func viewDidLoad() {
        super.viewDidLoad()
            MFav.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favTap))
            tapGestureRecognizer.numberOfTapsRequired = 1
            MFav.addGestureRecognizer(tapGestureRecognizer)
        Mtitle.text=movie.title
        helper.downloadAndSetImage(movie:movie,imageView:MPoster)
        movie.trailers=helper.getTrailers(movie:movie)
        helper.viewTrailer(playerView:MTrailer,videoID:movie.trailers.trailerID)
        movie.reviews=helper.getReviews(movie:movie)
        helper.displayRateInStars(movie:movie,cosmosView:MRating)
        MOverview.text=movie.overview
        MDate.text=movie.release_date
        //check if fav and set img
        if helper.checkIfMovieIsFav {
            MFav.image=UIImage(named:"Fav")
        }else{
            MFav.image=UIImage(named:"notFav")
        }
        func favTap(sender: UITapGestureRecognizer) {
            if helper.checkIfMovieIsFav{
                helper.removeFromFavorites(id:movie.id)
                MFav.image=UIImage(named:"notFav")
            }
            else{
                helper.addToFavorites(movie:movie)
                MFav.image=UIImage(named:"fav")
            }
        }
    }
    


}
