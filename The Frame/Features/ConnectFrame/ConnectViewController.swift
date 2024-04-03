import UIKit
import CoreBluetooth

protocol ConnectBLEDelegate {
    func startConnect()
    func onCodeReceviced(code: String)
    func requestConnectWifi(name: String, password: String)
}

class ConnectViewController: BaseViewController {

    var stringServiceUUID = "1441-05D3-4C5B-8281-93D4E07420CF"
    // BLE related properties
    var uuidService = CBUUID(string: "25AE1441-05D3-4C5B-8281-93D4E07420CF")
    var uuidFrameId = CBUUID(string: "25AE1442-05D3-4C5B-8281-93D4E07420CF")
    var uuidWifiInfo = CBUUID(string: "25AE1443-05D3-4C5B-8281-93D4E07420CF")
    var uuidWifiList = CBUUID(string: "25AE1444-05D3-4C5B-8281-93D4E07420CF")
    var uuidWifiResponse = CBUUID(string: "25AE1445-05D3-4C5B-8281-93D4E07420CF")
    var uuidRequestWifiList = CBUUID(string: "25AE1446-05D3-4C5B-8281-93D4E07420CF")
    var uuidDescription = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")

    var bleCentral: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    
    let userWantsToScanAndConnect: Bool = true
    var frameCode: String = ""
    var isReconnecting = false
    var isFrameConnected = false

    enum BLELifecycleState: String {
        case bluetoothNotReady
        case disconnected
        case scanning
        case connecting
        case connectedDiscovering
        case connected
    }

    var lifecycleState = BLELifecycleState.bluetoothNotReady {
        didSet {
            guard lifecycleState != oldValue else { return }
            appendLog("state = \(lifecycleState)")
            if oldValue == .connected {
                labelSubscription.text = "Not subscribed"
            }
        }
    }

    //  UI related propertie
    
    @IBOutlet weak var textViewStatus: UITextView!
    @IBOutlet weak var textViewLog: UITextView!
    @IBOutlet weak var switchConnect: UISwitch!
    @IBOutlet weak var textFieldDataForRead: UITextField!
    @IBOutlet weak var textFieldDataForWrite: UITextField!
    @IBOutlet weak var textFieldDataForIndicate: UITextField!
    @IBOutlet weak var labelSubscription: UILabel!

    let timeFormatter = DateFormatter()
    
    
    @IBOutlet weak var vViewPager: UIView!
    private let mPageViewController = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
    private var mListViewController = [UIViewController]()
    private let mScanFrameQRCVC = ScanFrameQRCViewController()
    private let mSelectWifiVC = SelectWifiViewController()
    private let mInputWifiPassVC = InputWifiPassViewController()
    
    private var mWifiListString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        textViewStatus.layer.borderWidth = 1
        textViewStatus.layer.borderColor = UIColor.gray.cgColor
        textViewLog.layer.borderWidth = 1
        textViewLog.layer.borderColor = UIColor.gray.cgColor

        textFieldDataForRead.isUserInteractionEnabled = false
        textFieldDataForIndicate.isUserInteractionEnabled = false

        // text field delegate will hide keyboard after "return" is pressed
        textFieldDataForRead.delegate = self
        textFieldDataForWrite.delegate = self
        textFieldDataForIndicate.delegate = self

        timeFormatter.dateFormat = "HH:mm:ss"
        textViewLog.layoutManager.allowsNonContiguousLayout = false // fixes not working scrollRangeToVisible
        appendLog("viewDidLoad")

        initViewControllers()
        
        initBLE()
    }

    @IBAction func onChangeSwitchConnect(_ sender: UISwitch) {
        bleRestartLifecycle()
    }

    @IBAction func onTapOpenSettings(_ sender: Any) {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }

    @IBAction func onTapClearLog(_ sender: Any) {
        textViewLog.text = "Logs:"
        appendLog("log cleared")
    }
    
    private func initViewControllers() {
        mListViewController.removeAll()
        mListViewController.append(mScanFrameQRCVC)
        mListViewController.append(mSelectWifiVC)
        mListViewController.append(mInputWifiPassVC)
        mScanFrameQRCVC.mDelegate = self
        
        
        mPageViewController.delegate = self
        mPageViewController.dataSource = self
        mPageViewController.setViewControllers([mListViewController[0]], direction: .forward, animated: false)
        mPageViewController.isPagingEnabled = false
        mPageViewController.view.frame = vViewPager.bounds
        vViewPager.addSubview(mPageViewController.view)
        
        mSelectWifiVC.didSelectedWifi = { [weak self] wifiName in
            guard let self = self else {return}
            self.mPageViewController.setViewControllers([self.mListViewController[2]], direction: .forward, animated: true)
        }
    }
}

