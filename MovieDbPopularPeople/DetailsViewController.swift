//
//  DetailsViewController.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/4/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var detailsTable: UITableView!
    
    // MARK: - Properities
    
    var id = 0
    
    var personDetail: PersonDetails = PersonDetails(gender: 0, name: "", profilePath: "", birthday: "", placeOfBirth: "", deathday: "", homepage: "", alsoKnownAs: [], biography: "", images: [])
    
    var infoList = [[String:String]]()
    var images = [String]()
    var imagesCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Details"
        
        //
        // Make table cell height fit content.
        //
        
        self.detailsTable.estimatedRowHeight = 50
        self.detailsTable.rowHeight = UITableViewAutomaticDimension
        
        //
        // Get details.
        //
        
        self.loadDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowImage":
            guard let imageViewController = segue.destination as? ImageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? ProfileImageCollectionViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = self.imagesCollection.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedImage = self.images[indexPath.row]
            imageViewController.filePath = selectedImage
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // MARK: - Private methods
    
    /**
     * Show error message.
     */
    private func showError(error: String) {
        self.detailsTable.isHidden = true
        self.errorLabel.text = error
        self.errorLabel.isHidden = false
        self.loading.stopAnimating()
    }
    
    /**
     * Call popular people API and handle response based on status.
     */
    private func loadDetails() {
        Alamofire.request(ServerUtils.getPersonDetailsUrl(id: self.id), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        self.handleDetailsData(json: json)
                    } else {
                        self.handleJsonError(error: "Cannot get JSON from response.")
                    }
                    
                    break
                case .failure(let error):
                    self.handleRequestError(error: error)
                    break
                }
        }
    }
    
    /**
     * Handle request error and based on error code show error message.
     */
    private func handleRequestError(error: Error) {
        print(error)
        
        if let err = error as? URLError, err.code == .notConnectedToInternet {
            self.showError(error: "Cannot connect to server\nPlease check Internet connection")
        } else {
            self.showError(error: "Error getting data")
        }
    }
    
    /**
     * Handle errors while parsing JSON.
     */
    private func handleJsonError(error: String) {
        print(error)
        self.showError(error: "Error getting data")
    }
    
    /**
     * Handle the response of popular people API call.
     */
    private func handleDetailsData(json: Any) {
        if let response = json as? [String:Any] {
            //
            // Fill profile images.
            //
            
            self.images = [String]()
            let profiles = (response["images"] as? [String:Any])?["profiles"] as? [[String:Any]]
            
            if profiles != nil && (profiles?.count) ?? 0 > 0 {
                for profile in profiles! {
                    images.append(profile["file_path"] as? String ?? "")
                }
            }
            
            //
            // Fill person data.
            //
            
            self.personDetail = PersonDetails(gender: response["gender"] as? Int ?? 0, name: response["name"] as? String ?? "Details", profilePath: response["profile_path"] as? String ?? "", birthday: response["birthday"] as? String ?? "", placeOfBirth: response["place_of_birth"] as? String ?? "", deathday: response["deathday"] as? String ?? "", homepage: response["homepage"] as? String ?? "", alsoKnownAs: response["also_known_as"] as? [String] ?? [], biography: response["biography"] as? String ?? "", images: images)
            
            //
            // Fill info list.
            //
            
            infoList = [[String:String]]()
            
            if personDetail.gender == ConstantUtils.GENGER_FEMALE {
                infoList.append(["Gender": "Female"])
            }
            
            if personDetail.gender == ConstantUtils.GENGER_MALE {
                infoList.append(["Gender": "Male"])
            }
            
            if !personDetail.birthday.isEmpty {
                infoList.append(["Birthday": personDetail.birthday])
            }
            
            if !personDetail.placeOfBirth.isEmpty {
                infoList.append(["Place of Birth": personDetail.placeOfBirth])
            }
            
            if !personDetail.deathday.isEmpty {
                infoList.append(["Deathday": personDetail.deathday])
            }
            
            if !personDetail.homepage.isEmpty {
                infoList.append(["Official Site": personDetail.homepage])
            }
            
            if !personDetail.alsoKnownAs.isEmpty {
                var otherNames = ""
                
                for name in personDetail.alsoKnownAs {
                    otherNames += "\(name)\n"
                }
                
                infoList.append(["Also Known As": otherNames])
            }
            
            //
            // Show details table and stop loading.
            //
            
            self.title = personDetail.name
            self.detailsTable.reloadData()
            self.detailsTable.isHidden = false
            self.loading.stopAnimating()
        } else {
            print("Cannot map JSON.")
            self.showError(error: "Error getting data")
        }
    }

}

// MARK: - TableView data source

extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoList.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //
            // Get cell of BioTableViewCell type.
            //
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellBio", for: indexPath) as? BioTableViewCell  else {
                fatalError("The dequeued cell is not an instance of BioTableViewCell.")
            }
            
            //
            // Set bio.
            //
            
            cell.bio.text = self.personDetail.biography
            
            //
            // Load the person image and set it to the cell image view.
            //
            
            if let sizes = PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES) as? [String] {
                Alamofire.request(ServerUtils.getImageUrl(fileSize: sizes[1], filePath: personDetail.profilePath)).responseImage { response in
                    if let image = response.result.value {
                        cell.profileImage.image = image
                        cell.setNeedsLayout()
                        cell.layoutIfNeeded()
                    }
                }
            }
            
            return cell
        case 1:
            //
            // Get cell of ImagesTableViewCell type.
            //
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellImages", for: indexPath) as? ImagesTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ImagesTableViewCell.")
            }
            
            //
            // Set images list.
            //
            
            cell.profileImagesCollection.dataSource = self
            cell.profileImagesCollection.delegate = self
            cell.profileImagesCollection.reloadData()
            self.imagesCollection = cell.profileImagesCollection
            return cell
        default:
            //
            // Get cell of InfoTableViewCell type.
            //
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellInfo", for: indexPath) as? InfoTableViewCell  else {
                fatalError("The dequeued cell is not an instance of InfoTableViewCell.")
            }
            
            //
            // Set title and details text.
            //
            
            cell.titleLabel.text = Array(infoList[indexPath.row - 2].keys)[0]
            cell.detailsLabel.text = Array(infoList[indexPath.row - 2].values)[0]
            return cell
        }
    }
    
}

// MARK: - CollectionView data source and delegate

extension DetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        // Get cell of ProfileImageCollectionViewCell type.
        //
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellProfileImage", for: indexPath) as? ProfileImageCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of ProfileImageCollectionViewCell.")
        }
        
        //
        // Load the person image and set it to the cell image view.
        //
        
        if let sizes = PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES) as? [String] {
            Alamofire.request(ServerUtils.getImageUrl(fileSize: sizes[0], filePath: images[indexPath.row])).responseImage { response in
                if let image = response.result.value {
                    cell.profileImage.image = image
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
