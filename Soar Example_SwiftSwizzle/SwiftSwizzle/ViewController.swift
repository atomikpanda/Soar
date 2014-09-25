//
//  ViewController.swift
//  SwiftSwizzle
//
//  Created by Bailey Seymour on 9/20/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveC
import Swift

var tweakEnabled = false;

@asmname("orig_BlueClass_hello") func orig_BlueClass_hello(name: NSString)

func typename (thing:Any) -> String{
    let name = _stdlib_getTypeName(thing)
    let demangleName = _stdlib_demangleName(name)
    return demangleName.componentsSeparatedByString(".").last!
}

class BlueClass {
    class func hello(name: NSString) {
        //Say "Hello".
        println("Hello, \(name)!")
    }
}

class RedClass {

    class func hellogoodbye(name: NSString) {
        //Run original function to say "Hello" first.
        orig_BlueClass_hello(name)
        
        if tweakEnabled {
        //Say "Goodbye".
        println("Goodbye, \(name)!")
        }
    }
}


class ViewController: UIViewController {

    var tweakEnabledSwitch: UISwitch = UISwitch();
    var button: UIButton = UIButton();

     func toggled(sender: UIButton) {
        tweakEnabled = tweakEnabledSwitch.on
        if tweakEnabled {
            println("--> Tweak Enabled")
        }
        else if !tweakEnabled {
            println("--> Tweak Disabled")
        }
    }
    func buttonPressed(sender: UIButton) {
        //Normally prints "Hello, <name>!"
        BlueClass.hello("Bailey")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SET UP VIEWS & FRAMES
        self.tweakEnabledSwitch.frame = CGRectMake(self.view.center.x-(tweakEnabledSwitch.frame.size.width/2), self.view.center.y-(tweakEnabledSwitch.frame.size.height/2), tweakEnabledSwitch.frame.size.width, tweakEnabledSwitch.frame.size.height)
        self.tweakEnabledSwitch.addTarget(self, action: Selector("toggled:"), forControlEvents: UIControlEvents.ValueChanged)
        
       
        self.button.frame = CGRectMake(self.view.center.x-(50), (self.view.center.y-(50))+100, 100, 100)
        self.button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.button.setTitle("Print", forState: UIControlState.Normal);
        self.button.backgroundColor = UIColor.darkGrayColor();
        self.button.layer.cornerRadius = 20;
        self.view.addSubview(self.tweakEnabledSwitch);
        self.view.addSubview(self.button);
        
        self.toggled(button);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

