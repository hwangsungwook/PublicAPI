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

for api in try db.prepare(apis) {
    do {
        print("api_id: \(api[api_id]), api_key: \(api[api_key]), api_key_desc: \(api[api_key_desc])")
        api_key_koneps = api[api_key]
        
    }
//    catch {
//        print("Error in prepare\(error)")
//    }
}


//for spec in try db.prepare(spec) {
//    do {
//       // print("bfSpecRgstNo: \(spec[bfSpecRgstNo]), refNo: \(spec[refNo])")
//        let spec_count = spec[bfSpecRgstNo]
//        //print("spec_count\(spec_count)")
//
//    }
////    catch {
////        print("Error in prepare\(error)")
////    }
//}

print("api_key_koneps=\(api_key_koneps)")

var weatherURL = "http://apis.data.go.kr/1230000/HrcspSsstndrdInfoService/getPublicPrcureThngInfoServc?serviceKey="

weatherURL.append(api_key_koneps)
weatherURL.append("&numOfRows=10&pageNo=1&inqryDiv=1&inqryBgnDt=202107230000")
weatherURL.append("&inqryEndDt=202107232359&bfSpecRgstNo=356759&type=json")


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
        
        for index in 0...rowCount-1 {

            //print(decodedData.response.body.items[index])
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

