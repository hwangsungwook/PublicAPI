//
//  API_Data.swift
//  PublicAPI
//
//  Created by 성욱 on 2021/07/23.
//

struct ApiData: Codable {
    let response: response
}

struct response: Codable {
    let header: header
    let body: body
}

struct header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct body: Codable {
    let items: [Items]
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct Items: Codable {
    let bsnsDivNm: String       //
    let refNo: String           //
    let prdctClsfcNoNm: String  //
    let orderInsttNm: String    //
    let rlDminsttNm: String     //
    let asignBdgtAmt: String    //
    let rcptDt: String          //
    let opninRgstClseDt: String //
    let ofclTelNo: String       //
    let ofclNm: String          //
    let swBizObjYn: String      //
    let dlvrTmlmtDt: String     //
    let dlvrDaynum: String      //
    let bfSpecRgstNo: String    //
    let specDocFileUrl1: String //
    let specDocFileUrl2: String //
    let specDocFileUrl3: String //
    let specDocFileUrl4: String //
    let specDocFileUrl5: String //
    let prdctDtlList: String    //
    let rgstDt: String          //
    let chgDt: String           //
    let bidNtceNoList: String   //
}