extension ConnectViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = mListViewController.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0  else {
            return nil
        }
        guard mListViewController.count >= previousIndex else {
            return nil
        }
        return mListViewController[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = mListViewController.firstIndex(of: viewController) else {
            return nil
        }
        
        print("index \(vcIndex)")
        
        let nextIndex = vcIndex + 1
        
        guard mListViewController.count != nextIndex  else {
            
            return nil
        }
        guard mListViewController.count > nextIndex else {
            return nil
        }
        return mListViewController[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = mPageViewController.viewControllers?.first else {
            return
        }
        guard mListViewController.firstIndex(of: currentVC) != nil else {
            return
        }
    }
}
    

// MARK: - UI related methods
extension ConnectViewController {
    func appendLog(_ message: String) {
        let logLine = "\(timeFormatter.string(from: Date())) \(message)"
        print("DEBUG: \(logLine)")
        textViewLog.text += "\n\(logLine)"
        let lastSymbol = NSRange(location: textViewLog.text.count - 1, length: 1)
        textViewLog.scrollRangeToVisible(lastSymbol)

        updateUIStatus()
    }

    func updateUIStatus() {
        textViewStatus.text = bleGetStatusString()
    }
}

extension ConnectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - BLE related methods
extension ConnectViewController {
    private func initBLE() {
        // using DispatchQueue.main means we can update UI directly from delegate methods
        bleCentral = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    func bleRestartLifecycle() {
        guard bleCentral.state == .poweredOn else {
            connectedPeripheral = nil
            lifecycleState = .bluetoothNotReady
            return
        }

        if userWantsToScanAndConnect {
            if let oldPeripheral = connectedPeripheral {
                bleCentral.cancelPeripheralConnection(oldPeripheral)
            }
            connectedPeripheral = nil
            bleScan()
        } else {
            bleDisconnect()
        }
    }

    func bleScan() {
        lifecycleState = .scanning
        bleCentral.scanForPeripherals(withServices: [uuidService], options: nil)
    }

    func bleConnect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        lifecycleState = .connecting
        bleCentral.connect(peripheral, options: nil)
    }

    func bleDisconnect() {
        if bleCentral.isScanning {
            bleCentral.stopScan()
        }
        if let peripheral = connectedPeripheral {
            bleCentral.cancelPeripheralConnection(peripheral)
        }
        lifecycleState = .disconnected
    }

    func bleReadCharacteristic(uuid: CBUUID) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            appendLog("ERROR: read failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }

    func bleWriteCharacteristic(uuid: CBUUID, data: Data) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            appendLog("ERROR: write failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func getCharacteristic(uuid: CBUUID) -> CBCharacteristic? {
        guard let service = connectedPeripheral?.services?.first(where: { $0.uuid == uuidService }) else {
            return nil
        }
        return service.characteristics?.first { $0.uuid == uuid }
    }

    private func bleGetStatusString() -> String {
        guard let bleCentral = bleCentral else { return "not initialized" }
        switch bleCentral.state {
        case .unauthorized:
            return bleCentral.state.stringValue + " (allow in Settings)"
        case .poweredOff:
            return "Bluetooth OFF"
        case .poweredOn:
            return "ON, \(lifecycleState)"
        default:
            return bleCentral.state.stringValue
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension ConnectViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        appendLog("central didUpdateState: \(central.state.stringValue)")
        bleRestartLifecycle()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        appendLog("didDiscover {name = \(peripheral.name ?? String("nil"))}")

        guard connectedPeripheral == nil else {
            appendLog("didDiscover ignored (connectedPeripheral already set)")
            return
        }

        bleCentral.stopScan()
        bleConnect(to: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        appendLog("didConnect")
        showLoading()
        lifecycleState = .connectedDiscovering
        peripheral.delegate = self
        peripheral.discoverServices([uuidService])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral === connectedPeripheral {
            appendLog("didFailToConnect")
            connectedPeripheral = nil
            bleRestartLifecycle()
        } else {
            appendLog("didFailToConnect, unknown peripheral, ingoring")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral === connectedPeripheral {
            appendLog("didDisconnect")
            connectedPeripheral = nil
            bleRestartLifecycle()
        } else {
            appendLog("didDisconnect, unknown peripheral, ingoring")
        }
    }
}

extension ConnectViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == uuidService }) else {
            appendLog("ERROR: didDiscoverServices, service NOT found\nerror = \(String(describing: error)), disconnecting")
            bleCentral.cancelPeripheralConnection(peripheral)
            return
        }

        appendLog("didDiscoverServices, service found")
        peripheral.discoverCharacteristics([uuidFrameId, uuidWifiInfo, uuidWifiList, uuidWifiResponse, uuidRequestWifiList, uuidDescription], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        appendLog("didModifyServices")
        // usually this method is called when Android application is terminated
        if invalidatedServices.first(where: { $0.uuid == uuidService }) != nil {
            appendLog("disconnecting because peripheral removed the required service")
            bleCentral.cancelPeripheralConnection(peripheral)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        appendLog("didDiscoverCharacteristics \(error == nil ? "OK" : "error: \(String(describing: error))")")

        if let wifiList = service.characteristics?.first(where: { $0.uuid == uuidWifiList }) {
            peripheral.setNotifyValue(true, for: wifiList)
            appendLog("didDiscoverCharacteristics wifiList")
            if let wifiResponse = service.characteristics?.first(where: { $0.uuid == uuidWifiResponse }) {
                peripheral.setNotifyValue(true, for: wifiResponse)
                appendLog("didDiscoverCharacteristics wifiResponse")
            }
        } else {
            appendLog("WARN: characteristic for indication not found")
            lifecycleState = .connected
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            appendLog("didUpdateValue error: \(String(describing: error))")
            return
        }

        let data = characteristic.value ?? Data()
        let stringValue = String(data: data, encoding: .utf8) ?? ""
        if (characteristic.uuid == uuidRequestWifiList) {
            appendLog("didUpdate uuidRequestWifiList '\(stringValue)'")
        } else if characteristic.uuid == uuidWifiList {
            appendLog("didUpdate uuidWifiList '\(stringValue)'")
            if (stringValue.first == "[") {
                mWifiListString = ""
            }
            
            mWifiListString.append(stringValue)
            
            if (stringValue.last == "]") {
                mWifiListString.removeFirst()
                mWifiListString.removeLast()
                appendLog("mWifiListString = \(mWifiListString)" )
                let wifiList = mWifiListString.components(separatedBy: ", ")
                hideLoading()
                self.mPageViewController.setViewControllers([mListViewController[1]], direction: .forward, animated: true)
                self.mSelectWifiVC.updateWifilist(wifiList: wifiList)
            }
        } else if (characteristic.uuid == uuidWifiResponse) {
            appendLog("didUpdate uuidWifiResponse '\(stringValue)'")
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        appendLog("didWrite \(error == nil ? "OK" : "error: \(String(describing: error))")")
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            appendLog("didUpdateNotificationState error\n\(String(describing: error))")
            lifecycleState = .connected
            return
        }

        if characteristic.uuid == uuidWifiList {
            let info = characteristic.isNotifying ? "Subscribed" : "Not subscribed"
            labelSubscription.text = info
            appendLog(info)
            bleReadCharacteristic(uuid: uuidRequestWifiList)
        } else if (characteristic.uuid == uuidWifiResponse) {
            let info = characteristic.isNotifying ? "uuidWifiResponse" : "Not uuidWifiResponse"
            labelSubscription.text = info
            appendLog(info)
            bleReadCharacteristic(uuid: uuidWifiResponse)
        }
        
        lifecycleState = .connected
    }
}

// MARK: - Other extensions
extension CBManagerState {
    var stringValue: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        @unknown default: return "\(rawValue)"
        }
    }
}

