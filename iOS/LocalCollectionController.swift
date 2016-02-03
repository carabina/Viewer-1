import UIKit
import Photos

class LocalCollectionController: UICollectionViewController {
    var photos = [ViewerItem]()
    var viewerController: ViewerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.registerClass(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.Identifier)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        Photo.checkAuthorizationStatus { success in
            self.photos = Photo.constructLocalElements()
            self.collectionView?.reloadData()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let columns = CGFloat(4)
        let bounds = UIScreen.mainScreen().bounds
        let size = (bounds.width - columns) / columns
        layout.itemSize = CGSize(width: size, height: size)
    }

    func alertControllerWithTitle(title: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        return alertController
    }
}

extension LocalCollectionController {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCell.Identifier, forIndexPath: indexPath) as! PhotoCell
        let photo = self.photos[indexPath.row]
        cell.image = photo.placeholder

        if let asset = PHAsset.fetchAssetsWithLocalIdentifiers([photo.remoteID!], options: nil).firstObject {
            Photo.resolveAsset(asset as! PHAsset, size: .Small, completion: { image in
                cell.image = image
            })
        }

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let collectionView = self.collectionView else { return }

        self.viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView, headerViewClass: HeaderView.self, footerViewClass: FooterView.self)
        self.viewerController!.controllerDataSource = self
        self.presentViewController(self.viewerController!, animated: false, completion: nil)
    }
}

extension LocalCollectionController: ViewerControllerDataSource {
    func viewerController(viewerController: ViewerController, itemAtIndexPath indexPath: NSIndexPath) -> ViewerItem {
        var item = self.photos[indexPath.row]
        if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? PhotoCell, placeholder = cell.imageView.image {
            item.placeholder = placeholder
        }
        self.photos[indexPath.row] = item

        return self.photos[indexPath.row]
    }
}