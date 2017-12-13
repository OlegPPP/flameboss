//
//  CookViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/17/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit
import SwiftChart
import RichEditorView

class CookViewController : FBViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var onlineStatusLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var pitTempFanView: UIView!
    @IBOutlet weak var meatTemp1View: UIView!
    @IBOutlet weak var meatTemp2View: UIView!
    @IBOutlet weak var meatTemp3View: UIView!
    @IBOutlet weak var titleNotesView: UIView!
    
    @IBOutlet weak var pitSetEditButton: UIButton!
    @IBOutlet weak var meatTemp1EditButton: UIButton!
    @IBOutlet weak var meatTemp2EditButton: UIButton!
    @IBOutlet weak var meatTemp3EditButton: UIButton!
    
    @IBOutlet weak var pitTempCookLabel: UILabel!
    @IBOutlet weak var setTempCookLabel: UILabel!
    @IBOutlet weak var fanCookLabel: UILabel!
    @IBOutlet weak var meatTemp1CookLabel: UILabel!
    @IBOutlet weak var meatTemp2CookLabel: UILabel!
    @IBOutlet weak var meatTemp3CookLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var editNotesButton: UIButton!
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var graph: Chart!
//    @IBOutlet weak var setTempGraphLabel: UILabel!
//    @IBOutlet weak var pitTempGraphLabel: UILabel!
//    @IBOutlet weak var fanGraphLabel: UILabel!
//    @IBOutlet weak var meatTemp1GraphLabel: UILabel!
//    @IBOutlet weak var meatTemp2GraphLabel: UILabel!
//    @IBOutlet weak var meatTemp3GraphLabel: UILabel!
    
    private var coverView: UIView!
    fileprivate var timeLabel: UILabel!
    fileprivate var viewModel: CookViewModel!
    public var cook: Cook?
    private var isUserEditingTitleOrNotes = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setTitleAndNotes()
        
        //viewModel.refreshDeviceForCook()
        //viewModel.refreshDataForCook()
        
        let titleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        titleLabel.addGestureRecognizer(titleTapRecognizer)
        
        let notesTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(notesTextViewTapped))
        notesTextView.addGestureRecognizer(notesTapRecognizer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.closeWebSocket()
    }
    
    func titleLabelTapped()
    {
        if viewModel.canEditTitleOrNotes() { showTitleNotesController(withFocus: .Title) }
    }
    
    func notesTextViewTapped()
    {
        if viewModel.canEditTitleOrNotes() { showTitleNotesController(withFocus: .Notes) }
    }
    
    private func configure()
    {
        statusBarStyle = .default
        initializeCoverView()
        initializeViewModel()
        createTimeLabel()
        addShadowToViews()
        dismissesKeyboardOnViewTap(true)
        configureAppearanceForCook()
    }
    
    private func updateAppearance()
    {
        DispatchQueue.main.async
        {
            if self.loadingView.alpha != 0
            {
                self.fadeLoadingViewOut()
                self.scrollView.flashScrollIndicators()
            }
            
            if !self.isUserEditingTitleOrNotes { self.configureAppearanceForCook() }
        }
    }
    
    private func addShadowToViews()
    {
        addShadowToView(pitTempFanView)
        addShadowToView(meatTemp1View)
        addShadowToView(meatTemp2View)
        addShadowToView(meatTemp3View)
        addShadowToView(graphView)
        addShadowToView(titleNotesView)
    }
    
    private func addShadowToView(_ view: UIView)
    {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 3
        
        view.layer.masksToBounds = false
    }
    
    private func initializeViewModel()
    {
        if let cook = cook
        {
            viewModel = CookViewModel(cook: cook, updateAppearanceCallback: updateAppearance)
        }
    }
    
    private func initializeCoverView()
    {
        coverView = UIView(frame: view.frame)
        coverView.backgroundColor = UIColor.black
        coverView.alpha = 0.0
        view.addSubview(coverView)
    }
    
    private func fadeLoadingViewOut()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.loadingView.alpha = 0.0
        }, completion: nil)
    }
    
    private func createTimeLabel()
    {
        let frame = CGRect(x: 0, y: 0, width: 90, height: 20)
        timeLabel = UILabel(frame: frame)
        timeLabel.font = UIFont.systemFont(ofSize: 20)
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .left
        graphView.addSubview(timeLabel)
    }
    
    private func configureAppearanceForCook()
    {
        if viewModel == nil { return }
        
        self.timeLabel.text = ""
        setTitleAndNotes()
        configureDateLabels()
        configureEditButtonsVisibility()
        configureCookValueLabels()
        configureGraphForCook()
        
        editNotesButton.isHidden = !viewModel.canEditTitleOrNotes()
        
        if viewModel.isControllerOnline()
        {
            onlineStatusLabel.text = "• ONLINE"
            onlineStatusLabel.textColor = UIColor.createColor(red: 152, green: 204, blue: 107, alpha: 1.0)
        }
        else
        {
            onlineStatusLabel.text = "• OFFLINE"
            onlineStatusLabel.textColor = UIColor.lightGray
        }
    }
    
    private func configureDateLabels()
    {
        guard let startDate = viewModel.getCookStartDate() else
        {
            startDateLabel.text = "---"
            return
        }
        startDateLabel.attributedText = attributtedString(dateString: startDate)
        
        guard let endDate = viewModel.getCookEndDate() else
        {
            endLabel.isHidden = true
            endDateLabel.isHidden = true
            return
        }
        
        endLabel.isHidden = false
        endDateLabel.isHidden = false
        endDateLabel.attributedText = attributtedString(dateString: endDate)
    }
    
    private func attributtedString(dateString: String) -> NSAttributedString
    {
        let atString = NSMutableAttributedString(string: dateString)
        
        let fontSize = startDateLabel.font.pointSize
        let boldAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
        let range = NSRange.init(location: 0, length: 6)
        atString.addAttributes(boldAttribute, range: range)
        
        return atString
    }
    
    private func setTitleAndNotes()
    {
        headerLabel.text = viewModel.headerText()
        
        let lightGray = UIColor.createColor(red: 199, green: 199, blue: 205, alpha: 1.0)
        
        if let title = viewModel.getCookTitle()
        {
            titleLabel.textColor = UIColor.black
            titleLabel.text = title
        }
        else
        {
            titleLabel.textColor = lightGray
            titleLabel.text = "Tap to Add Title"
            if !viewModel.canEditTitleOrNotes() { titleLabel.text = "Cook Title" }
        }
        
        if let notes = viewModel.getCookNotes()
        {
            if notes.isEmpty
            {
                notesTextView.textColor = lightGray
                notesTextView.text = "Tap to add notes"
                if !viewModel.canEditTitleOrNotes() { notesTextView.text = "Cook Notes" }
            }
            
            else
            {
                notesTextView.textColor = UIColor.black
                notesTextView.displayHtmlText(notes)
            }
        }
        else
        {
            notesTextView.textColor = lightGray
            notesTextView.text = "Tap to add notes"
            if !viewModel.canEditTitleOrNotes() { notesTextView.text = "Cook Notes" }
        }
    }
    
    private func configureEditButtonsVisibility()
    {
        let shouldShow:CGFloat = viewModel.canEditAlarmAndTemperatures() ? 1 : 0
        
        pitSetEditButton.alpha = shouldShow
        meatTemp1EditButton.alpha = shouldShow
        meatTemp2EditButton.alpha = viewModel.canEditMeat2Temp() ? 1 : 0
        meatTemp3EditButton.alpha = viewModel.canEditMeat3Temp() ? 1 : 0
    }
    
    private func configureCookValueLabels()
    {
        setTempCookLabel.text = viewModel.getLastSetTemp()
        pitTempCookLabel.text = viewModel.getLastPitTemp()
        fanCookLabel.text = viewModel.getLastBlowerOutput()
        
        let lastMeatTemps = viewModel.getLastMeatTemps()
        meatTemp1CookLabel.text = lastMeatTemps[0]
        meatTemp2CookLabel.text = lastMeatTemps[1]
        meatTemp3CookLabel.text = lastMeatTemps[2]
    }
    
    private func configureGraphForCook()
    {
        if viewModel.doesCookHaveGraphData() == false { return }
        
        graph.backgroundColor = .white
        graph.removeAllSeries()
        graph.delegate = self
        
        let setTempColor = UIColor.createColor(red: 69, green: 120, blue: 166, alpha: 1)
        let pitTempColor = UIColor.createColor(red: 239, green: 34, blue: 35, alpha: 1)
        let fanOutputColor = UIColor.createColor(red: 109, green: 186, blue: 2, alpha: 1)
        let meatTemp1Color = UIColor.createColor(red: 248, green: 173, blue: 30, alpha: 1)
        let meatTemp2Color = UIColor.createColor(red: 155, green: 89, blue: 182, alpha: 1)
        let meatTemp3Color = UIColor.createColor(red: 13, green: 191, blue: 242, alpha: 1)
        
        let setTempSeries = ChartSeries(viewModel.getSetTempData())
        setTempSeries.color = setTempColor
        
        let pitTempSeries = ChartSeries(viewModel.getPitTempData())
        pitTempSeries.color = pitTempColor
        
        let fanOutputSeries = ChartSeries(viewModel.getBlowerOutputData())
        fanOutputSeries.color = fanOutputColor
        
        let meatTemp1Series = ChartSeries(viewModel.getMeatTemp1Data())
        meatTemp1Series.color = meatTemp1Color
        
        let meat2Temps = viewModel.getMeatTemp2Data()
        let meatTemp2Series = ChartSeries(meat2Temps)
        meatTemp2Series.color = meatTemp2Color
        
        let meat3Temps = viewModel.getMeatTemp3Data()
        let meatTemp3Series = ChartSeries(viewModel.getMeatTemp3Data())
        meatTemp3Series.color = meatTemp3Color
        
        var series = [setTempSeries, pitTempSeries, fanOutputSeries, meatTemp1Series]
        if viewModel.isMeatTempsValid(meat2Temps) { series.append(meatTemp2Series) }
        if viewModel.isMeatTempsValid(meat3Temps) { series.append(meatTemp3Series) }
        
        graph.add(series)
        
        graph.xLabels = viewModel.graphXAxisLabels()
        graph.xLabelsFormatter = viewModel.graphXAxisLabelFormatter
        
        graph.setNeedsDisplay()
    }
    
    @IBAction func editTitleAndNotes()
    {
        showTitleNotesController(withFocus: .None)
    }
    
    @IBAction func shareCook()
    {
        showShareViewController()
    }
    
    func showTitleNotesController(withFocus: Focus)
    {
        let titleNotesController = storyboard?.instantiateViewController(withIdentifier: "CookTitleNotesViewController") as! CookTitleNotesViewController
        titleNotesController.cook = cook
        titleNotesController.cookTitleAndNotesUpdated = titleAndNotesEdited(updatedCook:)
        titleNotesController.focus = withFocus
        navigationController?.pushViewController(titleNotesController, animated: true)
    }
    
    private func titleAndNotesEdited(updatedCook: Cook)
    {
        viewModel.cook.title = updatedCook.title
        viewModel.cook.notes = updatedCook.notes
        
        DispatchQueue.main.async {
            self.setTitleAndNotes()
        }
    }
    
    func showShareViewController()
    {
        let activityController = UIActivityViewController(activityItems: viewModel.shareInfoForCook(),
                                                          applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityType.airDrop]
        
        if let popoverPresentationController = activityController.popoverPresentationController
        {
            popoverPresentationController.sourceView = view
            let screenWidth = view.frame.width
            let buttonWidth = CGFloat(60)
            let buttonHeight = CGFloat(50)
            popoverPresentationController.sourceRect = CGRect(x: screenWidth - buttonWidth, y: 15,
                                                              width: buttonWidth, height: buttonHeight)
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func editPitAndSetTemp()
    {
        if !viewModel.canEditAlarmAndTemperatures() { return }
        
        let setTempController = storyboard?.instantiateViewController(withIdentifier: "SetTempAndPitAlarmViewController") as! SetTempAndPitAlarmViewController
        setTempController.setDevice(viewModel.getDeviceForCook(), currentSetTemp: viewModel.getLastSetTempValue(),
                                    andTempScale: viewModel.tempScale())
        navigationController?.pushViewController(setTempController, animated: true)
    }
    
    @IBAction func editMeat1Temp()
    {
        if viewModel.canEditAlarmAndTemperatures() { showMeatAlarmViewController(meatIndex: 0) }
    }
    
    @IBAction func editMeat2Temp()
    {
        if viewModel.canEditMeat2Temp() { showMeatAlarmViewController(meatIndex: 1) }
    }
    
    @IBAction func editMeat3Temp()
    {
        if viewModel.canEditMeat3Temp() { showMeatAlarmViewController(meatIndex: 2) }
    }
    
    private func showMeatAlarmViewController(meatIndex: Int)
    {
        let setMeatAlarmController = storyboard?.instantiateViewController(withIdentifier: "SetMeatAlarmViewController") as! SetMeatAlarmViewController
        setMeatAlarmController.setDevice(viewModel.getDeviceForCook(), tempScale: viewModel.tempScale(),
                                         andMeatIndex: meatIndex)
        navigationController?.pushViewController(setMeatAlarmController, animated: true)
    }
}

extension CookViewController : ChartDelegate
{
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat)
    {
        shiftTimeLabel(xTouchPositonOnGraph: left + 5, xAxisValue: x)
        
//        configureValueLabels(xAxisValue: Int(x))
    }
    
    private func shouldShowTimeOnLeftSide(xPosition: CGFloat) -> Bool
    {
        if (xPosition + timeLabel.frame.width) > (graph.frame.origin.x + graph.frame.width) { return true }
        
        return false
    }
    
    private func shiftTimeLabel(xTouchPositonOnGraph: CGFloat, xAxisValue: Float)
    {
        viewModel.graphFrame = graph.frame
        viewModel.timeLabelFrame = timeLabel.frame
        
        let showOnLeftSide = viewModel.shouldShowTimeOnLeftSide(xTouchPositonOnGraph: xTouchPositonOnGraph)
        
        let timeLabelXPosition = viewModel.xPositionForTimeLabel(xAxisValue: CGFloat(xAxisValue),
                                                                 xTouchPositonOnGraph: xTouchPositonOnGraph)
        
        timeLabel.frame.origin.x = CGFloat(timeLabelXPosition)
        timeLabel.textAlignment = (showOnLeftSide) ? .right : .left
        timeLabel.text = viewModel.timeForXAxisValue(Int(xAxisValue))
    }
    
//    private func configureValueLabels(xAxisValue: Int)
//    {
//        let values = viewModel.getGraphDataValues_ForXAxisValue(xAxisValue)
//        setTempGraphLabel.text = values["set"]
//        pitTempGraphLabel.text = values["pit"]
//        fanGraphLabel.text = values["blower"]
//        meatTemp1GraphLabel.text = values["meat"]
//    }
    
    func didFinishTouchingChart(_ chart: Chart) {}
}
