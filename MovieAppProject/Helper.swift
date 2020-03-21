import CoreData
import UIKit
import SystemConfiguration
import Alamofire
import Cosmos
import youtube_ios_player_helper_swift
import SwiftyJSON
import Reachability
import SDWebImage
import YoutubePlayer_in_WKWebView

class Helper: NSObject {
    //insert this code where you want to check rechability (internet connection)
    /*let helper = Helper()
     result = helper.checkReachability()
    */
    func checkReachability() -> Bool {
        let reachability = try? Reachability()
        if reachability?.connection == .wifi || reachability?.connection == .cellular {
            return true
        }
        else {
        return false
        }
    }
    //insert this code where you want to get top rated movies online
    /*let helper = Helper()
     var moviesArray = [Movie]()
     moviesArray = helper.getTopRatedMoviesOnline()
     */
    func getTopRatedMoviesOnline() -> [Movie] {
        var moviesArray = [Movie]()
        var movie:Movie!
        AF.request("http://api.themoviedb.org/3/discover/movie?sort_by=vote_average.desc&api_key=f6eee4ea0a39d56930047ec50ad3341c").responseJSON { response in
            switch response.result
            {
            case .success(let value):
                let json = JSON(value)
                let movies = json["results"].array
                let moviesCount = movies?.count
                //truncate the table movies
                for n in 0..<moviesCount! {
                    movie = Movie()
                    movie.id = movies?[n]["id"].int
                    movie.title = movies?[n]["title"].string
                    movie.overview = movies?[n]["overview"].string
                    movie.poster_path = "http://image.tmdb.org/t/p/w185/"+(movies?[n]["poster_path"].string)!
                    movie.release_date = movies?[n]["release_date"].string
                    moviesArray.append(movie)
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        return moviesArray
    }
    //insert this code where you want to get popular movies online
    /*let helper = Helper()
     var moviesArray = [Movie]()
     moviesArray = helper.getPopularMoviesOnline()
     */
    func getPopularMoviesOnline(cv:MoviesCollectionViewController) -> [Movie] {
        var moviesArray = [Movie]()
        
        var movie:Movie!
        AF.request("http://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=f6eee4ea0a39d56930047ec50ad3341c").responseJSON { response in
            switch response.result
            {
            case .success(let value):
                let json = JSON(value)
                let movies = json["results"].array
                let moviesCount = movies?.count
                //truncate the table movies
                for n in 0..<moviesCount! {
                    movie = Movie()
                    movie.id = movies?[n]["id"].int
                    movie.title = movies?[n]["title"].string
                    movie.overview = movies?[n]["overview"].string
                    movie.poster_path = "http://image.tmdb.org/t/p/w185/"+(movies?[n]["poster_path"].string)!
                    movie.release_date = movies?[n]["release_date"].string
                    moviesArray.append(movie)
                    //save the movie in core data
                    savePopularMovie(movie)
                }
                DispatchQueue.main.async {
                    cv.data=moviesArray
                    cv.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        return moviesArray
    }
    //insert this code where you want to display image with url of poster of movie
    /*let helper = Helper()
     helper.downloadAndSetImage(movie,imageview)
     */
    func downloadAndSetImage(movie:Movie,imageView:UIImageView){
        let imageUrl:NSURL? = NSURL(string: movie.poster_path)
        if let url = imageUrl{
            imageView.sd_setImage(with:url as URL)
        }
        
    }
   //insert this code to get movie trailers urls to display
    /*
     let helper = Helper()
     let trailers = helper.getTrailers(movie)
    */
   func getTrailers(movie:Movie)-> [Trailer]{
    var trailer = Trailer()
    var trailersArray = [Trailer]()
    AF.request("http://api.themoviedb.org/3/movie/\(movie.id)"+"/videos?api_key=f6eee4ea0a39d56930047ec50ad3341c").responseJSON { response in
        switch response.result
        {
        case .success(let value):
            let json = JSON(value)
            //
            let trailersResult = json["results"].array
            for n in 0..<trailersResult!.count {
                trailer.trailerID = trailersResult![n]["key"].string!
                trailer.trailerName = trailersResult![n]["name"].string!
                trailersArray.append(trailer)
            }
            movie.trailers=trailersArray
        case .failure(let error):
            print(error)
        }
    }
    return trailersArray
     }
    //insert this code where you want to display youtube video trailer on a view
    /*
     let helper = Helper()
     helper.viewTrailer(view,movie.trailers[index].trailerID)
    */
    //important note make sure to change view class from UIView to WKYTPlayerView
    
    func viewTrailer(playerView:WKYTPlayerView,videoID:String){
       playerView.load(withVideoId: videoID)
     }
    
    
    //insert this code to get movie trailers urls to display
    /*
     let helper = Helper()
     let trailers = helper.getReviews(movie)
     */
    func getReviews(movie:Movie)-> [Review]{
        let review = Review()
        var reviewsArray = [Review]()
        AF.request("http://api.themoviedb.org/3/movie/\(movie.id)"+"/reviews?api_key=f6eee4ea0a39d56930047ec50ad3341c").responseJSON { response in
            switch response.result
            {
            case .success(let value):
                let json = JSON(value)
                let reviewsResult = json["results"].array
                for n in 0..<reviewsResult!.count {
                    review.author = reviewsResult![n]["author"].string
                    review.content = reviewsResult![n]["content"].string
                    reviewsArray.append(review)
                }
                movie.reviews = reviewsArray
            case .failure(let error):
                print(error)
            }
        }
        return reviewsArray
    }
    //insert this code where you want to display rating in stars
    //helper.displayRateInStars(movie,view)
    //important note change class view to CosmosView and Set its module property to Cosmos
    func displayRateInStars(movie:Movie,cosmosView:CosmosView) {
        cosmosView.rating = movie.vote_average/2
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 5
        cosmosView.settings.filledColor = UIColor.blue
        cosmosView.settings.emptyBorderColor = UIColor.blue
        cosmosView.settings.filledBorderColor = UIColor.blue
        
     }
    func savePopularMovie(movie:Movie){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let movieEntity = NSEntityDescription.entity(forEntityName: "Movies_Popular",in: managedContext)!
        let movie = NSManagedObject(entity:movieEntity, insertInto: managedContext)
        movie.setValue(movie.title,forKey:"title")
        movie.setValue(movie.overview,forKey:"overview")
        movie.setValue(movie.poster_path,forKey:"poster_path")
        movie.setValue(movie.id,forKey:"id")
        movie.setValue(movie.release_date,forKey:"release_date")
        movie.setValue(movie.trailers,forKey:"trailers")
        movie.setValue(movie.vote_average,forKey:"vote_average")
        movie.setValue(movie.reviews,forKey:"reviews")
        do {
            try managedContext.save()
            print("Done")
        }catch let error as NSError{
            print("couldnt save data !!")
        }
        
    }
    func getTopRatedMoviesOffline() -> [Movie] {
        let moc = ""
        let moviesFetch = NSFetchRequest(entityName: "Movies_Top_Rated")
        
        do {
            let fetchedMovies = try moc.executeFetchRequest(moviesFetch) as! [Movie]
        } catch {
            fatalError("Failed to fetch Movies: \(error)")
        }

        return fetchedMovies
    }
    
    func getPopularMoviesOffline() -> [Movie] {
        let moc = ""
        let moviesFetch = NSFetchRequest(entityName: "Movies_Popular")
        
        do {
            let fetchedMovies = try moc.executeFetchRequest(moviesFetch) as! [Movie]
        } catch {
            fatalError("Failed to fetch Movies: \(error)")
        }
        
        return fetchedMovies
    }
    
    func getFavorites()-> [Movie]{
        let moc = ""
        let moviesFetch = NSFetchRequest(entityName: "Favourites")
        
        do {
            let fetchedMovies = try moc.executeFetchRequest(moviesFetch) as! [Movie]
        } catch {
            fatalError("Failed to fetch Movies: \(error)")
        }
        
        return fetchedMovies
    }
    func addToFavorites(movie:Movie){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let movieEntity = NSEntityDescription.entity(forEntityName: "Favourites",in: managedContext)!
        let movie = NSManagedObject(entity:movieEntity, insertInto: managedContext)
        movie.setValue(movie.title,forKey:"title")
        movie.setValue(movie.overview,forKey:"overview")
        movie.setValue(movie.poster_path,forKey:"poster_path")
        movie.setValue(movie.id,forKey:"id")
        movie.setValue(movie.release_date,forKey:"release_date")
        movie.setValue(movie.trailers,forKey:"trailers")
        movie.setValue(movie.vote_average,forKey:"vote_average")
        movie.setValue(movie.reviews,forKey:"reviews")
        do {
            try managedContext.save()
            print("Done")
        }catch let error as NSError{
            print("couldnt save data !!")
        }
    }
    
    func removeFromFavorites(id:Int){
        let fetchRequest: NSFetchRequest<Favourites> = Favourites.fetchRequest()
        fetchRequest.predicate = Predicate.init(format: "id==\(id)")
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch _ {
            print("error cant delete favourite")
        }
    }

    func checkIfMovieIsFav(id:Int)-> bool{
        let fetchRequest: NSFetchRequest<Favourites> = Favourites.fetchRequest()
        fetchRequest.predicate = Predicate.init(format: "id==\(id)")
        
        do {
            let objects = try context.fetch(fetchRequest)
        } catch _ {
            print("error cant delete favourite")
        }
        if objects.count>0 {
            return true
        }
     return false
     }

}
