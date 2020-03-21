
import UIKit
class Movie: NSObject {
    var title:String!
    var overview:String!
    var poster_path:String!
    var id :Int!
    var release_date:String!
    var trailers:[Trailer]!
    var vote_average:Double!
    var reviews:[Review]!
    
}

