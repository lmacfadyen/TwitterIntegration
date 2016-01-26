//
//  TwitterViewController.swift
//  TwitterIntegration
//
//  Created by Lawrence F MacFadyen on 2015-07-24.
//  Copyright (c) 2015 LawrenceM. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterViewController: UIViewController {

    let image = UIImage(named: "RandomImage.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func clickedSLCVC(sender: AnyObject) {
        tweetSLCVC()
    }

    @IBAction func clickedSLR(sender: AnyObject) {
        tweetSLRSeparateMedia()
    }
    
    func tweetSLCVC()
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterController.setInitialText("Posting a tweet from iOS App" + "\r\n" + "\r\n" + "#Cool")
            twitterController.addImage(image)
            self.presentViewController(twitterController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func tweetSLRSeparateMedia()
    {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success: Bool, error: NSError!) -> Void in
                if success {
                    let arrayOfAccounts =
                    account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        let twitterAccount = arrayOfAccounts.first as! ACAccount
                        // Upload media first and use returned media_id_string in separate Tweet
                        // Use media/upload.json to post GIF first
                        let uploadURL = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")
                        let url = NSBundle.mainBundle().URLForResource("Fish", withExtension: "gif")
                        let imageData = NSData(contentsOfURL: url!)
                        guard (imageData != nil) else {print("error: There is no imageData"); return}
                        
                        let uploadRequest = SLRequest(forServiceType:SLServiceTypeTwitter, requestMethod: .POST, URL: uploadURL, parameters: nil)
                        
                        uploadRequest.account = twitterAccount
                        uploadRequest.addMultipartData(imageData, withName: "media", type: nil, filename: nil)
                        
                        uploadRequest.performRequestWithHandler()
                            {   (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                                // Get the media_id_string from response
                                let mediaIDString = self.stringForKey("media_id_string", fromJSONData:responseData)
                                guard (mediaIDString != nil) else {print("error: no media id in response \(urlResponse.statusCode)"); return}
                                
                                let statusKey = "status" as NSString
                                let mediaIDKey = "media_ids" as NSString
                                // Use statuses/update.json for the tweet
                                let statusURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
                                let message = "Posting a tweet with Animated GIF from iOS App" + "\r\n" + "\r\n" + "#Cool"
                                // Separate request to post the tweet
                                let statusRequest = SLRequest(forServiceType:SLServiceTypeTwitter, requestMethod: .POST, URL: statusURL, parameters: [statusKey : message, mediaIDKey : mediaIDString!])
                                
                                statusRequest.account = twitterAccount
                                
                                statusRequest.performRequestWithHandler()
                                    {   (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                                        
                                        if let err = error {  
                                            print("error : \(err.localizedDescription)")  
                                        }  
                                        print("Twitter HTTP response \(urlResponse.statusCode)")  
                                }  
                        }
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
     
    }
    
    private func stringForKey(key: String, fromJSONData data: NSData?) -> String?
    {
        guard let inData = data else {return nil}
        do
        {
            let response = try NSJSONSerialization.JSONObjectWithData(inData, options: []) as? NSDictionary
            let result = response?.objectForKey(key) as? String
            return result
        }
        catch {return nil}  
    }
   
}
