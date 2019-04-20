//
//  BookmarksViewController.swift
//  Concrete
//
//  Created by Vinicius Brito on 20/04/19.
//  Copyright © 2019 Vinicius Brito. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController, Storyboarded {

    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorites"
    }
}