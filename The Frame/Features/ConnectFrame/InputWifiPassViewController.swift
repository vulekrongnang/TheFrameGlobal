import Foundation
import UIKit
import LBBottomSheet
import RxSwift
import RxGesture

class InputWifiPassViewController: BaseViewController {
    
    @IBOutlet weak var lblWifiName: UILabel!
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var tfWifiPass: UITextField!
    @IBOutlet weak var btnConnect: CustomButton!
    
    @IBAction func didTouchBack(_ sender: Any) {
        didSelectBack?()
    }
    
    var didSelectBack: (() -> Void)?
    var didSelectConnect: ((String) -> Void)?
    
    var mWifiName: String = "" {
        didSet {
            lblWifiName.text = mWifiName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnConnect.didTap = { [weak self] in
            self?.didSelectConnect?(self?.tfWifiPass.text ?? "")
        }
    }
    
    @IBAction func didTouchOnConnect(_ sender: Any) {
        showLoading()
        didSelectConnect?(tfWifiPass.text ?? "")
    }
}
