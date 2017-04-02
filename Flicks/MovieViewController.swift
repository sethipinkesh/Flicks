//
//  MovieViewController.swift
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
    
    var refreshControlTable = UIRefreshControl()
    var refreshControlCollection = UIRefreshControl()
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
    
        refreshControlTable.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        refreshControlCollection.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // add refresh control to table view
        movieTableView.insertSubview(refreshControlTable, at: 0)
        movieCollectionView.insertSubview(refreshControlCollection, at: 0)
        
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
            
            if self.refreshControlTable.isRefreshing{
                self.refreshControlTable.endRefreshing()
            }
            if self.refreshControlCollection.isRefreshing{
                self.refreshControlCollection.endRefreshing()
            }
            
        } , error:{(error) -> Void in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            self.errorMessageView.isHidden = false
            self.errorMessageLabel.text = "Netwrok error"
            if self.refreshControlTable.isRefreshing{
                self.refreshControlTable.endRefreshing()
            }
            if self.refreshControlCollection.isRefreshing{
                self.refreshControlCollection.endRefreshing()
            }
        })
        /*Movie.fetchMovies(successCallBack: self.movies, errorCallBack: error) */
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
        if(row != -1){
            let movie = filteredMoviesList[row]
            let detailViewController = segue.destination as! MovieDetailViewController;
            detailViewController.movie = movie
        }
    }
    
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
        if(movie.moviePosterUrl != nil){
            fadeInImageFirst(imageView: cell.moviePosterImageView, movie: movie)
        }else{
            cell.moviePosterImageView.image =  nil
        }
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: (201/255.0), green: (239/255.0), blue: (247/255.0), alpha: 0.5)

        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMoviesList.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MovieViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        let movie = filteredMoviesList[indexPath.row]
        cell.movieTitleLabel.text =  movie.movieTitle
        //cell.movieTitleLabel.sizeToFit()
        if(movie.moviePosterUrl != nil){
            fadeInImageFirst(imageView: cell.moviePosterImage, movie: movie)
        }else{
            cell.moviePosterImage.image =  nil
        }
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

extension MovieViewController{
    
    func fadeInImageFirst(imageView: UIImageView, movie: Movie){
        let imageRequest = URLRequest(url: Foundation.URL(string: movie.moviePosterUrl!)!)
        imageView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        imageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    imageView.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                
        })
    }
    
}


