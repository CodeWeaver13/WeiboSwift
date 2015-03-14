//
//  String+Hash.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import Foundation
extension String {
    /// 返回字符串MD5散列化的结果
//    var md5: String! {
//            let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
//            let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
//            var result = UnsafeMutablePointer<UInt8>.alloc(16)
//            
//            CC_MD5(str!, strLen, result)
//            
//            var hash: String = ""
//            for var i = 0; i < 16; ++i {
//                let abc = NSString(format: "%02x", result[i]) as String
//                hash += abc
//            }
//        
//        result.dealloc(16)
////        result = nil
//        return hash
//    }
    /// 返回字符串的 MD5 散列结果
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return hash.copy() as! String
    }
}
//    extension Int {
//        func hexString() -> String {
//            autoreleasepool {
//                let str = String.localizedStringWithFormat("%02x", self)
//                return str
//            }
//        }
//    }
//    
//    extension NSData {
//        func hexString() -> String {
//            var string = String()
//            for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
//                string += Int(i).hexString()
//            }
//            return string
//        }
//        
//        func MD5() -> NSData {
//            let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
//            CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
//            return NSData(data: result)
//        }
//        
//        func SHA1() -> NSData {
//            let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
//            CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
//            return NSData(data: result)
//        }
//    }
//    
//    extension String {
//        func MD5() -> String {
//            return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexString()
//        }
//        
//        func SHA1() -> String {
//            return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexString()
//        }
//    }