//
// Tests.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
import WKZombie

class Tests: XCTestCase {
    
    var browser : WKZombie!
    
    override func setUp() {
        super.setUp()
        browser = WKZombie(name: "WKZombie Tests")
    }
    
    override func tearDown() {
        super.tearDown()
        browser = nil
    }
    
    func testExecute() {
        let expectation = expectationWithDescription("JavaScript Done.")
        
            browser.open(startURL())
        >>> browser.execute("document.title")
        === { (result: JavaScriptResult?) in
            XCTAssertEqual(result, "WKZombie Test Page")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testInspect() {
        let expectation = expectationWithDescription("Inspect Done.")
        var originalPage : HTMLPage?
        
        browser.open(startURL())
        >>> browser.map { originalPage = $0 as HTMLPage }
        >>> browser.inspect()
        === { (result: HTMLPage?) in
            if let result = result, originalPage = originalPage {
                XCTAssertEqual(result.data, originalPage.data)
            } else {
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
 
    func testButtonPress() {
        let expectation = expectationWithDescription("Button Press Done.")
        
        browser.open(startURL())        
        >>> browser.get(by: .Name("button"))
        >>> browser.press
        >>> browser.execute("document.title")
        === { (result: JavaScriptResult?) in
            XCTAssertEqual(result, "WKZombie Result Page")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testFormSubmit() {
        let expectation = expectationWithDescription("Form Submit Done.")
        
        browser.open(startURL())
            >>> browser.get(by: .Id("test_form"))
            >>> browser.submit
            >>> browser.execute("document.title")
            === { (result: JavaScriptResult?) in
                XCTAssertEqual(result, "WKZombie Result Page")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testFormWithXPathQuerySubmit() {
        let expectation = expectationWithDescription("Form XPathQuery Submit Done.")
        
        browser.open(startURL())
            >>> browser.get(by: .XPathQuery("//form[1]"))
            >>> browser.submit
            >>> browser.execute("document.title")
            === { (result: JavaScriptResult?) in
                XCTAssertEqual(result, "WKZombie Result Page")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testDivOnClick() {
        let expectation = expectationWithDescription("DIV OnClick Done.")
        
        browser.open(startURL())
            >>> browser.get(by: .Id("onClick_div"))
            >>> browser.map { $0.objectForKey("onClick")! }
            >>> browser.execute
            >>> browser.inspect()
            >>> browser.execute("document.title")
            === { (result: JavaScriptResult?) in
                XCTAssertEqual(result, "WKZombie Result Page")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testDivHref() {
        let expectation = expectationWithDescription("DIV Href Done.")
        
        browser.open(startURL())
            >>> browser.get(by: .Id("href_div"))
            >>> browser.map { "window.location.href='\($0.objectForKey("href")!)'" }
            >>> browser.execute
            >>> browser.inspect()
            >>> browser.execute("document.title")
            === { (result: JavaScriptResult?) in
                XCTAssertEqual(result, "WKZombie Result Page")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testUserAgent() {
        let expectation = expectationWithDescription("UserAgent Test Done.")
        browser.userAgent = "WKZombie"
    
        browser.open(startURL())
        >>> browser.execute("navigator.userAgent")
        === { (result: JavaScriptResult?) in
                XCTAssertEqual(result, "WKZombie")
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testSnapshot() {
        let expectation = expectationWithDescription("Snapshot Test Done.")

        var snapshots = [Snapshot]()
        
        browser.snapshotHandler = { snapshot in
            XCTAssertNotNil(snapshot.image)
            snapshots.append(snapshot)
        }
        
        browser.open(startURL())
        >>> browser.snap
        >>> browser.get(by: .Name("button"))
        >>> browser.press
        >>> browser.snap
        === { (result: HTMLPage?) in
            XCTAssertEqual(snapshots.count, 2)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    func testSwap() {
        let expectation = expectationWithDescription("iFrame Button Test Done.")
        
        browser.open(startURL())
        >>> browser.get(by: .XPathQuery("//iframe[@name='button_frame']"))
        >>> browser.swap
        >>> browser.get(by: .XPathQuery("//button[@name='button2']"))
        >>> browser.press
        >>> browser.execute("document.title")
        === { (result: JavaScriptResult?) in
            XCTAssertEqual(result, "WKZombie Result Page")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0, handler: nil)
    }
    
    //========================================
    // MARK: Helper Methods
    //========================================
    
    private func startURL() -> NSURL {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testPage = bundle.URLForResource("HTMLTestPage", withExtension: "html")!
        return testPage
    }
}
