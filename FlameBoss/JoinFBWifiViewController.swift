//
//  JoinFBWifiViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/19/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class JoinFBWifiViewController : UIViewController
{
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var connectionDetailLabel: UILabel!
    @IBOutlet weak var continueButtonLabel: UILabel!
    
    @IBOutlet weak var connectionStatusView: UIView!
    @IBOutlet weak var connectingView: UIView!
    @IBOutlet weak var connectedView: UIImageView!
    
    private var continueButtonPressed = false
    
    public weak var flameBossCommunicator: SmokerDeviceCommunicator?
    
    var nextPage: (() -> ())!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
        receiveAppBecameActiveNotification()
    }
    
    private var newVariable = true
    
    private func configure()
    {
        configureInstructionLabel()
        connectionStatusView.isHidden = true
        connectedView.isHidden = true
    }

    private func configureInstructionLabel()
    {
        let normalAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 19.0)]
        let boldAttrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 19.0)]

        let a = NSMutableAttributedString(string:
            "Press the Wifi Settings button below and join the network named\n", attributes: normalAttrs)

        a.append(NSMutableAttributedString(string: "FB-#####", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string: " (the number is your device ID).\n\nThen return to this app.\n", attributes: normalAttrs))

        instructionLabel.attributedText = a
    }
    
    private func receiveAppBecameActiveNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive),
                                               name: Notification.Name(rawValue: "AppBecameActive"), object: nil)
    }
    
    func appBecameActive()
    {
        guard let flameBossCommunicator = flameBossCommunicator else { return }
        
        if continueButtonPressed == true && continueButtonLabel.text == "WIFI SETTINGS"
        {
            connectionStatusView.isHidden = false
            
            flameBossCommunicator.tryConnecting(completion: { (error) in
                
                if error == nil
                {
                    self.configureViewForConnected()
                }
                else
                {
                    print("\nError Connecting to Flame Boss: \(String(describing: error))\n")
                }
            })
        }
    }
    
    public func configureViewForConnected()
    {
        connectedView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.connectingView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        { (Bool) in
            self.connectingView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.connectedView.isHidden = false
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7,
                           options: .curveEaseIn, animations: {
                self.connectedView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (Bool) in
                self.connectionStatusLabel.text = "You're Connected!"
                self.connectionDetailLabel.text = "Next you will connect your controller to your Wifi Network."
                self.connectionStatusLabel.textColor = UIColor.createColor(red: 93, green: 176, blue: 7, alpha: 1.0)
                self.continueButtonLabel.text = "NEXT"
            })
        }
    }
    
    // Called whenever the "Wifi Settings" or "Next" button is pressed
    @IBAction func continueToNextStep()
    {
        if continueButtonLabel.text == "WIFI SETTINGS"
        {
            openWifiSettings()
            continueButtonPressed = true
        }
        
        else if continueButtonLabel.text == "NEXT"
        {
            if self.nextPage != nil { nextPage() }
        }
    }
    
    private func openWifiSettings()
    {
        let settingsURL = URL(string: "App-Prefs:root=WIFI")
        UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
    }
}
