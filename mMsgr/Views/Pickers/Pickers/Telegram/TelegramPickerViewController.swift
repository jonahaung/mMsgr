import Foundation
import UIKit
import Photos

public typealias TelegramSelection = (TelegramSelectionType) -> ()

public enum TelegramSelectionType {
    
    case photos([PHAsset])
    case location(Location?)
    case openSmileController(Bool)
    case openAudio(Bool)
}

extension UIAlertController {
    
    /// Add Telegram Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of asset/assets
    
    func addTelegramPicker(selection: @escaping TelegramSelection) {
        let vc = TelegramPickerViewController(selection: selection)
        set(vc: vc)
    }
}



final class TelegramPickerViewController: UIViewController {
    
    var buttons: [ButtonType] {
        return selectedAssets.count == 0 ? [.photoOrVideo, .smiles, .audio, .location] : [.send]
    }
    
    enum ButtonType {
        case photoOrVideo
        case location
        case smiles
        case audio
        case send
        
        var title: String {
            switch self {
            case .photoOrVideo: return "More Photos from Phone"
            case .location: return "Share Location"
            case .smiles: return "Send A Smile"
            case .audio: return "Send Voice Message"
            case .send: return "Send "
            }
        }
        
        var image: UIImage? {
            let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .medium)
            switch self {
            case .photoOrVideo: return UIImage(systemName: "photo.on.rectangle", withConfiguration: config)
            case .location: return UIImage(systemName: "mappin.and.ellipse", withConfiguration: config)
            case .smiles: return UIImage(systemName: "heart.circle.fill", withConfiguration: config)
            case .audio: return UIImage(systemName: "music.note.list", withConfiguration: config)
            case .send: return UIImage(systemName: "paperplane.fill", withConfiguration: config)
            }
        }
    }
    
    // MARK: UI
    
    struct UI {
        static let rowHeight: CGFloat = 58
        static let insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let minimumInteritemSpacing: CGFloat = 0
        static let minimumLineSpacing: CGFloat = 3
        static let maxHeight: CGFloat = (GlobalVar.vSCREEN_WIDTH / 2)
        static let multiplier: CGFloat = 1.5
        static let animationDuration: TimeInterval = 0.3
    }
    
    var preferredHeight: CGFloat {
        return UI.maxHeight / (selectedAssets.count == 0 ? UI.multiplier : 1) + UI.insets.vertical
    }
    
    func sizeFor(asset: PHAsset) -> CGSize {
        let height: CGFloat = UI.maxHeight
        let width: CGFloat = CGFloat(Double(height) * Double(asset.pixelWidth) / Double(asset.pixelHeight))
        return CGSize(width: width, height: height)
    }
    
    func sizeForItem(asset: PHAsset) -> CGSize {
        let size: CGSize = sizeFor(asset: asset)
        if selectedAssets.count == 0 {
            let value: CGFloat = size.height / UI.multiplier
            return CGSize(width: value, height: value)
        } else {
            return size
        }
    }
    
    // MARK: Properties
    
    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.allowsMultipleSelection = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollView.DecelerationRate.fast
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = UI.insets
        $0.backgroundColor = nil
        $0.maskToBounds = false
        $0.clipsToBounds = false
        $0.register(ItemWithPhoto.self)
        
        return $0
        }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    fileprivate lazy var layout: PhotoLayout = { [unowned self] in
        $0.delegate = self
        $0.lineSpacing = UI.minimumLineSpacing
        return $0
        }(PhotoLayout())
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.rowHeight = UI.rowHeight
        $0.separatorColor = UIColor.systemGroupedBackground.darker(by: 7)
        $0.separatorStyle = .singleLine
        $0.backgroundColor = nil
        $0.bounces = false
        $0.tableHeaderView = collectionView
        $0.register(LikeButtonCell.self)
        return $0
        }(UITableView(frame: .zero, style: .plain))
    
    lazy var assets = [PHAsset]()
    lazy var selectedAssets = [PHAsset]()
    
    var selection: TelegramSelection?
    
    // MARK: Initialize
    
    required init(selection: @escaping TelegramSelection) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width * 0.5
        }
        updatePhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        preferredContentSize.height = tableView.contentSize.height
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }
    
    
    func layoutSubviews() {
        tableView.tableHeaderView?.height = preferredHeight
        preferredContentSize.height = tableView.contentSize.height
        
    }
    
    func updatePhotos() {
        checkStatus { [unowned self] assets in
            
            self.assets.removeAll()
            self.assets.append(contentsOf: assets)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }
    
    func checkStatus(completionHandler: @escaping ([PHAsset]) -> ()) {
        Log("status = \(PHPhotoLibrary.authorizationStatus())")
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .notDetermined:
            /// This case means the user is prompted for the first time for allowing contacts
            Assets.requestAccess { [unowned self] status in
                self.checkStatus(completionHandler: completionHandler)
            }
            
        case .authorized:
            /// Authorization granted by user for this app.
            DispatchQueue.main.async {
                self.fetchPhotos(completionHandler: completionHandler)
            }
            
        case .denied, .restricted:
            /// User has denied the current app to access the contacts.
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            let alert = UIAlertController(style: .alert, title: "Permission denied", message: "\(productName) does not have access to contacts. Please, allow the application to access to your photo library.")
            alert.addAction(title: "Settings", style: .destructive) { action in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            alert.addAction(title: "OK", style: .cancel) { [unowned self] action in
                self.alertController?.dismiss(animated: true)
            }
            alert.show()
        @unknown default:
            fatalError()
        }
    }
    
    func fetchPhotos(completionHandler: @escaping ([PHAsset]) -> ()) {
        Assets.fetch { [unowned self] result in
            switch result {
                
            case .success(let assets):
                completionHandler(assets)
                
            case .error(let error):
                Log("------ error")
                let alert = UIAlertController(style: .alert, title: "Error", message: error.localizedDescription)
                alert.addAction(title: "OK") { [unowned self] action in
                    self.alertController?.dismiss(animated: true)
                }
                alert.show()
            }
        }
    }
    
    func action(withAsset asset: PHAsset, at indexPath: IndexPath) {
        let previousCount = selectedAssets.count
        
        selectedAssets.contains(asset) ? selectedAssets.remove(asset) : selectedAssets.append(asset)
        
        let currentCount = selectedAssets.count
        
        if (previousCount == 0 && currentCount > 0) || (previousCount > 0 && currentCount == 0) {
            UIView.animate(withDuration: 0.9, animations: {
                self.layout.invalidateLayout()
            }) { finished in
                self.tableView.reloadData()
                self.layoutSubviews()
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                
            }
        } else {
            tableView.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }
        
    }
    
    func action(for button: ButtonType) {
        switch button {
            
        case .photoOrVideo:
            alertController?.addPhotoLibraryPicker(flow: .vertical, paging: false, selection: .multiple(action: { (assets) in
                self.selection?(TelegramSelectionType.photos(assets))
            }))
            
        case .location:
            alertController?.addLocationPicker { location in
                self.selection?(TelegramSelectionType.location(location))
            }
            
        case .smiles:
            alertController?.dismiss(animated: true) { [unowned self] in
                self.selection?(TelegramSelectionType.openSmileController(true))
            }
            
        case .send:
            alertController?.dismiss(animated: true) { [unowned self] in
                self.selection?(TelegramSelectionType.photos(self.selectedAssets))
            }
            
        case .audio:
            alertController?.dismiss(animated: true) { [unowned self] in
                self.selection?(TelegramSelectionType.openAudio(true))
            }
        }
    }
}

