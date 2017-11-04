//
//  ImageViewController.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/4/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properities
    
    var filePath = ""
    private var imageLoaded: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Load the person image.
        //
        
        if let sizes = PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES) as? [String] {
            Alamofire.request(ServerUtils.getImageUrl(fileSize: sizes[sizes.count - 1], filePath: self.filePath)).responseImage { response in
                if let image = response.result.value {
                    self.imageView.image = image
                    self.imageLoaded = image
                    self.loading.stopAnimating()
                    
                    //
                    // Add save button to navigation bar.
                    //
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveTapped))
                } else {
                    self.errorLabel.text = "Error loading image"
                    self.imageView.isHidden = true
                    self.errorLabel.isHidden = false
                    self.loading.stopAnimating()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    func saveTapped(sender: UIBarButtonItem) {
        var imageName = self.filePath
        imageName.remove(at: imageName.startIndex)
        let success = self.saveImage(image: self.imageLoaded, imageName: imageName)
        var message = ""
        
        if success {
            message = "Image saved to documents."
        } else {
            message = "Image not saved."
        }
        
        //
        // Show alert to represent save state.
        //
        
        let alert = UIAlertController(title: "Save", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     * Save image to documents directory.
     */
    private func saveImage(image: UIImage, imageName: String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(imageName)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

}
