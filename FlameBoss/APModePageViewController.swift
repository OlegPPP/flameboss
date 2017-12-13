//
//  APModePageViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/11/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class APModePageViewController : UIPageViewController
{
    fileprivate var contentViewControllers = [UIViewController]()
    public var currentPageIndex = 0
    
    public var nextPage: (() -> ())!
    public var close: (() -> ())!
    
    private var flameBossCommunicator: SmokerDeviceCommunicator? = SmokerDeviceCommunicator()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initContentViewControllers()
        setContentViewControllers()
    }
    
    private func initContentViewControllers()
    {
        contentViewControllers = [UIViewController]()
        
        let storyboard = UIStoryboard(name: "APModeSetup", bundle: nil)
        
        let enterAPModeController = storyboard.instantiateViewController(withIdentifier: "EnterAPModeViewController")
            as! EnterAPModeViewController
        enterAPModeController.nextPage = scrollToNextPage

        let enterAPMode2Controller = storyboard.instantiateViewController(withIdentifier: "EnterAPMode2ViewController")
            as! EnterAPMode2ViewController
        enterAPMode2Controller.nextPage = scrollToNextPage
        
        let joinFBWifiController = storyboard.instantiateViewController(withIdentifier: "JoinFBWifiViewController")
            as! JoinFBWifiViewController
        joinFBWifiController.nextPage = scrollToNextPage
        joinFBWifiController.flameBossCommunicator = flameBossCommunicator
        
        let connectFBToWifiController = storyboard.instantiateViewController(withIdentifier:
            "ConnectFBToWifiViewController") as! ConnectFBToWifiViewController
        connectFBToWifiController.close = closeView
        connectFBToWifiController.flameBossCommunicator = flameBossCommunicator
        
        contentViewControllers.append(enterAPModeController)
        contentViewControllers.append(enterAPMode2Controller)
        contentViewControllers.append(joinFBWifiController)
        contentViewControllers.append(connectFBToWifiController)
    }
    
    private func setContentViewControllers()
    {
        setViewControllers([contentViewControllers.first!], direction: .forward, animated: true, completion: nil)
    }
    
    private func scrollToNextPage()
    {
        let nextIndex = currentPageIndex + 1
        if !isPageIndexValid(nextIndex) { return }
        
        currentPageIndex = nextIndex
        if nextPage != nil { self.nextPage() }
        
        let controllerToShow = contentViewControllers[currentPageIndex]
        setViewControllers([controllerToShow], direction: .forward, animated: true, completion: nil)
    }
    
    public func scrollToPreviousPage()
    {
        let prevIndex = currentPageIndex - 1
        if !isPageIndexValid(prevIndex) { return }
        
        currentPageIndex = prevIndex
        
        let controllerToShow = contentViewControllers[currentPageIndex]
        setViewControllers([controllerToShow], direction: .reverse, animated: true, completion: nil)
    }
    
    private func isPageIndexValid(_ pageIndex: Int) -> Bool
    {
        return pageIndex >= 0 && pageIndex < contentViewControllers.count
    }
    
    public func closeView()
    {
        if close != nil { close() }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        flameBossCommunicator?.disconnect()
        flameBossCommunicator = nil
    }
}