// MARK: - TableViewDelegate

extension TelegramPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SoundManager.playSound(tone: .Tock)
        action(withAsset: assets[indexPath.item], at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        action(withAsset: assets[indexPath.item], at: indexPath)
    }
}

// MARK: - CollectionViewDataSource

extension TelegramPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemWithPhoto = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let asset = assets[indexPath.item]
        let size = sizeFor(asset: asset)
        
        DispatchQueue.main.async {
            Assets.resolve(asset: asset, size: size) { new in
                cell.imageView.image = new
            }
        }
        
        return cell
    }
}

// MARK: - PhotoLayoutDelegate

extension TelegramPickerViewController: PhotoLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        let size: CGSize = sizeForItem(asset: assets[indexPath.item])
        //Log("size = \(size)")
        return size
    }
}

// MARK: - TableViewDelegate

extension TelegramPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isSafeToSelect(indexPath: indexPath) {
            action(for: self.buttons[indexPath.row])
        }
    }
}

// MARK: - TableViewDataSource

extension TelegramPickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LikeButtonCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let button = buttons[indexPath.row]
        cell.imageView?.image = button.image
        
        if button == .send {
            cell.textLabel?.text = button.title + " - \(collectionView.indexPathsForSelectedItems?.count ?? 0)"
        } else {
            cell.textLabel?.text = button.title
        }
        return cell
    }
}
