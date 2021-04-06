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
    
    enum Layout {
        case layout0, layout1, layout2
    }
    private var layout = Layout.layout0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func button0DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[0].isSelected = true
        layout = .layout0
    }
    @IBAction func button1DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[1].isSelected = true
        layout = .layout1
    }
    @IBAction func button2DidTouched(_ sender: Any) {
        buttons.forEach { (button) in
            button.isSelected = false
        }
        buttons[2].isSelected = true
        layout = .layout2
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layout == .layout2 ? 4 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as? CollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
}
extension ViewController: UICollectionViewDelegate {
    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        var size = CGSize(
            width: (collectionViewWidth - 45) / 2,
            height: (collectionViewWidth - 45) / 2
        )
        if (layout == .layout0 && indexPath.item == 0) || (layout == .layout1 && indexPath.item == 2) {
            size.width = collectionViewWidth - 30
        }
        return size
    }
}
