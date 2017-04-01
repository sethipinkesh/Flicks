//
//  ViewController.swift
//  Flicks
//
//  Created by Sethi, Pinkesh on 3/29/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MovieViewController: UIViewController {

    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var errorMessageView: UIView!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    // Initialize a UIRefreshControl
    var refreshControl = UIRefreshControl()
    var moviesList: [Movie] = []
    let error: Error? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        // Initialize a UIRefreshControl
    
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        
        self.fetchAndLoadMovieData()
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    func fetchAndLoadMovieData(){
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Movie.fecthMovieData(successCallback: {(movies) -> Void in
            self.errorMessageView.isHidden = true
            self.moviesList = movies
            self.movieTableView.reloadData()
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if self.refreshControl.isRefreshing{
                self.refreshControl.endRefreshing()
            }
        } , error:{(error) -> Void in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            self.errorMessageView.isHidden = false
            self.errorMessageLabel.text = "Netwrok error"
            if self.refreshControl.isRefreshing{
                self.refreshControl.endRefreshing()
            }
        })
        /*Movie.fetchMovies(successCallBack: self.movies, errorCallBack: error) */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MovieViewController: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableCell") as! MovieTableCell
        let movie = moviesList[indexPath.row]
        cell.movieTitleLabel.text = movie.movieTitle
        cell.movieDescriptionLabel.text = movie.movieOverView
        let fileUrl = Foundation.URL(string: movie.moviePosterUrl!)
        cell.moviePosterImageView.setImageWith(fileUrl!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesList.count;
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPath(for: cell)
        let movie = moviesList[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! MovieDetailViewController;
        detailViewController.movie = movie
     }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchAndLoadMovieData()
    }
}

