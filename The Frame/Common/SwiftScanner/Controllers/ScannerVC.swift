import UIKit
import AVFoundation
import RxSwift
import RxGesture
import SnapKit

public class ScannerVC: UIViewController, HeaderViewControllerDelegate {

    
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
    public var didSelectBack: (() -> ())?

    let disposeBag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraViewController.startCapturing()
    }
    
    public func didClickedCloseButton() {
        didSelectBack?()
    }
}


extension ScannerVC{
    
    func setupUI() {
        
        if title == nil {
            title = ""
        }
        
        view.backgroundColor = .black
        
        cameraViewController.metadata = metadata
        
        cameraViewController.animationStyle = animationStyle
        
        cameraViewController.delegate = self
        
        add(cameraViewController)
        
        if navigationController == nil {
            let navView = UIView()
            navView.backgroundColor = .white
            view.addSubview(navView)
            navView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(47)
                make.top.left.right.equalToSuperview()
            }
            
            let vBack = UIView()
            vBack.backgroundColor = .white
            navView.addSubview(vBack)
            vBack.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.width.height.equalTo(40)
            }
            
            let ivBack = UIImageView(image: UIImage(named: "ic_back"))
            vBack.addSubview(ivBack)
            ivBack.snp.makeConstraints { make in
                make.width.height.equalTo(24)
                make.center.equalToSuperview()
            }
            
            let lbTitle = UILabel()
            lbTitle.text = "Quét mã QR"
            lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            lbTitle.textColor = UIColor(hexString: "333752")
            navView.addSubview(lbTitle)
            lbTitle.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(vBack)
            }
            
            let vIndi = UIView()
            vIndi.backgroundColor = .opaqueSeparator
            navView.addSubview(vIndi)
            vIndi.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            vBack.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
                self?.didSelectBack?()
            }).disposed(by: disposeBag)
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
