//
//  ViewModel.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import GGNObservable

protocol TableViewDataSource {
    func numberOfSections() -> Int
    func numbersOfRows(inSection section: Int) -> Int
    func cellForRow(at indexPath: NSIndexPath, en tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: NSIndexPath) -> CGFloat
}

typealias PhlickrPhotos = [PhlickrPhoto]
protocol ViewModeling: TableViewDataSource {
    var output: Observable<PhlickrPhotos> { get }
    func refresh()
}


class ViewModel: ViewModeling {
    let output = Observable<PhlickrPhotos>()

    private let fetcher: Fetching
    private var photos: PhlickrPhotos = []

    init(fetcher: Fetching) {
        self.fetcher = fetcher

        self.fetcher.output.onNext { dictionary in
            guard
                let photosDictionary = dictionary.valueForKey("photos") as? [String: AnyObject],
                let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]
                else { return }

            let photos = photosArray.flatMap { PhlickrPhoto(dictionary: $0) }
            self.photos = photos
            self.output.emit(photos)
        }
    }

    func refresh() {
        let query = "https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=b139e4f1a3a51778332012ca260bf060&gallery_id=72157664540660544&format=json&nojsoncallback=1"
        let encoded = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: encoded)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        fetcher.fetch(with: request)
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numbersOfRows(inSection section: Int) -> Int {
        return photos.count
    }

    func cellForRow(at indexPath: NSIndexPath, en tableView: UITableView) -> UITableViewCell {
        let image = photos[indexPath.row].image
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

    func heightForRow(at indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
}
