import Foundation

class Order{
    var title:String
    var number: String
    var price: String
    var total: String
    var date: String
    
    init (title:String, number:String, price:String,total: String,date: String){
        self.title=title
        self.number=number
        self.price = price
        self.total=total
        self.date=date
    }
}

