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

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var personsTable: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Properities
    
    var persons = [Person]()
    var pagesCount = 0
    var page = 1
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLoading = true
        self.persons = [Person]()
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
    
    // MARK: - Private methods
    
    private func showError(error: String) {
        self.personsTable.isHidden = true
        self.errorLabel.text = error
        self.errorLabel.isHidden = false
        self.loading.stopAnimating()
    }
    
    private func showData(results: [[String:Any]]) {
        print(results.count)
        
        for result in results {
            self.persons.append(Person(id: result["id"] as? Int ?? 0, name: result["name"] as? String ?? "", profilePath: result["profile_path"] as? String ?? ""))
        }
        
        self.personsTable.reloadData()
        self.personsTable.isHidden = false
        self.loading.stopAnimating()
    }
    
    private func getConfiguration() {
        Alamofire.request(ServerUtils.getConfigurationUrl(), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Result: \(response.result)")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let json = response.result.value {
                        print("JSON: \(json)")
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
    
    private func loadPeople() {
        Alamofire.request(ServerUtils.getPopularPeopleUrl(page: self.page), method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Result: \(response.result)")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let json = response.result.value {
                        print("JSON: \(json)")
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
    
    private func handleRequestError(error: Error) {
        print(error)
        
        if let err = error as? URLError, err.code == .notConnectedToInternet {
            self.showError(error: "Cannot connect to server\nPlease check Internet connection")
        } else {
            self.showError(error: "Error getting data")
        }
    }
    
    private func handleJsonError(error: String) {
        print(error)
        self.showError(error: "Error getting data")
    }
    
    private func handleConfigurationData(json: Any) {
        if let response = json as? [String:Any] {
            if let images = response["images"] as? [String:Any] {
                print("Get configuration success.")
                print(images["secure_base_url"] as? String as Any)
                print(images["profile_sizes"] as? [String] as Any)
                
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_BASE_URL, value: images["secure_base_url"] as? String ?? "")
                
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES, value: images["profile_sizes"] as? [String] ?? [])
                
                let _ = PreferencesUtils.writeToPreferences(key: PreferencesUtils.PREF_KEY_FIRST_RUN, value: false)
                loadPeople()
            } else {
                print("Cannot get image configuration.")
                self.showError(error: "Error getting data")
            }
            
        } else {
            print("Cannot map JSON.")
            self.showError(error: "Error getting data")
        }
    }
    
    private func handlePeopleData(json: Any) {
        if let response = json as? [String:Any] {
            print("Get people success.")
            print(response["total_pages"] as? Int as Any)
            self.pagesCount = response["total_pages"] as? Int ?? 0
            self.showData(results: response["results"] as? [[String:Any]] ?? [[:]])
        } else {
            print("Cannot map JSON.")
            self.showError(error: "Error getting data")
        }
    }

}

// MARK: - TableView data source and delegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CellPopular")
        
        cell.textLabel?.text = self.persons[indexPath.row].name
        
        if let sizes = PreferencesUtils.readFromPreferences(key: PreferencesUtils.PREF_KEY_PROFILE_SIZES) as? [String] {
            Alamofire.request(ServerUtils.getImageUrl(fileSize: sizes[0], filePath: persons[indexPath.row].profilePath)).responseImage { response in
                debugPrint(response)
                
                print(response.request as Any)
                print(response.response as Any)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    cell.imageView?.image = image
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.personsTable.deselectRow(at: indexPath, animated: true)
    }
    
}

