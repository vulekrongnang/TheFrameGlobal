import UIKit

class WifiCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel! {
        didSet {
            selectionStyle = .none
        }
    }
    
}
