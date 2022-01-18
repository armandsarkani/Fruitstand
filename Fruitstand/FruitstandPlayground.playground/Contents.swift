import Foundation

struct Test {
    var x: String?
}


let dict = ["Yes": "No", "Hot": "Cold"]

var w = Test(x: dict["Jarumba"] ?? nil)

print(w)
