//
//  HomeViewController.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import YPImagePicker
import AVKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var vContent: UIView!
    
    @IBOutlet weak var tabHome: UIView!
    @IBOutlet weak var icHome: UIImageView!
    @IBOutlet weak var lbHome: UILabel!
    
    @IBOutlet weak var tabAddMedia: UIView!
    @IBOutlet weak var icAddMedia: UIImageView!
    @IBOutlet weak var lbAddMedia: UILabel!
    
    @IBOutlet weak var tabGroup: UIView!
    @IBOutlet weak var icGroup: UIImageView!
    @IBOutlet weak var lbGroup: UILabel!

    @IBOutlet weak var tabAddFrame: UIView!
    @IBOutlet weak var icAddFrame: UIImageView!
    @IBOutlet weak var lbAddFrame: UILabel!
    
    var selectedTab = 0
    
    let postListVC = PostListViewController()
    let settingVC = SettingViewController()
    let pagerVC = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
    var listVC = [BaseViewController]()
    private var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchTab()
        
        tabHome.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            guard let self = self else {return}
            self.selectedTab = 0
            self.switchTab()
            self.pagerVC.setViewControllers([self.listVC[0]], direction: .reverse, animated: false)
        }).disposed(by: disposeBag)
        
        tabAddMedia.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            self?.handleSelectPhoto()
        }).disposed(by: disposeBag)
        
        tabGroup.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            guard let self = self else {return}
            self.selectedTab = 2
            self.switchTab()
            self.pagerVC.setViewControllers([self.listVC[1]], direction: .forward, animated: false)
        }).disposed(by: disposeBag)
        
        tabAddFrame.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            let vc = ConnectViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        initPager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func initPager() {
        pagerVC.delegate = self
        pagerVC.dataSource = self
        listVC.append(postListVC)
        settingVC.parrentVC = self
        listVC.append(settingVC)
        pagerVC.setViewControllers([listVC[0]], direction: .forward, animated: false)
        pagerVC.view.frame = vContent.bounds
        vContent.addSubview(pagerVC.view)
        pagerVC.didMove(toParent: self)
        pagerVC.isPagingEnabled = false
        
        settingVC.didSelectCreateGroup = { [weak self] in
            let vc = CreateGroupViewController()
            vc.isShowBack = true
            vc.didCreatedGroup = { [weak self] in
                self?.settingVC.didCreatedGroup()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func switchTab() {
        if selectedTab == 0 {
            icHome.image = UIImage(named: "ic_home_tab_active")
            lbHome.textColor = UIColor(hexString: "#1877F2")
        } else {
            icHome.image = UIImage(named: "ic_home_tab_normal")
            lbHome.textColor = UIColor(hexString: "#000000")
        }
        
        if selectedTab == 2 {
            icGroup.image = UIImage(named: "ic_group_tab_active")
            lbGroup.textColor = UIColor(hexString: "#1877F2")
        } else {
            icGroup.image = UIImage(named: "ic_group_tab_normal")
            lbGroup.textColor = UIColor(hexString: "#000000")
        }
    }
    
    private func handleSelectPhoto() {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = true
        config.showsPhotoFilters = false
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "MeMo Frame"
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo, .video]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.bottomMenuItemSelectedTextColour = UIColor.red
        config.bottomMenuItemUnSelectedTextColour = UIColor.blue
        config.library.maxNumberOfItems = 1
        config.library.mediaType = .photo
        config.video.compression = AVAssetExportPreset1920x1080
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [weak self] items, cancelled in
            if !cancelled {
                let vc = AddPostViewController()
                vc.selectedMedias = items
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true)
    }
}

extension HomeViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = listVC.firstIndex(of: viewController as! BaseViewController) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0  else {
            return nil
        }
        guard listVC.count >= previousIndex else {
            return nil
        }
        return listVC[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = listVC.firstIndex(of: viewController as! BaseViewController) else {
            return nil
        }
        
        print("index \(vcIndex)")
        
        let nextIndex = vcIndex + 1
        
        guard listVC.count != nextIndex  else {
            
            return nil
        }
        guard listVC.count > nextIndex else {
            return nil
        }
        return listVC[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pagerVC.viewControllers?.first else {
            return
        }
        guard let currentIndex = listVC.firstIndex(of: currentVC as! BaseViewController) else {
            return
        }
        currentPage = currentIndex
    }
}

