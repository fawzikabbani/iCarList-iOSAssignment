//
//  Assigment.swift
//  iCarList-iOSAssignment-Chat
//
//  Created by Faowzy on 12/4/16.
//  Copyright © 2016 Faowzy. All rights reserved.
//

import Foundation

public class Checker {
    ///////// FAOWZY CODE ////////
    static func getHTMLTitle(html: String) -> String {
        if let open = html.rangeOfString("<title>"), close = html.rangeOfString("</title>") {
            let enclosed = html.substringWithRange(Range(start: open.endIndex, end: close.startIndex))
            return enclosed
        }
        return ""
    }
    static func isCarlistHost(resultURL : NSURL) -> (Bool, String) {
        var pageTitle = ""
        if resultURL.host == "www.carlist.my" || resultURL.host == "carlist.my" {
            let HTMLString = NSURL(string: (resultURL.absoluteString))
                .flatMap { NSData(contentsOfURL: $0) }
                .flatMap { NSString(data: $0, encoding: NSASCIIStringEncoding) }
            pageTitle = self.getHTMLTitle(HTMLString as! String)
            return (true,pageTitle)
        }
        return (false,pageTitle)
    }
    static func obfuscateString(string: String,charecter: String, range: NSRange) -> String {
        let nsString = string as NSString
        var replasment = ""
        for _ in 1...(range.length) { replasment += charecter}
        let newString = nsString.stringByReplacingCharactersInRange(range, withString: replasment)
        return newString
    }
    static func getJSONFromStrings(string: String,url: String?, title: String?) -> [String : AnyObject]? {
        if (title?.characters.count > 0){
            let URLsCount = 1
            var jsonLinks = [[String: String]]()
            for j in 0..<URLsCount{
                let jsonLink: [String: String] = [ "url": url!, "title": title! ]
                jsonLinks.append(jsonLink)
            }
            let jsonItem = [ "message": string as String,
                             "Links":    jsonLinks as AnyObject] as [String : AnyObject]
            
            if NSJSONSerialization.isValidJSONObject(jsonItem) {
                return(jsonItem as AnyObject) as? [String : AnyObject]
            }else{
                print("Error: isValidJSONObject")
            }
        }else{
            let jsonItem = [ "message ": string as String ] as [String : AnyObject]
            if NSJSONSerialization.isValidJSONObject(jsonItem) {
                return jsonItem
            }else{
                print("Error: isValidJSONObject")
            }
        }
        return nil
    }
    static public func checkMessage(message: String) -> [String : AnyObject]? {
        var string = message
        var url : String?
        var title : String?
        
        let types: NSTextCheckingType = [.Link, .PhoneNumber]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatchesInString(string, options: [], range: NSMakeRange(0, (string as NSString).length)) { (result, flags, _) in
            if let _ = result!.phoneNumber{
                string = self.obfuscateString(string,charecter: "*", range: (result?.range)!)
            }
            if let _ = result!.URL?.host{
                let stringURL = self.isCarlistHost((result!.URL)!)
                if stringURL.0{
                    url = result!.URL?.absoluteString
                    string = string.substringToIndex(string.endIndex.advancedBy(-result!.range.length))
                    title = stringURL.1
                }else{
                    string = self.obfuscateString(string,charecter: "*", range: (result?.range)!)
                }
            }
        }
        return getJSONFromStrings(string,url: url,title: title)
    }
}