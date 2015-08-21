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
        tweetSLR()
    }
    
    func tweetSLCVC()
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterController.setInitialText("Posting a tweet from iOS App" + "\r\n" + "\r\n" + "#Cool")
            twitterController.addImage(image)
            self.presentViewController(twitterController, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func tweetSLR()
    {
        
        var url = NSBundle.mainBundle().URLForResource("Fish", withExtension: "gif")
        var imageData = NSData(contentsOfURL: url!)
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
                        var message = Dictionary<String, AnyObject>()
                        message["status"] = "Posting a tweet with Animated GIF from iOS App" + "\r\n" + "\r\n" + "#Cool"
                        
                        let requestURL = NSURL(string:
                            "https://api.twitter.com/1.1/statuses/update.json")
                        let postRequest = SLRequest(forServiceType:
                            SLServiceTypeTwitter,
                            requestMethod: SLRequestMethod.POST,
                            URL: requestURL,
                            parameters: message)
                        
                        postRequest.account = twitterAccount
                        postRequest.addMultipartData(imageData, withName: "media", type: nil, filename: nil)
                        
                        postRequest.performRequestWithHandler({
                            (responseData: NSData!,
                            urlResponse: NSHTTPURLResponse!,
                            error: NSError!) -> Void in
                            if let err = error {
                                println("Error : \(err.localizedDescription)")
                            }
                            println("Twitter HTTP response \(urlResponse.statusCode)")
                            
                        })
                    }
                }
                else
                {
                    var alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }

   
}
