//
//  ViewController.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var model: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl?.beginRefreshing()

        refresh()
    }

    func refresh() {
        let query = "https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=\(Private.apiKey)&gallery_id=72157664540660544&format=json&nojsoncallback=1"
        let encoded = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: encoded)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary

                guard
                    let photosDictionary = object?.valueForKey("photos") as? [String: AnyObject],
                    let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]
                    else { return }

                for photoDictionary in photosArray {
                    guard
                        let farmID = photoDictionary["farm"] as? Int,
                        let serverID = photoDictionary["server"] as? String,
                        let photoID = photoDictionary["id"] as? String,
                        let secret = photoDictionary["secret"] as? String
                        else { return }

                    let imageResourceString = "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secret)_z.jpg"

                    guard
                        let encoded = imageResourceString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
                        let url = NSURL(string: encoded),
                        let data = NSData(contentsOfURL: url),
                        let image = UIImage(data: data)
                        else { return }

                    self.model.append(image)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }

            } catch {
                print(error)
            }

        }.resume()
    }
}

// MARK: - Table view data source
extension ViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let image = model[indexPath.row]
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill

        let cell: UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell()
        cell.addSubview(imageView)

        imageView.topAnchor.constraintEqualToAnchor(imageView.superview!.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(imageView.superview!.bottomAnchor).active = true
        imageView.leadingAnchor.constraintEqualToAnchor(imageView.superview!.leadingAnchor).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(imageView.superview!.trailingAnchor).active = true

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.width
    }
}
