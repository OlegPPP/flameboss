//
//  ProgressView.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/21/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ProgressView : UIView
{
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var line1To2: UIView!
    @IBOutlet weak var line2To3: UIView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    private var line1To2ColorView: UIView!
    private var line2To3ColorView: UIView!
    
    private var progressColor = UIColor.createColor(red: 241, green: 53, blue: 59, alpha: 1.0)
    private var grayColor = UIColor.createColor(red: 223, green: 223, blue: 223, alpha: 1.0)
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("ProgressView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configure()
    }
    
    private func configure()
    {
        view1.layer.cornerRadius = view1.frame.width/1.8
        view2.layer.cornerRadius = view2.frame.width/1.8
        view3.layer.cornerRadius = view3.frame.width/1.8
    }
    
    public func animateFrom1To2()
    {
        let frame = CGRect(x: 0, y: 0, width: 0, height: line1To2.frame.height)
        line1To2ColorView = UIView(frame: frame)
        line1To2ColorView.backgroundColor = progressColor
        let newFrame = CGRect(x: 0, y: 0, width: line1To2.frame.width, height: line1To2.frame.height)
        line1To2.addSubview(line1To2ColorView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.line1To2ColorView.frame = newFrame
        })
        { (Bool) in
            self.view2.layer.borderColor = self.progressColor.cgColor
            self.label2.textColor = self.progressColor
        }
    }
    
    public func animateFrom2To1()
    {
        self.view2.layer.borderColor = self.grayColor.cgColor
        self.label2.textColor = self.grayColor
        let newFrame = CGRect(x: 0, y: 0, width: 0, height: line1To2.frame.height)
        
        UIView.animate(withDuration: 0.3) {
            self.line1To2ColorView.frame = newFrame
        }
    }
    
    public func animateFrom2To3()
    {
        let frame = CGRect(x: 0, y: 0, width: 0, height: line2To3.frame.height)
        line2To3ColorView = UIView(frame: frame)
        line2To3ColorView.backgroundColor = progressColor
        line2To3.addSubview(line2To3ColorView)
        let newFrame = CGRect(x: 0, y: 0, width: line2To3.frame.width, height: line2To3.frame.height)
        line2To3.addSubview(line2To3ColorView)
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.line2To3ColorView.frame = newFrame
        })
        { (Bool) in
            self.view3.layer.borderColor = self.progressColor.cgColor
            self.label3.textColor = self.progressColor
        }
    }
    
    public func animateFrom3To2()
    {
        self.view3.layer.borderColor = self.grayColor.cgColor
        self.label3.textColor = self.grayColor
        let newFrame = CGRect(x: 0, y: 0, width: 0, height: line2To3.frame.height)
        
        UIView.animate(withDuration: 0.3) { 
            self.line2To3ColorView.frame = newFrame
        }
    }
}
