import UIKit
import RxGesture
import RxSwift

public protocol HeaderViewControllerDelegate: AnyObject {
    func didClickedCloseButton()
}


public class HeaderVC: UIViewController {
    
    public override var title: String? {
        didSet{
            titleItem.text = title
        }
    }
    
    public lazy var closeImage = imageNamed("ic_back")
    
    
    @IBOutlet weak public var navigationBar: UIView!
    
    @IBOutlet weak var closeBtn: UIView!
    
    @IBOutlet weak var titleItem: UILabel!
    
    private let disposeBag = DisposeBag ()
    public weak var delegate:HeaderViewControllerDelegate?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        let bundle = Bundle(for: HeaderVC.self)
        
        super.init(nibName: nibNameOrNil, bundle: bundle)
        
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: statusHeight + 40)
        view.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
}

extension HeaderVC{
    
    func setupUI() {
        navigationBar.backgroundColor = .white
        
        
        closeBtn.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: {gesture in
                self.delegate?.didClickedCloseButton()
            }
        ).disposed(by: disposeBag)
    }
}


extension HeaderVC:UINavigationBarDelegate {
    
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}
