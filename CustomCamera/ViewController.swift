//
//  HomeViewController.swift
//  CustomCamera
//
//  Created by user on 12/29/18.
//  Copyright © 2018 Pekshn. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var txtMessageField: UITextView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!

    var captureSession = AVCaptureSession()
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        txtMessageField.resignFirstResponder()
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                currentCamera = device
            }
        }
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButton_touchUpInside(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 0.55
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        sender.layer.add(pulse, forKey: nil)
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 3
        shake.autoreverses = true
        let fromPoint = CGPoint(x: sender.center.x - 13, y: sender.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: sender.center.x + 13, y: sender.center.y)
        let toValue = NSValue(cgPoint: toPoint)
        shake.fromValue = fromValue
        shake.toValue = toValue
        sender.layer.add(shake, forKey: nil)
    }

    @IBAction func logoutButton(_ sender: UIButton) {
        //removing values from default
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        //switching to login screen
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: false)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sendMailButton(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.setToRecipients(["petar034@hotmail.com"])
            mailComposerVC.setSubject("Photo Play App")
            if txtMessageField.text.count != 0 {
                mailComposerVC.setMessageBody("\(txtMessageField.text ?? "Sent From App")", isHTML: false)
            } else {
                let alert = UIAlertController(title: "No text added", message: "Add some text please!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
                self.present(alert, animated: true, completion: nil)
            }
            mailComposerVC.mailComposeDelegate = self
            
            if let image3jpg = image3.image?.jpegData(compressionQuality: 0.5)
            {
                mailComposerVC.addAttachmentData(image3jpg, mimeType: "image/jpeg", fileName: "image3.jpeg")
            }
            if let image2jpg = image2.image?.jpegData(compressionQuality: 0.5)
            {
                mailComposerVC.addAttachmentData(image2jpg, mimeType: "image/jpeg", fileName: "image2.jpeg")
            }
            if let image1jpg = image1.image?.jpegData(compressionQuality: 0.5)
            {
                mailComposerVC.addAttachmentData(image1jpg, mimeType: "image/jpeg", fileName: "image1.jpeg")
                present(mailComposerVC, animated: true, completion: nil)                
            }
            else {
                    let alert = UIAlertController(title: "No pictures added", message: "Make some pictures please!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
                    self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_image1segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = image1.image
        } else if segue.identifier == "show_image2segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = image2.image
        } else if segue.identifier == "show_image3segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = image3.image
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            print(imageData)
            image = UIImage(data: imageData)
            image3.image = image2.image
            image2.image = image1.image
            image1.image = self.image
            UIView.transition(with: image1, duration: 0.3, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
}
