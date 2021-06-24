//
//  ViewController.swift
//  test
//
//  Created by 黃肇祺 on 2021/6/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var countiesTextField: UITextField!
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var roadTextField: UITextField!
    @IBOutlet weak var allAddressTextField: UITextField!
    
    @IBOutlet weak var countriesPicker: UIPickerView!
    @IBOutlet weak var sitePicker: UIPickerView!
    @IBOutlet weak var roadPicker: UIPickerView!
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    
    //MARK: 地址全部填完後定位
    @IBAction func confirmButton(_ sender: Any) {
        
        //沒填完顯示警告
        if roadTextField.text?.isEmpty == true || allAddressTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "資料不完整", message: "請填完整地址", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            //傳回完整地址，執行定位
            totalAdress = "\(siteTextField.text ?? "")\(roadTextField.text ?? "")\(allAddressTextField.text ?? "")"
            showmap()
        }
    }
    
    
    let countiesArrays = ["臺北市", "新北市", "基隆市", "桃園市", "新竹縣", "新竹市", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義縣", "嘉義市", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣", "連江縣", ]
    
    //匯入從json讀取的array
    var completeArrays = Address.data
    
    var selectedCounties: String = "金門縣"
    var selectedSite: String = ""
    
    var trueNumber = 0
    var falseNumber = 0
    
    var rangeArrays = [Int]()
    
    var realSite_idArrays = [Address]()
    
    var site_idArrays = [Address]()
    var roadArrays = [String]()
    
    var totalAdress = ""
    
    var adressPlace = CLPlacemark()
    var x = CLLocationDegrees()
    var y = CLLocationDegrees()
    
    
    //viewDidLoad放置代理delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        countiesTextField.delegate = self
        siteTextField.delegate = self
        roadTextField.delegate = self
        countriesPicker.delegate = self
        countriesPicker.dataSource = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        roadPicker.delegate = self
        roadPicker.dataSource = self
        
        countiesTextField.inputView = countriesPicker
        siteTextField.inputView = sitePicker
        roadTextField.inputView = roadPicker
        
        siteTextField.alpha = 0
        roadTextField.alpha = 0
        allAddressTextField.alpha = 0
        
        //確保陣列分解正確，先進行排序
        completeArrays.sort { address1, address2 in
            return address1.site_id.compare(address2.site_id) == .orderedAscending
            
        }
        
    }
    
    
    //點擊空白處會隱藏uipickerView
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: UIPickerView的設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return 22
        case 2:
            return site_idArrays.count
        default:
            return roadArrays.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return countiesArrays[row]
        case 2:
            return site_idArrays[row].site_id
        default:
            return roadArrays[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        //MARK: -縣市選單
        case 1:
            //為應付使用者重複選擇，每次會重置
            siteTextField.alpha = 0
            roadTextField.alpha = 0
            allAddressTextField.alpha = 0
            
            realSite_idArrays = []
            site_idArrays = []
            roadArrays = []
            rangeArrays = []
            trueNumber = 0
            falseNumber = 0
            
            countiesTextField.text = countiesArrays[row]
            selectedCounties = countiesArrays[row]
            let total = completeArrays.count - 1
            
            //計算被選取的縣市在哪個區間
            for n in 0...total {
                if completeArrays[n].city == selectedCounties {
                    trueNumber += 1
                    if trueNumber == 1 {
                        rangeArrays.append(falseNumber)
                    }
                } else {
                    falseNumber += 1
                }
            }
            rangeArrays.append(trueNumber)
            
            //讀取計算出的區間，置入新的陣列，並去掉重複的鄉鎮名稱
            let firstN = rangeArrays[0]
            let secondN = rangeArrays[1] - 1
            var anArrays = [Address]()
            
            for x in 0...secondN {
                let n = firstN + x
                anArrays.append(completeArrays[n])
            }
            
            //保留所有路名選項
            realSite_idArrays = anArrays
            
            let total1 = anArrays.count - 1
            var countANN = 0
            var countArrays = [Int]()
            var countArraysN = 0
            var theNumber = 0
            
            while countANN != anArrays.count {
                if countANN != 0 {
                    for x in 0...total1 {
                        if anArrays[x].site_id == anArrays[countArrays[theNumber]].site_id {
                            countANN += 1
                        }
                    }
                    countArrays.append(countANN)
                    countArraysN += 1
                    theNumber = countArrays.count - 1
                    

                } else {
                    for n in 0...total1 {
                        if anArrays[n].site_id == anArrays[0].site_id {
                            countANN += 1
                        }
                    }
                    countArrays.append(countANN)
                    countArraysN = 0
                }
            }
            
            let site_idCount = countArrays.count - 1
            
            for m in 0...site_idCount {
                let h = countArrays[m] - 1
                site_idArrays.append(anArrays[h]) //放入第二個UIPickerView
            }
            
            //顯現下一個Picker
            siteTextField.alpha = 1
            
            //picker重載入
            pickerView.reloadAllComponents()
            
        //MARK: - 鄉鎮市區選單
        case 2:
            
            //與第一輪配置相同
            roadTextField.alpha = 0
            roadArrays = []
            rangeArrays = []
            trueNumber = 0
            falseNumber = 0
            
            siteTextField.text = site_idArrays[row].site_id
            selectedSite = site_idArrays[row].site_id
            
            let thirdN = realSite_idArrays.count - 1
            
            realSite_idArrays.sort { add1, add2 in
                return add1.site_id.compare(add2.site_id) == .orderedAscending
            }
            
            for n in 0...thirdN {
                if realSite_idArrays[n].site_id == selectedSite {
                    trueNumber += 1
                    if trueNumber == 1 {
                        rangeArrays.append(falseNumber)
                    }
                } else {
                    falseNumber += 1
                }
            }
            print(trueNumber) //測試數字
            print(falseNumber)
            
            rangeArrays.append(trueNumber)
            
            let firstN = rangeArrays[0]
            let secondN = rangeArrays[1] - 1
            
            for x in 0...secondN {
                let y = firstN + x
                roadArrays.append(realSite_idArrays[y].road) //路名UIPickerView資料
            }
            
            roadArrays.sort { road1, road2 in
                return road1.compare(road2) == .orderedAscending
            }
            roadTextField.alpha = 1
            
            pickerView.reloadAllComponents()
            
        case 3:
            allAddressTextField.alpha = 0
            roadTextField.text = roadArrays[row]
            allAddressTextField.alpha = 1
            
        default:
            break
            
        }
    }
}


