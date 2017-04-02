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
            loadLowResFirst(movie:movie)
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
    

    func loadLowResFirst(movie:Movie){
    
        let smallImageRequest = URLRequest(url: Foundation.URL(string: movie.moviePosterLowResolutionUrl!)!)
        let largeImageRequest = URLRequest(url: Foundation.URL(string: movie.moviePosterUrl!)!)
        
        self.moviePosterImageView.setImageWith(
            smallImageRequest as URLRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.moviePosterImageView.alpha = 0.0
                self.moviePosterImageView.image = smallImage;
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.moviePosterImageView.alpha = 1.0
                    
                }, completion: { (sucess) -> Void in
                    
                    // The AFNetworking ImageView Category only allows one request to be sent at a time
                    // per ImageView. This code must be in the completion block.
                    self.moviePosterImageView.setImageWith(
                        largeImageRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            self.moviePosterImageView.image = largeImage;
                            
                    },
                        failure: { (request, response, error) -> Void in
                            self.moviePosterImageView =  nil
                    })
                })
        },
            failure: { (request, response, error) -> Void in
                self.moviePosterImageView = nil
        })
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
