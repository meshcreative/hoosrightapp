//
//  CameraVC.swift
//  HoosRight
//
//  Created by ios on 08/03/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    
 let cameraManager = CameraManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            addCameraToView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.black
        cameraManager.resumeCaptureSession()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    fileprivate func addCameraToView()
    {
        _ = cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }



    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func flashButton(_ sender: Any) {

        switch (cameraManager.changeFlashMode()) {
        case .off:
            print("Flash Off")
            (sender as AnyObject).setImage(UIImage(named: "flashOffIcon"), for:  UIControlState())
        case .on:
            print("Flash On")
            (sender as AnyObject).setImage(UIImage(named: "flashOnIcon"), for:  UIControlState())
        case .auto:
            print("Flash Auto")
            (sender as AnyObject).setImage(UIImage(named: "FlashAutoIcon"), for:  UIControlState())
        }
    }
    
    
    @IBAction func switchCameraButton(_ sender: Any) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        switch (cameraManager.cameraDevice) {
        case .front:
            print("Front Camera")
            self.flashButton.isHidden = true
            cameraManager.flashMode = .off
        case .back:
            self.flashButton.isHidden = false
            cameraManager.flashMode = .auto
            print("Back Camera")
        }
    }
    
    
    @IBAction func imageOrVideoButton(_ sender: Any) {
        
        cameraManager.cameraOutputMode = cameraManager.cameraOutputMode == CameraOutputMode.stillImage ? CameraOutputMode.videoWithMic : CameraOutputMode.stillImage
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraButton.isSelected = false
            //cameraButton.backgroundColor = UIColor.green
            print("image")
            (sender as AnyObject).setImage(UIImage(named: "camera"), for:  UIControlState())
        case .videoWithMic, .videoOnly:
            print("video")
            (sender as AnyObject).setImage(UIImage(named: "video"), for:  UIControlState())
        }
    }
    
    
    
    @IBAction func captureButton(_ sender: Any) {
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else {
//                    let vc: ImageViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController
//                    if let validVC: ImageViewController = vc {
//                        if let capturedImage = image {
//                            validVC.image = capturedImage
//                            self.navigationController?.pushViewController(validVC, animated: true)
//                        }
//                   }
                }
            })
        case .videoWithMic, .videoOnly:
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            (sender as! UIButton).backgroundColor = (sender as! UIButton).isSelected ? UIColor.red : UIColor.green
            if (sender as! UIButton).isSelected {
                cameraManager.startRecordingVideo()
            } else {
                cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                    if let errorOccured = error {
                        self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                    }
                })
            }
        }
        
    }
    
    
    
    
    
    
    
    
    

}