//ＪＳＯＮ資料讀取
extension Address {
    static var data: [Address] {
        var arrays = [Address]()
        if let data = NSDataAsset(name: "csvjson")?.data {
            let decoder = JSONDecoder()
            print("1")
            
            do {
                arrays = try decoder.decode([Address].self, from: data)
            } catch { print(error) }
        }
        return arrays
    }
    
    
}

extension ViewController {
    
    
    //定位動作
    func showmap() {
        
        /*let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(totalAdress) { placemark, error in
            if let error = error,
               let place = placemark {
                print(error)
                
                self.adressPlace = place[0]
                self.x = self.adressPlace.location?.coordinate.latitude ?? 0.0
                self.y = self.adressPlace.location?.coordinate.longitude ?? 0.0
            }
            
        }
        
        
        mapKitView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: x, longitude: y), latitudinalMeters: 1000, longitudinalMeters: 1000)*/
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = totalAdress
        request.region = mapKitView.region
        MKLocalSearch(request: request).start { response, error in
            guard error == nil, response != nil else {return}
            
            
            for item in response!.mapItems {
                self.mapKitView.addAnnotation(item.placemark)
                self.mapKitView.region = MKCoordinateRegion(center: item.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                
                //self.mapKitView.setCenter(item.placemark.coordinate, animated: false)
            }
        }
    }
}
