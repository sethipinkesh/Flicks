//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Sethi, Pinkesh on 4/1/17.
//  Copyright © 2017 Intuit. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var detailScrollview: UIScrollView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieInfoView: UIView!
    
    var movie : Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieTitleLabel.text = movie.movieTitle
        movieOverviewLabel.text = movie.movieOverView
        movieOverviewLabel.sizeToFit()
        if(movie.moviePosterUrl != nil){
            let fileUrl = Foundation.URL(string: movie.moviePosterUrl!)
            moviePosterImageView.setImageWith(fileUrl!)
        }else{
            moviePosterImageView.image =  nil
        }
        // Do any additional setup after loading the view.
        detailScrollview.contentSize = CGSize (width: detailScrollview.frame.size.width, height: movieInfoView.frame.origin.y + movieInfoView.frame.size.height + 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
