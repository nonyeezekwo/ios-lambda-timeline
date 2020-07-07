//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostViewController: ShiftableViewController {
    
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
//    @IBOutlet weak var imageViewFilter: UIImageView!
    
    // MARK: - SLIDER OUTLETS
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var distortionSlider: UISlider!
    @IBOutlet weak var kaleidoscopeSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    
    let vibranceFilter = CIFilter(name: "CIVibrance")
    let exposureFilter = CIFilter(name: "CIExposureAdjust")
    let distortionFilter = CIFilter(name: "CIBumpDistortion")
    let kaleidoscopeFilter = CIFilter(name: "CIKaleidoscope")
    let hueFilter = CIFilter(name: "CIHueAdjust")
    
    private let context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultValues()
//        setImageViewHeight(with: 1.0)
        
//        updateViews()
        orginalImage = imageView.image
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Slider Defaults
    private func defaultValues() {
        vibranceSlider.value = 0
        exposureSlider.value = 0
        distortionSlider.value = 0.5 // idk
        kaleidoscopeSlider.value = 0.25 // idk
        hueSlider.value = 0
    }
    
    private var orginalImage: UIImage? {
        didSet {
            guard let image = orginalImage else {
                scaledImage = nil
                return
            }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            //imageByScaling is coming from the UIImage+Scaling.swift
            let scaledImage = image.imageByScaling(toSize: scaledSize)
            self.scaledImage = scaledImage
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    //What we call to move slider - THIS IS NOT WORKING
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(_: scaledImage)
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
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func image(_ image: UIImage) -> UIImage {
        
        //UIImage -> CGImage -> CIImage "recipe"
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        
        //Vibrance Filter
        filter.inputImage = ciImage
        let filter2 = CIFilter(name: "CIColorControls")!
        filter2.setValue(ciImage, forKey: "inputImage")
        filter2.setValue(vibranceSlider.value, forKey: "inputAmount")
    
//        vibranceFilter?.setValue(vibranceSlider.value, forKey: "inputAmount")
//        vibranceFilter?.setValue(vibranceSlider.value, forKey: filterKey.vibrance.rawValue)
//        guard let vibranceCIImage = vibranceFilter?.outputImage else { return image }

        
        //Exposure Filter
        exposureFilter?.setValue(exposureSlider.value, forKey: filterKey.exposure.rawValue)
        guard let exposureCIImage = exposureFilter?.outputImage else { return image }
        
        //REDO THIS ONE TO SOMETHING WITHOUT CIVECTOR, MAYBE BLUR?
        //Distortion Filter
        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.distortInputScale.rawValue)
        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.distortInputRadius.rawValue)
        distortionFilter?.setValue(CIVector(cgPoint: CGPoint(x: 150, y: 150)), forKey: kCIInputCenterKey)
//        distortionFilter?.setValue(distortionSlider.value, forKey: filterKey.inputCenter.rawValue)
        guard let distortionCIImage = distortionFilter?.outputImage else { return image }
        
        //Kaleidoscope Filter - CHANGE FILTER.
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
    
    //Save button tapped action
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        guard let orginalImage = orginalImage else { return }
        
        let filteredImage = image(orginalImage)
        
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
                DispatchQueue.main.async {
                    print("Saved photo")
                }
                //Present an alert to the user saying that the image was unable to be saved
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        @unknown default:
            print("FatalError")
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
        dismiss(animated: false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
