import Foundation

class News{
    var title:String
    var imageUrl: String
    var contentUrl: String
    
    init (title:String, imageUrl:String, contentUrl:String){
        self.title=title
        self.imageUrl=imageUrl
        self.contentUrl=contentUrl
    }
}
