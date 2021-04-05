//
//  ViewController.swift
//  Instagrid
//
//  Created by Vincent Caronnet on 05/04/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var instructions: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func button0DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[0].isSelected = true
    }
    @IBAction func button1DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[1].isSelected = true
    }
    @IBAction func button2DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[2].isSelected = true
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )
        return cell
    }
    
    
}
