import Foundation
import UIKit
import LBBottomSheet

class SelectWifiViewController: UIViewController {
    
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var tbWifi: UITableView!
    
    var didSelectedWifi: ((String) -> Void)?
    
    private var mWifiList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbWifi.dataSource = self
        tbWifi.delegate = self
        tbWifi.register(WifiCell.NibObject(), forCellReuseIdentifier: WifiCell.nameOfClass)
        tbWifi.reloadData()
    }
    
    func updateWifilist(wifiList: [String]) {
        mWifiList = wifiList
        tbWifi.reloadData()
    }
}

extension SelectWifiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mWifiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WifiCell.nameOfClass) as! WifiCell
        cell.lbName.text = mWifiList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(mWifiList[indexPath.row])")
        didSelectedWifi?(mWifiList[indexPath.row])
    }
}
