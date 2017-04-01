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
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    // Initialize a UIRefreshControl
    var refreshControl = UIRefreshControl()
    var moviesList = [Movie] ()
    var filteredMoviesList = [Movie] ()
    var endPoint: String!
    let error: Error? = nil
    var searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:180, height:20))
    
    @IBAction func onSegmentClick(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0){
            movieTableView.isHidden = false
            movieCollectionView.isHidden = true
        }else{
            movieTableView.isHidden = true
            movieCollectionView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        navigationItem.title = "Movies"
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.resignFirstResponder()
        searchBar.keyboardType = UIKeyboardType.alphabet
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        movieCollectionView.dataSource = self
        movieCollectionView.delegate = self
        
        // Initialize a UIRefreshControl
    
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        movieCollectionView.insertSubview(refreshControl, at: 0)
        
        self.fetchAndLoadMovieData()
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    func fetchAndLoadMovieData(){
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Movie.fecthMovieData(endPoint:endPoint,successCallback: {(movies) -> Void in
            self.errorMessageView.isHidden = true
            self.moviesList = movies
            self.filteredMoviesList = self.moviesList
            self.movieTableView.reloadData()
            self.movieCollectionView.reloadData()
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var row = -1
        if segue.identifier == "tableViewSegue"{
            let cell = sender as! UITableViewCell
            let indexPath = movieTableView.indexPath(for: cell)
            row = (indexPath?.row)!

        }
        if segue.identifier == "collectionViewSegue"{
            let cell = sender as! UICollectionViewCell
            let indexPath = movieCollectionView.indexPath(for: cell)
            row = (indexPath?.row)!
        }
        let movie = filteredMoviesList[row]
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

extension MovieViewController: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableCell", for:indexPath) as! MovieTableCell
        let movie = filteredMoviesList[indexPath.row]
        cell.movieTitleLabel.text = movie.movieTitle
        cell.movieDescriptionLabel.text = movie.movieOverView
        let fileUrl = Foundation.URL(string: movie.moviePosterUrl!)
        cell.moviePosterImageView.setImageWith(fileUrl!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMoviesList.count
    }
    
}

extension MovieViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        let movie = filteredMoviesList[indexPath.row]
        cell.movieTitleLabel.text =  movie.movieTitle
        cell.movieTitleLabel.sizeToFit()
        let fileUrl = Foundation.URL(string: movie.moviePosterUrl!)
        cell.moviePosterImage.setImageWith(fileUrl!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMoviesList.count
    }
}

extension MovieViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMoviesList = []
        for movie in moviesList{
            if(movie.movieTitle?.contains(searchText))!{
                filteredMoviesList.append(movie)
            }
        }
        if(searchText == ""){
            perform(#selector(hideKeyboardWithSearchBar(searchBar:)), with:searchBar, afterDelay:0)
            filteredMoviesList = moviesList
        }
        movieTableView.reloadData()
        movieCollectionView.reloadData()
    }
    
    func hideKeyboardWithSearchBar(searchBar:UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
