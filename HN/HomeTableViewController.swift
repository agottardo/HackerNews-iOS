//
//  HomeTableViewController.swift
//  HackerNews
//
//  Created by Andrea Gottardo on 2017-12-23.
//  Copyright © 2017 Andrea Gottardo. All rights reserved.
//

import UIKit
import FeedKit
import SafariServices
import AVFoundation

class HomeTableViewController: UITableViewController {
    
    var audioPlayer : AVAudioPlayer!
    
    var stories = [RSSFeedItem]()
    let feedURL = URL(string: "https://news.ycombinator.com/rss")!
    var parser : FeedParser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        parser = FeedParser(URL: feedURL)
        
        // MARK: UI + Refresh Control
        self.extendedLayoutIncludesOpaqueBars = true
        refreshControl?.tintColor = UIColor.darkGray
        refreshControl?.backgroundColor = UIColor.orange
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.beginRefreshing()
        refreshControl?.attributedTitle = NSAttributedString(string: "Fetching the latest stories from HN...")
        refreshControl?.addTarget(self, action: #selector(HomeTableViewController.updateContent), for: UIControl.Event.valueChanged)
        
        updateContent()
    }
    
    @objc func updateContent() -> Void {
        if ((parser) != nil) {
            parser!.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                // Do your thing, then back to the Main thread
                DispatchQueue.main.async {
                    // ..and update the UI
                    self.refreshControl?.endRefreshing()
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
                    if ((result.rssFeed) != nil) {
                        self.stories = (result.rssFeed?.items)!
                        self.tableView.reloadData()
                    } else {
                        // an error occurred
                        self.presentNetworkErrorAlert()
                    }
                }
            }
        } else {
            presentNetworkErrorAlert()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath)
        cell.textLabel?.text = stories[indexPath.row].title
        /*let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale.autoupdatingCurrent
            formatter.dateStyle = DateFormatter.Style.medium
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()*/
        cell.detailTextLabel?.text = (URL(string: stories[indexPath.row].link!)?.host)!// + " - " + dateFormatter.string(from: stories[indexPath.row].pubDate ?? Date()).lowercased()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safariVC = SFSafariViewController(url: URL(string: stories[indexPath.row].link!)!, entersReaderIfAvailable: true)
        // A bit of colour (on newer devices that support it).
        if #available(iOS 10.0, *) {
            safariVC.preferredBarTintColor = UIColor.orange
            safariVC.preferredControlTintColor = UIColor.darkGray
        }
        present(safariVC, animated: true, completion: nil)
    }
    
    func presentNetworkErrorAlert() -> Void {
        refreshControl?.endRefreshing()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        let alert = UIAlertController(title: "An error occurred", message: "I couldn't retrieve the latest stories from Hacker News. Maybe your network connection is not working?", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "OK 😕", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}
