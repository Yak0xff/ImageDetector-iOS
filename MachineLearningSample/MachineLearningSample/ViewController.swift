//
//  ViewController.swift
//  MachineLearningSample
//
//  Created by Robin on 23/06/2017.
//  Copyright © 2017 TendCloud. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Photos

//let model = Inceptionv3()
//
//if let prediction = try? model.prediction(image: image as) {//Make sure the image is in CVPixelBufferFormat
//    descriptionLabel.text = prediction.classLabel
//} else {
//    descriptionLabel.text = "Oops. Error in processing!!"
//}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var chooseBtn: UIButton!
    
    
    var imagePickerController: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupImagePickerController()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController {
    @IBAction func chooseImage(_ sender: Any) {
        showPhotoLibrary()
    }
}

extension ViewController {
    func setupImagePickerController() {
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.allowsEditing = true
    }
    
    func showPhotoLibrary() {
        imagePickerController!.sourceType = .photoLibrary
        
        let authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .denied:
            accessPhotoLibraryAlert()
            break
        case .restricted:
            accessPhotoLibraryAlert()
            break
        case .authorized:
            presentImagePicker()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .denied || authorizationStatus == .notDetermined || authorizationStatus == .restricted {
                    return
                }
                else {
                    self.presentImagePicker()
                }
            })
            break
        }
    }
    
    
    func presentImagePicker() {
        label.text = ""
        self.present(imagePickerController!, animated: true, completion: nil)
    }
    
    func accessPhotoLibraryAlert() {
        label.text = "Allow App to access photo"
    }
    
}

extension ViewController {
    func makePrediction(image: CVPixelBuffer) {
        if let model = try? VNCoreMLModel(for: Inceptionv3().model) { // get the model
            let request = VNCoreMLRequest(model: model) { [weak self] response, error in // create a request using the model
                if let results = response.results as? [VNClassificationObservation], let topResult = results.first{
                    DispatchQueue.main.async { [weak self] in
                        self?.label.text = "\(topResult.identifier)\n\(Int(topResult.confidence * 100))% Sure"//Update the label
                    }
                }
            }
            //The following is to perform the request
            let handler = VNImageRequestHandler(ciImage: CIImage(image: imageView.image!)!)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        makePrediction(image: info[UIImagePickerControllerEditedImage] as! CVPixelBuffer)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
