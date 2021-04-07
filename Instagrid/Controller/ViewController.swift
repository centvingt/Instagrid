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
    @IBOutlet weak var logo: UILabel!
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
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
    
    @IBAction func dragCollectionView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed: transformCollectionViewWithGesture(sender)
        case .ended, .cancelled: finishGesture(sender)
        default: break
        }
    }
    
    private func transformCollectionViewWithGesture(_ gesture: UIPanGestureRecognizer) {
        let gestureTranslation = gesture.translation(in: collectionView)
        
        let isPortrait = UIDevice.current.orientation.isPortrait
        
        let axisGestureTranslation = isPortrait ? gestureTranslation.y : gestureTranslation.x
        
        guard axisGestureTranslation < 0 else { return }
        
        let transform = CGAffineTransform(
            translationX: isPortrait ? 0 : axisGestureTranslation,
            y: isPortrait ? gestureTranslation.y : 0
        )
        
        UIView.animate(
            withDuration: 0.8,
            delay: 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 5,
            options: .curveEaseInOut,
            animations: {
                self.collectionView.transform = transform
                self.instructions.transform = transform
            },
            completion: nil
        )
        
        let screenSize = isPortrait ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        let alpha = 1 - (-axisGestureTranslation / (screenSize / 6))
        self.instructions.alpha = alpha
    }
    private func finishGesture(_ gesture: UIPanGestureRecognizer) {
        let isPortrait = UIDevice.current.orientation.isPortrait

        let screenSize = isPortrait ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        
        let gestureTranslation = gesture.translation(in: collectionView)
        
        let axisGestureTranslation = isPortrait ? gestureTranslation.y : gestureTranslation.x
        
        var transform: CGAffineTransform
        
        if -axisGestureTranslation < screenSize / 4 {
            transform = .identity
        } else {
            transform = CGAffineTransform(
                translationX: isPortrait ? 0 : -screenSize,
                y: isPortrait ? -screenSize : 0
            )
        }
        UIView.animate(
            withDuration: 0.8,
            delay: 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 5,
            options: .curveEaseInOut,
            animations: {
                self.collectionView.transform = transform
                self.instructions.transform = transform
                self.instructions.alpha = 1
            },
            completion: nil
        )
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
