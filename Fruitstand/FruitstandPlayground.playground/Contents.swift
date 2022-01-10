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
print(mgr2.product!)

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
    print(deviceName)
}
