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
        
        orginalImage = imageView.image
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
            updateViews()
        }
    }
    
    private func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(_: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    
    
    // MARK: - ACTIONS FOR SLIDERS
    
    // MARK: - ACTIONS

    
    private func filterImage(_ image: UIImage) -> UIImage? {
        //UIImage -> CGImage -> CIImage "recipe"
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorControls()
        
        //Vibrance Filter
        
        //Exposure Filter
        
        
        //
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

