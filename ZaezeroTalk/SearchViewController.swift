//
//  SearchViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var customNavigationItem: UINavigationItem! {
        didSet {
            customNavigationItem.titleView = searchController.searchBar
        }
    }
    @IBOutlet weak var searchResultTableView: UITableView! {
        didSet {
            searchResultTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
            searchResultTableView.dataSource = self
            searchResultTableView.delegate = self
        }
    }
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        return searchController
    }()
    
    var searchResultFriends: [(uid: String,info: UserInfo)]?
    
    lazy var friends: [(uid: String,info: UserInfo)] = {
        var friends = [(uid: String,info: UserInfo)]()
        if let friendsDictionary = ConnectedUser.shared.user.friends {
            friends = friendsDictionary.map { (key,value) in
                (key,value)
            }
        }
        return friends
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        searchResultFriends = friends.filter{ $0.info.name.localizedCaseInsensitiveContains(text)}
        searchResultTableView.reloadData()
    }
}

// MARK: - SearchResult Table View DataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultFriends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        
        cell.nameLabel.text = searchResultFriends![indexPath.row].info.name
        cell.stateMessageLabel.text = searchResultFriends![indexPath.row].info.stateMessage
        if let profileImageUrl = searchResultFriends![indexPath.row].info.profileImageUrl, !profileImageUrl.isEmpty {
            let url = URL(string: profileImageUrl)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async { cell.profileImageView.image = UIImage(data: data!) }
            }
        } else {
            cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
        }
        return cell
    }
    
    
}

// MARK: - SearchResult Table View Delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "ProfileViewController", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        profileVC.selectedUserUid = searchResultFriends![indexPath.row].uid
        profileVC.selectedUserInfo = searchResultFriends![indexPath.row].info
        
        profileVC.modalPresentationStyle = .fullScreen
        searchController.present(profileVC, animated: true, completion: nil)
    }
}
