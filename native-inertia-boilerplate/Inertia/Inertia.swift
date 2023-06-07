//
//  Inertia.swift
//  ebill
//
//  Created by Mario Hamann on 25.02.23.
//

import Foundation
import SwiftyJSON
import WebKit

class Inertia {
  /// Initializer that set webView
  init() {
  }

  static func render(component: String, props: [String: Any], url: String) -> String {
    print("Props", props)
    let response = JSON([
      "component": component,
      "props": props,
      "url": url,
    ])
    print("Response", response)
    return """
      window.dispatchEvent(new CustomEvent('native-inertia', { detail: \(response.rawString()!) }));
      """
  }

  static func setup(webView: WKWebView, router: InertiaRouter) -> WKWebView {
    webView.configuration.userContentController.add(router, name: "native-inertia")
    if #available(iOS 16.4, *) { webView.isInspectable = true; }

    if let useLocalFileString = ProcessInfo.processInfo.environment["useLocalFile"],
      let _ =
        Bool(useLocalFileString)
    {
      print("prod")
      let path = Bundle.main.url(forResource: "www-dist", withExtension: nil, subdirectory: nil)
      guard let baseURL = path else {
        print("Failed to find the base URL for the web content.")
        return WKWebView()
      }
      /// Allow file access from file URLs
      webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
      /// Load the local index.html file
      let indexFile = baseURL.appendingPathComponent("index.html")
      webView.loadFileURL(indexFile, allowingReadAccessTo: baseURL)
    } else {
      print("dev")
      /// Load the remote URL
      let url = URL(string: "http://localhost:5173")!
      webView.load(URLRequest(url: url))
    }

    return webView
  }
}