extension ConnectViewController: ConnectBLEDelegate {
    func startConnect() {
        mPageViewController.setViewControllers([mListViewController[1]], direction: .forward, animated: true)
        if (isReconnecting) {
            onCodeReceviced(code: frameCode)
        }
    }
    
    func requestConnectWifi(name: String, password: String) {
        let text = "[\(name),\(password)]"
        let data = text.data(using: .utf8) ?? Data()
        bleWriteCharacteristic(uuid: uuidWifiInfo, data: data)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            if (self.isReconnecting) {
                let frame = PreferenceUtils.instance.getCurrentFrame()
                self.checkFrameStatus(frame: frame)
            } else {
                self.createTempFrame()
            }
        })
    }
    
    func onCodeReceviced(code: String) {
        showLoading()
        frameCode = code
        stringServiceUUID = code + stringServiceUUID
        uuidService = CBUUID(string: stringServiceUUID)
        bleRestartLifecycle()
    }
    
    func createTempFrame() {
        let frame = FrameModel()
        frame.id = "\(Date().currentTimeMillis())"
        frame.code = frameCode
        frame.name = ""
        FrameService.instance.createFrame(frame: frame, onSuccess: { [weak self] tempFrame in
            self?.onCreateTempFrameSuccess(frame: tempFrame)
        }, onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        })
    }
    
    func onCreateTempFrameSuccess(frame: FrameModel) {
        let data = frame.id?.data(using: .utf8) ?? Data()
        bleWriteCharacteristic(uuid: uuidFrameId, data: data)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            self.checkFrameStatus(frame: frame)
        })
    }
    
    func checkFrameStatus(frame: FrameModel) {
        FrameService.instance.checkFrameConnectStatus(frame: frame, onSuccess: { [weak self] frameId in
            if (frameId == frame.id) {
                self?.isFrameConnected = true
                self?.onFrameConnectSuccess(frame: frame)
            }
        }, onError: { [weak self] frameId in
            if (frameId == frame.id) {
                self?.hideLoading()
                if (self?.isFrameConnected != true) {
                    self?.showAlertError(message: "Sai mật khẩu. Vui lòng nhập lại")
                }
            }
        })
    }
    
    func onFrameConnectSuccess(frame: FrameModel) {
        self.hideLoading()
        if (self.isReconnecting) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.mPageViewController.setViewControllers([mListViewController[2]], direction: .forward, animated: true)
//            self.mInputNameViewController.mCode = frameCode
//            self.mInputNameViewController.mFrame = frame
        }
    }
}

extension ConnectViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
