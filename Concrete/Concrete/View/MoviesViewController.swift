//
//  ViewController.swift
//  Concrete
//
//  Created by Vinicius Brito on 20/04/19.
//  Copyright © 2019 Vinicius Brito. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, Storyboarded {

    @IBOutlet weak var collectionViewMovies: UICollectionView!

    weak var coordinator: MainCoordinator?
    private var isLoading = false
    private let serviceManager = MoviesService()
    var viewModelData: [MovieViewModel]? = []
    var arrayResponse: Movies?

    private var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData(page: 1)

        collectionViewMovies.register(UINib(nibName: "MovieCell", bundle: .main),
                                         forCellWithReuseIdentifier: "movieCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionViewMovies.reloadData()
    }

    private func showAlertInternet() {

    }

    private func fetchData(page: Int) {
        if Reachability.isConnectedToNetwork() {
            isLoading = true

            serviceManager.loadGenres { (response, _) in
                print(response ?? "")
                if let genres = response {
                    DBManager.sharedInstance.registerGenres(genres: genres)

                    self.serviceManager.loadMovies(page: "\(page)") { (response, _) in
                        if response != nil {
                            self.setViewModel(response: response)
                        } else {
                            print("error")
                        }
                        self.isLoading = false
                    }
                }
            }

        } else {
            showAlertInternet()
        }
    }

    func setViewModel(response: Movies?) {

        if let model = viewModelData {
            if model.isEmpty {
                if let movies = response?.results {
                    arrayResponse = response
                    viewModelData = movies.map({ return MovieViewModel(item: $0)})
                }
            } else {
                if let movies = response?.results {
                    if let results = response?.results {
                        arrayResponse?.results.append(contentsOf: results)
                    }
                    viewModelData?.append(contentsOf: movies.map({
                        return MovieViewModel(item: $0) }))
                }
            }
        }

        collectionViewMovies.reloadData()
    }

    @objc func bookmark(_ sender: UIButton) {
        if let movie = arrayResponse?.results[sender.tag] {
            DBManager.sharedInstance.checkAndChangeState(movie: movie)
            let indexPath = IndexPath(row: sender.tag, section: 0)
            collectionViewMovies.reloadItems(at: [indexPath])
        }
    }
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewMovies.frame.width / 2 - 15,
                      height: collectionViewMovies.frame.width / 2 + 45)
    }
}

extension MoviesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let count = viewModelData?.count {
            return count
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell",
                                                         for: indexPath) as? MovieCell {
            if let cellData = viewModelData?[indexPath.row] {
                cell.setCellData(cellData: cellData)
                cell.buttonStar.tag = indexPath.row
                cell.buttonStar.addTarget(self, action: #selector(bookmark(_:)), for: .touchUpInside)
            }

            return cell
        }

        return MovieCell()
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let movie = viewModelData?[indexPath.row] {
            coordinator?.createDetails(to: movie)
        }
    }
}
