//
//  MLMOJI
//
//  This file is part of Alexis Aubry's WWDC18 scolarship submission open source project.
//  Copyright © 2018 Alexis Aubry. Available under the terms of the MIT License.
//

import UIKit
import MobileCoreServices

private let kAugmentCell = "ImageCollectionViewCell"

/**
 * A view controller to perform data augmentation.
 */

public class AugmentViewController: UIViewController {

    /// The filters to apply.
    let filters: [AugmentationFilter]

    /// The list of augmented images received so far.
    var augmentedImages: [UIImage] = []

    /// The block called when augmentation has finished.
    public var completionHandler: (() -> Void)? = nil

    /// The active augmentation session.
    private var currentSession: AugmentationSession? = nil

    // MARK: - Views

    let paper = Paper()
    let clearButton = UIButton()
    let confirmButton = UIButton(type: .system)
    let drawContainer = UIView()

    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    public var containerLayoutGuide: UILayoutGuide! = nil

    // MARK: - Initialization

    public init(filters: [AugmentationFilter]) {
        self.filters = filters
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) was not implemented.")
    }

    public override func loadView() {
        super.loadView()
        configureViews()
    }

    /**
     * Configures the views.
     */

    private func configureViews() {

        // Configure the clear button

        let clearIcon = UIImage(named: "KeyboardClear")!.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(clearIcon, for: .normal)
        clearButton.adjustsImageWhenHighlighted = true
        clearButton.isEnabled = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)

        // Configure the confirm button

        confirmButton.setTitle("Augment Drawing", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let bgImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            #colorLiteral(red: 0, green: 0.4352941176, blue: 1, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        confirmButton.setBackgroundImage(bgImage, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.clipsToBounds = true

        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmButton.adjustsImageWhenHighlighted = true
        confirmButton.adjustsImageWhenDisabled = true
        confirmButton.isEnabled = false

        // Configure the paper

        paper.backgroundColor = .white
        paper.layer.cornerRadius = 34
        paper.clipsToBounds = true
        paper.delegate = self

        // Configure the collection view

        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier:kAugmentCell)
        collectionView.delegate = self
        collectionView.dataSource = self

    }

    /**
     * Configures the Auto Layout constraint.
     */

    public func configureConstraints() {

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: containerLayoutGuide.leadingAnchor, constant: 44).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: containerLayoutGuide.trailingAnchor, constant: -44).isActive = true
        collectionView.topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor, constant: 44).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor, constant: -44).isActive = true

        view.addSubview(drawContainer)
        drawContainer.translatesAutoresizingMaskIntoConstraints = false
        drawContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        drawContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        drawContainer.addSubview(paper)
        paper.translatesAutoresizingMaskIntoConstraints = false
        paper.widthAnchor.constraint(equalToConstant: 250).isActive = true
        paper.heightAnchor.constraint(equalToConstant: 250).isActive = true
        paper.topAnchor.constraint(equalTo: drawContainer.topAnchor).isActive = true
        paper.leadingAnchor.constraint(equalTo: drawContainer.leadingAnchor).isActive = true

        drawContainer.trailingAnchor.constraint(equalTo: paper.trailingAnchor).isActive = true

        view.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.leadingAnchor.constraint(equalTo: drawContainer.trailingAnchor, constant: 16).isActive = true
        clearButton.topAnchor.constraint(equalTo: drawContainer.topAnchor).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        drawContainer.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.topAnchor.constraint(equalTo: paper.bottomAnchor, constant: 16).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: paper.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: paper.trailingAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        drawContainer.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor).isActive = true

    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.invalidateLayout()
    }

    // MARK: - Drawing

    /**
     * Clears the canvas.
     */

    @objc private func clearCanvas() {
        paper.clear()
        clearButton.isEnabled = false
        confirmButton.isEnabled = false
    }

    /**
     * Confirms the drawing and starts augmentation.
     */

    @objc private func confirm() {

        guard self.currentSession == nil else {
            return
        }

        let startAugmentation: (Bool) -> Void = { _ in

            let session = AugmentationSession(actions: self.filters)
            session.delegate = self

            let imageSize = CGSize(width: 250, height: 250)
            let initialImage = self.paper.exportImage(size: imageSize)
            let initialUIImage = UIImage(cgImage: initialImage)

            self.currentSession = session
            self.insertImage(initialUIImage)
            session.start(initialImage: initialImage)

        }

        view.enqueueChanges(animation: .property(0.35, .linear), changes: {
            self.drawContainer.alpha = 0
            self.drawContainer.isUserInteractionEnabled = false
            self.clearButton.alpha = 0
            self.clearButton.isUserInteractionEnabled = false
        }, completion: startAugmentation)

    }

}

extension AugmentViewController: AugmentationSessionDelegate {

    public func augmentationSession(_ session: AugmentationSession, didCreateImage image: UIImage) {
        guard currentSession == session else {
            return
        }

        insertImage(image)
    }

    public func augmentationSessionDidFinish(_ session: AugmentationSession) {
        guard currentSession == session else {
            return
        }

        currentSession = nil
        completionHandler?()
    }

    func insertImage(_ image: UIImage) {
        let collectionEndIndex = augmentedImages.endIndex
        augmentedImages.append(image)
        collectionView.insertItems(at: [IndexPath(row: collectionEndIndex, section: 0)])
    }

}

extension AugmentViewController: PaperDelegate {

    public func paperDidStartDrawingStroke(_ paper: Paper) {}

    public func paperDidFinishDrawingStroke(_ paper: Paper) {
        clearButton.isEnabled = true
        confirmButton.isEnabled = true
    }

}

extension AugmentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return augmentedImages.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAugmentCell, for: indexPath) as! ImageCollectionViewCell

        cell.configure(image: augmentedImages[indexPath.row])
        return cell

    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let containerSize = collectionView.frame.size.width
        let numberOfCellsPerLine: CGFloat = containerSize < 700 ? 3 : 5
        let cellWidth = (containerSize / numberOfCellsPerLine) - (numberOfCellsPerLine * 3)
        return CGSize(width: cellWidth, height: cellWidth)
    }

}
