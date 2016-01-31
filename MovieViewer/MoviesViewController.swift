//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Sukhrobjon Golibboev on 1/14/16.
//  Copyright © 2016 ccsf. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!

    
    
    
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var filteredMovieData: [NSDictionary]?
    var endpoint: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        movieSearchBar.delegate = self
        
        
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        
        // Do any additional setup after loading the view. networkRequest:
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let spining = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spining.labelText = "loading"
        spining.detailsLabelText = ""

        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovieData = self.movies
                            self.tableView.reloadData()
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            //                            let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
                            
                    }
                }
        });
        task.resume()
        
        networkRequest()
        
    }
    
    func networkRequest() {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )

        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
//        func networkRequest() {
//            
//            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
//            let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
//            let request = NSURLRequest(URL: url!)
//            let session = NSURLSession(
//                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//                delegate: nil,
//                delegateQueue: NSOperationQueue.mainQueue()
//            )
//            
//            
//        }
//        

        
        
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let movies = filteredMovieData {
            return movies.count
        } else{
            return 0
        }
        
        return movies!.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovieData! [indexPath.row]
        let title = movie["title"] as! String
        cell.titleLabel.text = title
        
        let overview = movie["overview"] as? String
        cell.overviewLabel.text = overview
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
        
        let posterURL = NSURL(string: baseUrl + posterPath)
        cell.posterView.setImageWithURL(posterURL!)
        }
        
        
        print("row \(indexPath.row)")
        return cell
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText.isEmpty {
            filteredMovieData = movies
        } else {
            filteredMovieData = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        self.movieSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovieData = movies
        self.tableView.reloadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.movie = movie
    }


}





//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
//
//        return 20
//     }
//
//   func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
//
//    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCell", forIndexPath: indexPath) as! ColorCell
//    let cellColor = filteredMovieData!(indexPath)
//    cell.backgroundColor = cellColor
//
//    if CGColorGetNumberOfComponents(cellColor.CGColor) == 4 {
//        let redComponent = CGColorGetComponents(cellColor.CGColor)[0] * 255
//        let greenComponent = CGColorGetComponents(cellColor.CGColor)[1] * 255
//        let blueComponent = CGColorGetComponents(cellColor.CGColor)[2] * 255
//        cell.colorLabel.text = String(format: "%.0f, %.0f, %.0f", redComponent, greenComponent, blueComponent)
//    }
//
//    return cell
//}


//return ColorCell(movies , cell: cell)

//    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
//    let movie = filteredMovies[indexPath.row]
//    return movieToCollectionViewCell(movie , cell: cell)





//}





// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
    




