//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Nonye on 7/6/20.
//  Copyright © 2020 Nonye Ezekwo. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    
    enum filterKey: String {
        case inputImage = "inputImage"
        case vibrance = "inputAmount"
        case exposure = "inputEV"
        case inputCenter = "inputCenter"
        case distortInputRadius = "inputRadius"
        case distortInputScale = "inputScale"
        case kaleidoInputCount = "inputCount"
        case inputAngle = "inputAngle"
    }
    
    // MARK: - OUTLETS
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - SLIDER OUTLETS
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var distortionSlider: UISlider!
    @IBOutlet weak var kaleidoscopeSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    
    let vibranceFilter = CIFilter(name: "CIVibrance")
    let exposureFilter = CIFilter(name: "CIExposureAdjust")
    let distortionFilter = CIFilter(name: "CIExposureAdjust")
    let kaleidoscopeFilter = CIFilter(name: "CIKaleidoscope")
    let hueFilter = CIFilter(name: "CIHueAdjust")
    
    private let context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultValues()
        orginalImage = imageView.image
    }
    
    //Slider Defaults
    private func defaultValues() {
        vibranceSlider.value = 0
        exposureSlider.value = 0
        distortionSlider.value = 0 // idk
        kaleidoscopeSlider.value = 0 // idk
        hueSlider.value = 0
    }
    
    private var orginalImage: UIImage? {
        didSet {
            guard let orginalImage = orginalImage else {
                scaledImage = nil
                return
            }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(_: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    
    
    // MARK: - ACTIONS FOR SLIDERS
    @IBAction func vibranceChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func exposureChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func distortionChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func kaleidoscopeChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func hueChanged(_ sender: UISlider) {
        updateImage()
    }
    
    // MARK: - ACTIONS
    
    //Choose Photo
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePicker()
    }
    //Save button tapped action
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        guard let orginalImage = orginalImage else { return }
        
        let filteredImage = filterImage(orginalImage)
        
        PHPhotoLibrary.requestAuthorization { (status) in
    
            guard status == .authorized else {
                NSLog("The user has not authorized permission for Photo Library Usage")

                return
            }
            
            PHPhotoLibrary.shared().performChanges({

                PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
                
            }) { (success, error) in
                if let error = error {
                    NSLog("Error saving photo asset: \(error)")
                    return
                }

                //Present an alert to the user saying that the image was unable to be saved
            }
        }
    }
    
    private func filterImage(_ image: UIImage) -> UIImage {
        
        //UIImage -> CGImage -> CIImage "recipe"
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorControls()
        
        //Vibrance Filter
        vibranceFilter?.setValue(vibranceSlider.value, forKey: filterKey.vibrance.rawValue)
        guard let vibranceCIImage = vibranceFilter?.outputImage else { return image }
        
        //Exposure Filter
        exposureFilter?.setValue(exposureSlider.value, forKey: filterKey.exposure.rawValue)
        guard let exposureCIImage = exposureFilter?.outputImage else { return image }
        
        //Distortion Filter
        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.distortInputScale.rawValue)
        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.distortInputRadius.rawValue)
        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.inputCenter.rawValue)
        guard let distortionCIImage = distortionFilter?.outputImage else { return image }
        
        //Kaleidoscope Filter
        kaleidoscopeFilter?.setValue(kaleidoscopeSlider.value, forKey: filterKey.kaleidoInputCount.rawValue)
        kaleidoscopeFilter?.setValue(kaleidoscopeSlider.value, forKey: filterKey.inputCenter.rawValue)
        kaleidoscopeFilter?.setValue(kaleidoscopeSlider.value, forKey: filterKey.inputAngle.rawValue)
        guard let kaleidoscopeCIImage = kaleidoscopeFilter?.outputImage else { return image }
        
        //Hue Filter
        hueFilter?.setValue(hueSlider.value, forKey: filterKey.inputAngle.rawValue)
        guard let hueCIImage = hueFilter?.outputImage else { return image }
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        return UIImage(cgImage: outputCGImage)
    }
    
        func presentImagePicker() {
            // Make sure the photo library is available to use in the first place
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                NSLog("The photo library is not available")
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        }
    }

 // EOD

// MARK: - EXTENTSION

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            orginalImage = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
}

