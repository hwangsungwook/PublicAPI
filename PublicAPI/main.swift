//
//  main.swift
//  PublicAPI
//
//  Created by 성욱 on 2021/07/23.
//

import Foundation
import SQLite

let db = try Connection("/Users/sungwook/Documents/Dev/PublicAPI/PublicAPI/db.sqlite3")

let users = Table("users")
let id = Expression<Int64>("id")
let name = Expression<String?>("name")
let email = Expression<String>("email")


let apis = Table("API_KEY")
let api_id = Expression<Int64>("API_Id")
let api_key = Expression<String>("API_Key")
let api_key_desc = Expression<String>("API_Key_Desc")
let svc_url = Expression<String>("SVC_URL")

let spec = Table("Spec")
var Spec_Id = Expression<String>("Spec_Id")
var bsnsDivNm = Expression<String>("bsnsDivNm")
var refNo = Expression<String>("refNo")
var prdctClsfcNoNm = Expression<String>("prdctClsfcNoNm")
var orderInsttNm = Expression<String>("orderInsttNm")
var rlDminsttNm = Expression<String>("rlDminsttNm")
var asignBdgtAmt = Expression<String>("asignBdgtAmt")
var rcptDt = Expression<String>("rcptDt")
var opninRgstClseDt = Expression<String>("opninRgstClseDt")
var ofclTelNo = Expression<String>("ofclTelNo")
var ofclNm = Expression<String>("ofclNm")
var swBizObjYn = Expression<String>("swBizObjYn")
var dlvrTmlmtDt = Expression<String>("dlvrTmlmtDt")
var dlvrDaynum = Expression<String>("dlvrDaynum")
var bfSpecRgstNo = Expression<String>("bfSpecRgstNo")
var specDocFileUrl1 = Expression<String>("specDocFileUrl1")
var specDocFileUrl2 = Expression<String>("specDocFileUrl2")
var specDocFileUrl3 = Expression<String>("specDocFileUrl3")
var specDocFileUrl4 = Expression<String>("specDocFileUrl4")
var specDocFileUrl5 = Expression<String>("specDocFileUrl5")
var prdctDtlList = Expression<String>("prdctDtlList")
var rgstDt = Expression<String>("rgstDt")
var chgDt = Expression<String>("chgDt")
var bidNtceNoList = Expression<String>("bidNtceNoList")

var api_key_koneps = ""

let inqryBgnDt = "202107010000" //조회시작
let inqryEndDt = "202107272359" //조회마감

for api in try db.prepare(apis) {
    do {
        print("api_id: \(api[api_id]), api_key: \(api[api_key]), api_key_desc: \(api[api_key_desc])")
        api_key_koneps = api[api_key]
        
    }
//    catch {
//        print("Error in prepare\(error)")
//    }
}

print("api_key_koneps=\(api_key_koneps)")

var weatherURL = "http://apis.data.go.kr/1230000/HrcspSsstndrdInfoService/getPublicPrcureThngInfoServc?serviceKey="

weatherURL.append(api_key_koneps)
weatherURL.append("&numOfRows=10&pageNo=1&inqryDiv=1&inqryBgnDt=202107010000")
weatherURL.append("&inqryEndDt=202107272359&bfSpecRgstNo=356759&type=json")

// URL, 조회조건 생성
func makeURL(with numOfRows :String, with pageNo :String) {

    var url = "http://apis.data.go.kr/1230000/HrcspSsstndrdInfoService/getPublicPrcureThngInfoServc?serviceKey="
    
    url += api_key_koneps
    url += "&numOfRows=" + String(numOfRows)
    url += "&pageNo=" + String(pageNo)
    url += "&inqryDiv=" + "1"
    url += "&inqryBgnDt=" + inqryBgnDt
    url += "&inqryEndDt=" + inqryEndDt
    url += "&bfSpecRgstNo=" + ""
    url += "&type=" + "json"
    
    //print("url=\(url)")
}

func fetchData() {
    let urlString = "\(weatherURL)"
    //print(urlString)
    performRequest(with: urlString)
}

func performRequest(with urlString: String) {
    if let url = URL(string: urlString) {
        
        let sema = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let safeData = data {
//                if let weather = parseJSON(safeData) {
//                    print(weather)
//                }
                makeURL(with: "1", with: "1")
                parseJSON(safeData)
            }
            
            sema.signal()
        }
        
        task.resume()
        sema.wait()
    }
}

func parseJSON(_ apiData: Data) {
    let decoder = JSONDecoder()
    //let itemList = [Items]()
    
    do {
        let decodedData = try decoder.decode(ApiData.self, from: apiData)
        let rowCount: Int = decodedData.response.body.numOfRows
        let totalCount: Int = decodedData.response.body.totalCount
        
        print("totalCount=\(totalCount)")
        for index in 0...rowCount-1 {

            print("rowCount=\(rowCount)")
            // decodedData 형을 바로 insert 가능
            let insert = try spec.insert(decodedData.response.body.items[index])
            
            let rowid = try db.run(insert)
            
            print("\(rowid)=Inserted")
        }
        
        return
        
    } catch {
        print("error: \(error)")
        return
    }
}

fetchData()

