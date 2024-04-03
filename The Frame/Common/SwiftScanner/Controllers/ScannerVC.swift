import UIKit
import AVFoundation

public class ScannerVC: UIViewController, HeaderViewControllerDelegate {
    

    public lazy var headerViewController:HeaderVC = .init()
    
    public lazy var cameraViewController:CameraVC = .init()
    
    public var animationStyle:ScanAnimationStyle = .default{
        didSet{
            cameraViewController.animationStyle = animationStyle
        }
    }
    
    public var scannerColor:UIColor = .red{
        didSet{
            cameraViewController.scannerColor = scannerColor
        }
    }
    
    public var scannerTips:String = ""{
        didSet{
           cameraViewController.scanView.tips = scannerTips
        }
    }
    
    public var metadata = AVMetadataObject.ObjectType.metadata {
        didSet{
            cameraViewController.metadata = metadata
        }
    }
    
    public var successBlock:((String)->())?
    
    public var errorBlock:((Error)->())?
    
    public override var title: String?{
        
        didSet {

            if navigationController == nil {
                headerViewController.title = title
            }
        }
    }
 
    public var closeImage: UIImage?{
        
        didSet {
            if navigationController == nil {
                headerViewController.closeImage = closeImage ?? UIImage()
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraViewController.startCapturing()
    }
    
    public func didClickedCloseButton() {}
}


extension ScannerVC{
    
    func setupUI() {
        
        if title == nil {
            title = ""
        }
        
        view.backgroundColor = .black
        
        headerViewController.delegate = self
        
        cameraViewController.metadata = metadata
        
        cameraViewController.animationStyle = animationStyle
        
        cameraViewController.delegate = self
        
        add(cameraViewController)
        
        if navigationController == nil {
            add(headerViewController)
            view.bringSubviewToFront(headerViewController.view)
        }
    }
    
    public func setupScanner(_ title:String? = nil, _ color:UIColor? = nil, _ style:ScanAnimationStyle? = nil, _ tips:String? = nil, _ success:@escaping ((String)->())){
        
        if title != nil {
            self.title = title
        }
        
        if color != nil {
            scannerColor = color!
        }
        
        if style != nil {
            animationStyle = style!
        }
        
        if tips != nil {
            scannerTips = tips!
        }
        
        successBlock = success
    }
}

extension ScannerVC:CameraViewControllerDelegate{
    
    func didOutput(_ code: String) {
        self.dismiss(animated: true){
            self.successBlock?(code)
        }
    }
    
    func didReceiveError(_ error: Error) {
        errorBlock?(error)
    }
}
