//
//  APModeSetupViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/18/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class APModeSetupViewController : UIViewController
{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    
    private var apModePageController: APModePageViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateBackButtonVisibility()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let controller = segue.destination as? APModePageViewController
        {
            apModePageController = controller
            apModePageController.nextPage = goToNextPage
            apModePageController.close = close
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    @IBAction func back()
    {
        if apModePageController.currentPageIndex == 2 { progressView.animateFrom2To1() }
        else if apModePageController.currentPageIndex == 3 { progressView.animateFrom3To2() }
        apModePageController.scrollToPreviousPage()
        updateBackButtonVisibility()
    }
    
    private func goToPreviousPage()
    {
        
    }
    
    private func goToNextPage()
    {
        if apModePageController.currentPageIndex == 2 { progressView.animateFrom1To2() }
        else if apModePageController.currentPageIndex == 3 { progressView.animateFrom2To3() }
        else if apModePageController.currentPageIndex == 4 { self.dismiss(animated: true, completion: nil) }
        updateBackButtonVisibility()
    }
    
    private func updateBackButtonVisibility()
    {
        guard apModePageController != nil else { return }
        if apModePageController.currentPageIndex > 0 { backButton.isHidden = false }
        else { backButton.isHidden = true }
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
}
