////////////////////////////////////////////////////////////////////////////
// Copyright 2015 Viacom Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Modifications under MIT License
//
////////////////////////////////////////////////////////////////////////////
import Foundation

public class InertiaRoute {
    
    enum Pattern: String {
        case routeParam = ":[a-zA-Z0-9-_]+"
        case urlParam = "([^/]+)"
    }
    
    enum RegexResult: Error, CustomDebugStringConvertible {
        case success(regex: String)
        case duplicateInertiaRouteParamError(route: String, urlParam: String)
        
        var debugDescription: String {
            switch self {
            case .success(let regex):
                return "successfully parsed to \(regex)"
            case .duplicateInertiaRouteParamError(let route, let urlParam):
                return "duplicate url param \(urlParam) was found in \(route)"
            }
        }
    }
    
    let routeParameter = try! NSRegularExpression(pattern: Pattern.routeParam.rawValue, options: .caseInsensitive)
    let urlParameter = try! NSRegularExpression(pattern: Pattern.urlParam.rawValue, options: .caseInsensitive)
    
    // parameterized route, ie: /video/:id
    public let route: String
    
    // route in its regular expression pattern, ie: /video/([^/]+)
    var routePattern: String?
    
    // url params found in route
    var urlParamKeys = [String]()
    
    init(aRoute: String) throws {
        route = aRoute
        switch regex() {
        case .success(let regex):
            routePattern = regex
        case .duplicateInertiaRouteParamError(let route, let urlParam):
            throw RegexResult.duplicateInertiaRouteParamError(route: route, urlParam: urlParam)
        }
    }
    
    /**
        Forms a regex pattern of the route
    
        - returns: string representation of the regex
    */
    func regex() -> RegexResult {
        let _route = "^\(route)/?$"
        var _routeRegex = NSString(string: _route)
        let matches = routeParameter.matches(in: _route, options: [],
            range: NSMakeRange(0, _route.count))

        // range offset when replacing :params
        var offset = 0
        
        for match in matches as [NSTextCheckingResult] {
            
            var matchWithOffset = match.range
            if offset != 0 {
                matchWithOffset = NSMakeRange(matchWithOffset.location + offset, matchWithOffset.length)
            }
            
            // route param (ie. :id)
            let urlParam = _routeRegex.substring(with: matchWithOffset)
            
            // route param with ':' (ie. id)
            let name = (urlParam as NSString).substring(from: 1)

            // url params should be unique
            if urlParamKeys.contains(name) {
                return .duplicateInertiaRouteParamError(route: route, urlParam: name)
            } else {
                urlParamKeys.append(name)
            }
            
            // replace :params with regex
           
            _routeRegex =  _routeRegex.replacingOccurrences(of: urlParam, with: Pattern.urlParam.rawValue, options: NSString.CompareOptions.literal, range: matchWithOffset) as NSString
            
            // update offset
            offset += Pattern.urlParam.rawValue.count - urlParam.count
        }
            
        return .success(regex: _routeRegex as String)
    }
}

// MARK: Hashable
extension InertiaRoute: Hashable {
    public var hashValue: Int {
        return self.route.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.route.hashValue)
    }
    
}

// MARK: Equatable
extension InertiaRoute: Equatable {}

public func ==(lhs: InertiaRoute, rhs: InertiaRoute) -> Bool {
    return lhs.route == rhs.route
}

// MARK: NSRegularExpression
extension NSRegularExpression {
    
    convenience init(pattern: InertiaRoute.Pattern, options: NSRegularExpression.Options) throws {
        try self.init(pattern: pattern.rawValue, options: options)
    }
    
}
