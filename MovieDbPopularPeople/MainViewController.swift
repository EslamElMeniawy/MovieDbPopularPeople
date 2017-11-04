//
//  ViewController.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/3/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var personsTable: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var searchText: UITextField!
    
    // MARK: - Properities
    
    var persons = [Person]()
    var pagesCount = 0
    var page = 1
    var isLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Check if first run of app then get configuration first else get people list.
        //
        
        if (PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_FIRST_RUN) as? Bool) ?? true {
            self.getConfiguration()
        } else {
            self.loadPeople()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            guard let detailViewController = segue.destination as? DetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? PeopleTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = self.personsTable.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPerson = self.persons[indexPath.row]
            detailViewController.id = selectedPerson.id
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func searchTextChanged(_ sender: UITextField) {
        //
        // Check if text is empty then load popular people else search with text.
        //
        
        self.isLoading = true
        self.persons = [Person]()
        self.personsTable.reloadData()
        self.page = 1
        self.loading.startAnimating()
        
        if (self.searchText.text ?? "" as String).characters.count > 0 {
            self.searchPeople(searchString: self.searchText.text!)
        } else {
            self.loadPeople()
        }
    }
    
    // MARK: - Private methods
    
    /**
     * Show error message in case of loading first page.
     */
    private func showError(error: String, noSearchResult: Bool) {
        if page == 1 {
            self.personsTable.isHidden = true
            self.searchText.isHidden = !noSearchResult
            self.errorLabel.text = error
            self.errorLabel.isHidden = false
        }
        
        self.loading.stopAnimating()
        self.isLoading = false
    }
    
    /**
     * Add results to table view and show it if hidden.
     */
    private func showData(results: [[String:Any]]) {
        if results.count > 0 {
            for result in results {
                self.persons.append(Person(id: result["id"] as? Int ?? 0, name: result["name"] as? String ?? "", profilePath: result["profile_path"] as? String ?? ""))
            }
            
            self.personsTable.reloadData()
            self.searchText.isHidden = false
            self.personsTable.isHidden = false
            self.loading.stopAnimating()
            self.page += 1
            self.isLoading = false
        } else {
            self.showError(error: "No data available to view.", noSearchResult: true)
        }
    }
    
    /**
     * Call configurations API and handle response based on status.
     */
    private func getConfiguration() {
        Alamofire.request(ServerUtils.getConfigurationUrl(), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        self.handleConfigurationData(json: json)
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
     * Call popular people API and handle response based on status.
     */
    func loadPeople() {
        Alamofire.request(ServerUtils.getPopularPeopleUrl(page: self.page), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        self.handlePeopleData(json: json)
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
     * Call search people API and handle response based on status.
     */
    func searchPeople(searchString: String) {
        Alamofire.request(ServerUtils.getSearchPeopleUrl(query: searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, page: self.page), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        self.handlePeopleData(json: json)
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
            self.showError(error: "Cannot connect to server\nPlease check Internet connection", noSearchResult: false)
        } else {
            self.showError(error: "Error getting data", noSearchResult: false)
        }
    }
    
    /**
     * Handle errors while parsing JSON.
     */
    private func handleJsonError(error: String) {
        print(error)
        self.showError(error: "Error getting data", noSearchResult: false)
    }
    
    /**
     * Save configurations and load popular people or show error if configuration not available.
     */
    private func handleConfigurationData(json: Any) {
        if let response = json as? [String:Any] {
            if let images = response["images"] as? [String:Any] {
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_BASE_URL, value: images["secure_base_url"] as? String ?? "")
                
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES, value: images["profile_sizes"] as? [String] ?? [])
                
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_FIRST_RUN, value: false)
                loadPeople()
            } else {
                print("Cannot get image configuration.")
                self.showError(error: "Error getting data", noSearchResult: false)
            }
            
        } else {
            print("Cannot map JSON.")
            self.showError(error: "Error getting data", noSearchResult: false)
        }
    }
    
    /**
     * Handle the response of popular people API call.
     */
    private func handlePeopleData(json: Any) {
        if let response = json as? [String:Any] {
            self.pagesCount = response["total_pages"] as? Int ?? 0
            self.showData(results: response["results"] as? [[String:Any]] ?? [[:]])
        } else {
            print("Cannot map JSON.")
            self.showError(error: "Error getting data", noSearchResult: false)
        }
    }

}

// MARK: - TableView data source and delegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        // Get cell of PeopleTableViewCell type.
        //
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellPopular", for: indexPath) as? PeopleTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PeopleTableViewCell.")
        }
        
        //
        // Set person name as the cell label text.
        //
        
        cell.name.text = self.persons[indexPath.row].name
        
        //
        // Load the person image and set it to the cell image view.
        //
        
        if let sizes = PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES) as? [String] {
            Alamofire.request(ServerUtils.getImageUrl(fileSize: sizes[0], filePath: persons[indexPath.row].profilePath)).responseImage { response in
                if let image = response.result.value {
                    cell.profileImage.image = image
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.personsTable {
            //
            // Check if table reached the end.
            //
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                //
                // Check if not loading and there is still pages to load then load next page.
                //
                
                if !self.isLoading && page <= pagesCount {
                    self.loading.startAnimating()
                    self.isLoading = true
                    self.loadPeople()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.personsTable.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension MainViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //
        // Hide keyboard on return.
        //
        
        self.searchText.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        // Hide keyboard on tap outside.
        //
        
        self.view.endEditing(true)
    }
    
}

