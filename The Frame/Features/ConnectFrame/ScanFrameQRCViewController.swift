import Foundation
import UIKit
import LBBottomSheet
import RxSwift
import RxGesture
import SPPermissions

class ScanFrameQRCViewController: BaseViewController {
    
    public static func newInstance() -> ScanFrameQRCViewController {
        let vc = ScanFrameQRCViewController()
        return vc
    }
    
    var mDelegate: ConnectBLEDelegate?
    
    @IBOutlet weak var safeAreaview: UIView!
    
    private var mWifiList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorized = SPPermissions.Permission.camera.authorized
        if authorized {
            initScanView()
        } else {
            let controller = SPPermissions.native([ .camera])
            controller.delegate = self
            controller.present(on: self)
            onPermissionAllowed = {
                self.initScanView()
            }
        }
    }
    
    func initScanView() {
        let vc = ScannerVC()
        vc.setupScanner("Kết nối Wifi", .white, .none, nil ){ (result) in
            self.scanQRCSuccess(result)
        }
        vc.view.frame = self.safeAreaview.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func scanQRCSuccess(_ code:String) {
        mDelegate?.onCodeReceviced(code: code)
    }
}
