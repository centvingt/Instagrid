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
    
    private var grid = Grid()
    
    private var activeIndexImage = 0
    
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
        
        if let image = grid.images[indexPath.item] {
            cell.image.image = image
            cell.image.isHidden = false
        } else {
            cell.image.image = UIImage()
            cell.image.isHidden = true
        }
        
        return cell
    }
}
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeIndexImage = indexPath.item
        presentActionSheet()
    }
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

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        self.grid.images[self.activeIndexImage] = image
        
        collectionView.reloadData()
    }
    
    func presentActionSheet() {
        let photoLibraryAction = UIAlertAction(
            title: "Choisir dans la galerie",
            style: .default
        ) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(
            title: "Annuler",
            style: .cancel,
            handler: nil
        )
        
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
