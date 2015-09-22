//
//  AppDelegate.swift
//  image2text_macserver
//
//  Created by Tanmay Bakshi on 2015-08-03.
//  Copyright © 2015 Tanmay Bakshi. All rights reserved.
//

import Cocoa
import AppKit

class DrawView: NSView {
    
    var path = NSBezierPath()
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer!.backgroundColor = NSColor.blackColor().CGColor
    }
    
    override func keyDown(theEvent: NSEvent) {
        var keyChar = theEvent.characters
        if keyChar == "c" {
            path.removeAllPoints()
            self.needsDisplay = true
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        var loc = theEvent.locationInWindow
        loc.x -= self.frame.origin.x
        loc.y -= self.frame.origin.y
        path.moveToPoint(loc)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        var loc = theEvent.locationInWindow
        loc.x -= self.frame.origin.x
        loc.y -= self.frame.origin.y
        path.lineToPoint(loc)
        self.needsDisplay = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor.redColor().set()
        path.lineCapStyle = NSLineCapStyle.RoundLineCapStyle
        path.lineWidth = 15
        path.stroke()
    }
    
}

extension NSImage {
    var imagePNGRepresentation: NSData {
        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSJPEGFileType, properties: [:])!
    }
    func savePNG(path:String) -> Bool {
        return imagePNGRepresentation.writeToFile(path, atomically: true)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var imagePath: NSTextField!
    @IBOutlet var output: NSTextField!
    @IBOutlet var drawView: DrawView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        //self.window.setFrame(NSRect(x: self.window.frame.origin.x, y: self.window.frame.origin.y, width: 1564, height: 650), display: true)
    }
    
    @IBAction func convertImage(sender: NSButton) {
        let dot = "."
        if imagePath.stringValue.containsString("http") || imagePath.stringValue.containsString("https") && imagePath.stringValue.containsString("://") {
            let path = "\(NSHomeDirectory())/downloadedImage.jpg"
            NSImage(data: NSData(contentsOfURL: NSURL(string: imagePath.stringValue)!)!)!.savePNG(path)
            output.stringValue = run("sh ~/tesseract.sh \(path) \(path.componentsSeparatedByString(dot)[1])").read()
        } else {
            output.stringValue = run("sh ~/tesseract.sh \(imagePath.stringValue) \(imagePath.stringValue.componentsSeparatedByString(dot)[1])").read()
        }
    }
    
    @IBAction func help(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://image2text.tanmaybakshi.com/")!)
    }
    
    @IBAction func handwriting(sender: NSButton) {
        let dot = "."
        let path = "\(NSHomeDirectory())/handwritingImage.jpg"
        NSImage(data: drawView.dataWithPDFInsideRect(drawView.bounds))!.savePNG(path)
        output.stringValue = run("sh ~/tesseract.sh \(path) \(path.componentsSeparatedByString(dot)[1])").read()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}

