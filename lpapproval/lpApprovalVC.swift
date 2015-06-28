//
//  lpApprovalVC.swift
//  lpapproval
//
//  Created by Sayantan Chakraborty on 26/06/15.
//  Copyright (c) 2015 Sayantan Chakraborty. All rights reserved.
//

import UIKit

let reuseIdentifier = "LpApprovalCell"

class lpApprovalVC: UICollectionViewController {

    var lpApprovalData = [Int : NSMutableDictionary]()
    var refreshControl : UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.title = "LP Approval"
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refreshControl)
        fetchData()

        // Do any additional setup after loading the view.
    }
    
    func fetchData()
    {
        let url = NSURL(string: "http://lppapproval.eu-gb.mybluemix.net/api/db/")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            if let data = NSData(contentsOfURL: url!){
                var error: NSError? = nil
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error)
                if let dict = json as? NSDictionary {
                    print(dict)
                    var totalRecords = dict["total_rows"] as! Int
                    if let rows: AnyObject = dict["rows"] {
                        var i : Int = 0
                        while(i < totalRecords)
                        {
                            self.lpApprovalData[i+1] = rows[i]["doc"] as? NSMutableDictionary
                            i++                            
                        }
                        print(self.lpApprovalData)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.collectionView?.reloadData()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.refreshControl.endRefreshing()
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender : AnyObject)
    {
        refreshControl.beginRefreshing()
        fetchData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return lpApprovalData.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LpApprovalCell", forIndexPath: indexPath) as! IpApprovalCell
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        // Configure the cell
        if lpApprovalData.count > 0 {
            if let details = lpApprovalData[indexPath.row + 1] {
                cell.lblCategory.text = details["category"] as? String
                cell.lblMoney.text = details["money"] as? String
                cell.lblStatus.text = details["status"] as? String
                cell.lblTons.text = details["tons"] as? String
                cell.lblYear.text = details["year"] as? String
                cell.approve.layer.setValue(indexPath.row, forKey: "index")
                cell.approve.addTarget(self, action: "approve:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.pending.layer.setValue(indexPath.row, forKey: "index")
                cell.pending.addTarget(self, action: "pending:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.approve.enabled = true
                cell.pending.enabled = true
                if cell.lblStatus.text == "Approved" {
                    cell.approve.enabled = false
                } else if cell.lblStatus.text == "Pending for Approval" {
                    cell.pending.enabled = false
                } else if cell.lblStatus.text == "Rejected" {
                    cell.pending.enabled = false
                    cell.approve.enabled = false
                }

            }
        }
        
        
        
        return cell
    }
    
    func approve(sender: UIButton)
    {
        var i = sender.layer.valueForKey("index") as! Int
        if let jsonPut = formJSONStringForPut(i,status: "Approved") {
            putHTTPDataWithJSONString(jsonPut)
            print(jsonPut)
        }
    }
    func pending(sender: UIButton)
    {
        var i = sender.layer.valueForKey("index") as! Int
        if let jsonPut = formJSONStringForPut(i,status: "Pending for Approval") {
            putHTTPDataWithJSONString(jsonPut)
            print(jsonPut)
        }
    
    }
    
    private func formJSONStringForPut(index : Int, status : NSString) -> NSString?
    {
        var jsonString : NSString?
        if let details = lpApprovalData[index + 1] {
            var id: AnyObject? = details["_id"]
            var rev: AnyObject? = details["_rev"]
            var year: AnyObject? = details["year"]
            var category: AnyObject? = details["category"]
            var tons: AnyObject? = details["tons"]
            var money: AnyObject? = details["money"]
            jsonString = "{\"id\":\"\(id!)\",\"rev\":\"\(rev!)\",\"year\":\"\(year!)\",\"category\":\"\(category!)\",\"tons\":\"\(tons!)\",\"money\":\"\(money!)\",\"status\":\"\(status)\"}"
            //var i = 0
        }
        return jsonString
    }
    
    private func putHTTPDataWithJSONString(jsonString : NSString)
    {
        //var request1 = NSMutableURLRequest(URL: NSURL(string: "http://lppapproval.eu-gb.mybluemix.net/api/db/")!,)
        var request = NSMutableURLRequest(URL: NSURL(string: "http://lppapproval.eu-gb.mybluemix.net/api/db/")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        var response : NSURLResponse?
        var error : NSError?
        
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        //NSURLConnection.sen
        
        if let httpresponse = response as? NSHTTPURLResponse {
            print("HTTP response:\(httpresponse.statusCode)")
            if httpresponse.statusCode == 200 {
                var alert = UIAlertController(title: "Alert", message: "Put Successfull, Response Code : \(httpresponse.statusCode)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                var alert = UIAlertController(title: "Alert", message: "Put Unsuccessfull, Response Code : \(httpresponse.statusCode)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }else{
            print("No HTTP response")
            var alert = UIAlertController(title: "Alert", message: "No Response", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
