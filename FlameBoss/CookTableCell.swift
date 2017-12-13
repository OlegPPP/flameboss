//
//  CookTableCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/14/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class CookTableCell : UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var timeFrameLabel: UILabel!
    private var dateFormatter = DateFormatter()
    private var cook: Cook!
    
    public func configureWithCook(_ cook: Cook)
    {
        self.cook = cook
        titleLabel.text = infoForCook()
        configureDateLabels()
    }
    
    private func configureDateLabels()
    {
        monthLabel.text = monthForCook()
        weekdayLabel.text = weekdayForCook()
        timeFrameLabel.text = timeFrameForCook()
    }
    
    private func monthForCook() -> String
    {
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter.string(from: cook.startDate()).uppercased()
    }
    
    private func weekdayForCook() -> String
    {
        dateFormatter.dateFormat = "EEE"
        let weekday = dateFormatter.string(from: cook.startDate()).uppercased()
        
        return weekday
    }
    
    private func timeFrameForCook() -> String
    {
        dateFormatter.dateFormat = "h:mma"
        var timeFrame = dateFormatter.string(from: cook.startDate())
        
        if let endDate = cook.endDate()
        {
            timeFrame += " - " + dateFormatter.string(from: endDate)
        }
        
        if wasCookMoreThanOneDay() { timeFrame += " (+1 day)" }
        
        return timeFrame
    }
    
    private func wasCookMoreThanOneDay() -> Bool
    {
        guard let endDate = cook.endDate() else { return false }
        
        let calendar = Calendar.current
        
        let startDay = calendar.startOfDay(for: cook.startDate())
        let endDay = calendar.startOfDay(for: endDate)
        
        let dateComponents = calendar.dateComponents([.day], from: startDay, to: endDay)
        
        return dateComponents.day! >= 1
    }
    
    private func infoForCook() -> String
    {
        if let cookTitle = cook.title { return cookTitle }
        
        var controllerName : String
        if((cook.deviceName ?? "").isEmpty){
            controllerName = "Controller \(cook.deviceID)"
        }
        else{
            controllerName = cook.deviceName!
        }

        
        return String(format: "Cook %d on %@", cook.id, controllerName)
    }
}
