import Foundation
import UIKit
import LBBottomSheet
import RxSwift
import RxGesture

class InputWifiPassViewController: BaseViewController {
    
    @IBOutlet weak var lblWifiName: UILabel!
    @IBOutlet weak var ivBack: UIImageView!
    
    @IBOutlet weak var tfWifiPass: UITextField!
    var didSelectBack: ((String) -> Void)?
    var didSelectConnect: ((String) -> Void)?
    
    private var mWifiName: String = ""
    
    public static func newInstance(wifiName: String) -> InputWifiPassViewController {
        let vc = InputWifiPassViewController()
        vc.mWifiName = wifiName
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        lblWifiName.text = mWifiName
//        ivBack.rx.tapGesture().when(.recognized).subscribe({ _ in
//            self.didSelectBack?("")
//        }).disposed(by: disposeBag)
    }
    
    @IBAction func didTouchOnConnect(_ sender: Any) {
        showLoading()
        didSelectConnect?(tfWifiPass.text ?? "")
    }
}
