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
    
    private var grid = Grid()

    private var layout = Layout.layout0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var activeIndexImage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let state = UIControl.State.selected.union(UIControl.State.disabled)
        buttons.forEach ({ $0.setImage(UIImage(named: "Selected"), for: state) })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
    }
    
    @IBAction func buttonDidTouched(_ sender: UIButton) {
        buttons.forEach { (button) in
            button.isSelected = button.tag == sender.tag
        }
        
        guard let layout = Layout(rawValue: sender.tag) else { return }
        self.layout = layout
    }
    
    @IBAction func dragCollectionView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began: disableAllButtons(sender)
        case .changed: transformCollectionViewWithGesture(sender)
        case .ended, .cancelled: finishGesture(sender)
        default: break
        }
    }
    
    private func disableAllButtons(_ gesture: UIPanGestureRecognizer) {
        buttons.forEach{ button in
            button.isEnabled = false
        }
    }
    
    private func transformCollectionViewWithGesture(_ gesture: UIPanGestureRecognizer) {
        let gestureTranslation = gesture.translation(in: collectionView)
        
        let isPortrait = UIApplication.shared.statusBarOrientation == .portrait
        
        let orientedGestureTranslation = isPortrait ? gestureTranslation.y : gestureTranslation.x
        
        guard orientedGestureTranslation < 0 else { return }
        
        let transform = CGAffineTransform(
            translationX: isPortrait ? 0 : orientedGestureTranslation,
            y: isPortrait ? orientedGestureTranslation : 0
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
        let alpha = 1 - (-orientedGestureTranslation / (screenSize / 6))
        self.instructions.alpha = alpha
    }
    
    private func finishGesture(_ gesture: UIPanGestureRecognizer) {
        let isPortrait = UIApplication.shared.statusBarOrientation == .portrait

        let screenSize = isPortrait ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        
        let gestureTranslation = gesture.translation(in: collectionView)
        
        let orientedGestureTranslation = isPortrait ? gestureTranslation.y : gestureTranslation.x
        
        let translationIsToShort = -orientedGestureTranslation < screenSize / 4
        
        var transform: CGAffineTransform
        
        if translationIsToShort {
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
            options: .curveEaseInOut
        ) {
            self.collectionView.transform = transform
            self.instructions.transform = transform
            self.instructions.alpha = 1
        } completion: { (true) in
            if !translationIsToShort {
                self.shareGrid()
            }
        }
    }
    
    private func shareGrid() {
        guard grid.isComplete(layout) else {
            presentIncompleteGridAlert()
            return
        }

        let renderer = UIGraphicsImageRenderer(size: collectionView.bounds.size)
        let image = renderer.image { ctx in
            collectionView.drawHierarchy(in: collectionView.bounds, afterScreenUpdates: true)
        }

        let items = [image]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)

        activityViewController.completionWithItemsHandler = {
            (
                activityType: UIActivity.ActivityType?,
                completed: Bool,
                arrayReturnedItems: [Any]?,
                error: Error?
            ) in self.repositionGrid()
        }
    }
    
    private func repositionGrid() {
        UIView.animate(
            withDuration: 0.8,
            delay: 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 5,
            options: .curveEaseInOut
        )  {
            self.collectionView.transform = .identity
            self.instructions.transform = .identity
        } completion: { (true) in
            self.buttons.forEach({ $0.isEnabled = true })
        }
    }
    
    private func presentIncompleteGridAlert() {
        let alert = UIAlertController(
            title: "Warning!",
            message: "Your composition is incomplete.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "I got it",
                style: .default,
                handler: { (acion) in
                    self.repositionGrid()
                }
            )
        )
        self.present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return layout == .layout2 ? 4 : 3
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
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
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        activeIndexImage = indexPath.item
        presentAlertAction()
    }
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        
        var size = CGSize(
            width: (collectionViewWidth - 45) / 2,
            height: (collectionViewWidth - 45) / 2
        )
        if (layout == .layout0 && indexPath.item == 0)
            || (layout == .layout1 && indexPath.item == 2) {
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
    
    func presentAlertAction() {
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
