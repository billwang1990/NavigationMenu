//
//  DropDownMenuConfiguration.swift
//  YQNavigationBarMenuDemo
//
//  Created by Yaqing Wang on 12/5/15.
//  Copyright © 2015 thoughtworks. All rights reserved.
//

import UIKit

public struct DropDownMenuConfiguration {
    
    static let shareInstance = DropDownMenuConfiguration()
    
    // The color of the text inside cell. Default is darkGrayColor()
    public var cellTextLabelColor: UIColor = .darkGrayColor()
    
    // The font of the text inside cell. Default is HelveticaNeue-Bold, size 17
    public var cellTextLabelFont: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 17)!
    
    // The animation duration of showing/hiding menu. Default is 0.3
    public var animationDuration: NSTimeInterval  = 0.3
    
    // The arrow next to navigation title
    public var maxItemsPerRow: Int = 4
    
    // The opacity of the mask layer. Default is 0.3
    public var maskBackgroundOpacity: CGFloat = 0.3
    
    // The color of menu. Default is white
    public var menuBackgroundColor: UIColor = .clearColor()
    
    // The padding between navigation title and arrow
    public var arrowPadding: CGFloat = 15.0
    
    public var arrowImage: UIImage = UIImage(named:"arrow_down_icon")!
    
}