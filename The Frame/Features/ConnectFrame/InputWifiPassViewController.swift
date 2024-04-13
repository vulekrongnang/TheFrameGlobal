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
    
    var didSelectBack: ((String) -> Void)?
    var didSelectConnect: ((String) -> Void)?
    
    var mWifiName: String = "" {
        didSet {
            lblWifiName.text = mWifiName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vBack.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            self?.didSelectBack?("")
        }).disposed(by: disposeBag)
        
        btnConnect.didTap = { [weak self] in
            self?.didSelectConnect?(self?.tfWifiPass.text ?? "")
        }
    }
    
    @IBAction func didTouchOnConnect(_ sender: Any) {
        showLoading()
        didSelectConnect?(tfWifiPass.text ?? "")
    }
}
