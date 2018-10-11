//
//  ViewController.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var errorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Search controller and Network Manager
    let searchController = UISearchController(searchResultsController: nil)
    let networkingService = NetworkManager()
    
    
    // Mark: View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        prepareSearchBar()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: Private variables
    private enum State {
        case loading
        case populated([VideoGame])
        case paging([VideoGame], next: Int)
        case empty
        case error
        
        var currentRecordings: [VideoGame] {
            switch self {
            case .populated(let recordings):
                return recordings
            case .paging(let recordings, next: _):
                return recordings
            default:
                return []
            }
        }
    }
    
    private var state: State = State.loading {
        didSet {
            setFooterView()
            tableView.reloadData()
        }
    }
    
    private func setFooterView() {
        switch state {
        case .loading:
            tableView.tableFooterView = loadingView
        case .populated:
            tableView.tableFooterView = nil
        case .paging:
            tableView.tableFooterView = loadingView
        case .error:
            tableView.tableFooterView = errorView
        case .empty:
            tableView.tableFooterView = emptyView
        }
    }
    
    // method to prepare navigation bar
    private func prepareNavigationBar() {
        navigationController?.navigationBar.barTintColor = .red
        
        let whiteTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = whiteTitleAttributes
    }
    
    // method for prepare search bar
    private func prepareSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        
        let whiteTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let textFieldInSearchBar = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldInSearchBar.defaultTextAttributes = whiteTitleAttributes
        
        navigationItem.searchController = searchController
        searchController.searchBar.becomeFirstResponder()
    }
    
    func loadPage(_ page: Int = 1) {
        tableView.reloadData()
        
        let query = searchController.searchBar.text
        networkingService.fetchGames(matching: query, page: page) { [weak self] response in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.searchController.searchBar.endEditing(true)
            strongSelf.update(response: response)
        }
    }
    
    func update(response: VideoGameResult) {
        
        // update the state if we get error
        if response.error != nil {
            state = .error
            return
        }
        
        // update the state if the response is empty
        guard let newRecordings = response.videoGames,
            !newRecordings.isEmpty else {
                state = .empty
                return
        }
        
        // if the back end supports pagination, we can use this
        if response.hasMorePages {
            state = .paging(newRecordings, next: response.nextPage)
        }
        else {
            state = .populated(newRecordings)
        }
    }
    
    // configuring table view
    func configureTableView() {
        tableView.dataSource = self
        
        let nib = UINib(nibName: VideoGameTableViewCell.NibName, bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: VideoGameTableViewCell.ReuseIdentifier)
    }
    
    // method to load video games
    @objc private func loadVideoGames() {
        state = .loading
        loadPage()
    }
}

// MARk: Search Bar Delegate Methods
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(loadVideoGames),
                                               object: nil)
        
        perform(#selector(loadVideoGames), with: nil, afterDelay: 0.5)
    }
}

// MARK: Table View Data Source and Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return state.currentRecordings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: VideoGameTableViewCell.ReuseIdentifier)
            as? VideoGameTableViewCell else {
                return UITableViewCell()
        }
        
        if !(state.currentRecordings.count > 0) {
            return cell
        }

        cell.videoGameData = state.currentRecordings[indexPath.row]

        // this supports pagination, if head end supports.
        if case .paging(_, let nextPage) = state, indexPath.row == state.currentRecordings.count - 1 {
            loadPage(nextPage)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

