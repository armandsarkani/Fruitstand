import Foundation
import Combine

extension UserDefaults
{
  func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String)
  {
    let encoded = try? JSONEncoder().encode(data)
    set(encoded, forKey: defaultName)
   }
}

extension UserDefaults
{
  func getCodableObject<T : Codable>(dataType: T.Type, key: String) -> T?
  {
    guard let userDefaultData = data(forKey: key) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: userDefaultData)
  }
}

struct MacInfo: Codable
{
    var num: Int?
    var date: String?
    var year: String?
}
class MacInfoManager: ObservableObject
{
    var uuid: String
    @Published var product: MacInfo!
    {
        didSet
        {
            UserDefaults.standard.setCodableObject(product, forKey: uuid) // once product variable modified by view, set UserDefaults
            
        }
    }
    init(uuid: String)
    {
        self.uuid = uuid
        if((UserDefaults.standard.getCodableObject(dataType: MacInfo.self, key: uuid)) != nil)
        {
            self.product = UserDefaults.standard.getCodableObject(dataType: MacInfo.self, key: uuid)
        }
    }
}

var test = MacInfo(num: 31, date: "1/9/2022")
var uuid = UUID().uuidString
let mgr = MacInfoManager(uuid: uuid)
mgr.product = test
let mgr2 = MacInfoManager(uuid: uuid)

let UUIDArray = ["AppleTV_01249-83ffe2-2c31b", "Apple Watch_01249-849fe2-2b31d", "Mac_94149-481e2-77cb3"]
var matchingUUIDArray: [String]
for uuid in UUIDArray
{
    let delimiterLocation = uuid.firstIndex(of: "_")
    var deviceName = uuid[...delimiterLocation!]
    deviceName.remove(at: delimiterLocation!)
    if(deviceName == "AppleTV")
    {
        deviceName = "Apple TV"
    }
    else if(deviceName == "AppleWatch")
    {
        deviceName = "Apple Watch"
    }
}

enum iPhoneModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "iPhone (1st generation)"
    case _3G = "iPhone 3G"
    case _3GS = "iPhone 3GS"
    case _4 = "iPhone 4"
    case _5 = "iPhone 5"
    case _5c = "iPhone 5c"
    case _5s = "iPhone 5s"
    case _6 = "iPhone 6"
    case _6Plus = "iPhone 6 Plus"
    case _6s = "iPhone 6s"
    case _6sPlus = "iPhone 6s Plus"
    case _SE1stGen = "iPhone SE (1st generation)"
    case _7 = "iPhone 7"
    case _7Plus = "iPhone 7 Plus"
    case _8 = "iPhone 8"
    case _8Plus = "iPhone 8 Plus"
    case _X = "iPhone X"
    case _XR = "iPhone XR"
    case _XS = "iPhone XS"
    case _XSMax = "iPhone XS Max"
    case _11 = "iPhone 11"
    case _11Pro = "iPhone 11 Pro"
    case _11ProMax = "iPhone 11 Pro Max"
    case _SE2ndGen = "iPhone SE (2nd generation)"
    case _12Mini = "iPhone 12 mini"
    case _12 = "iPhone 12"
    case _12Pro = "iPhone 12 Pro"
    case _12ProMax = "iPhone 12 Pro Max"
    case _13Mini = "iPhone 13 mini"
    case _13 = "iPhone 13"
    case _13Pro = "iPhone 13 Pro"
    case _13ProMax = "iPhone 13 Pro Max"
    case Other = "Other"

    var id: String { self.rawValue }
    static var asArray: [iPhoneModel] {return self.allCases}
    func asInt() -> Int {
         return iPhoneModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> Bool {
        if(self.asInt() < iPhoneModel._X.asInt() || self == iPhoneModel._SE2ndGen)
        {
            return true
        }
        return false
    }
}
print(iPhoneModel._XSMax.getIcon())


