import SwiftUI
import AVFoundation
import UIKit

// ERROR HANDLING
func requestCameraAccess(completion: @escaping (Bool) -> Void) {
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch cameraAuthorizationStatus {
    case .notDetermined:
        // Request permission if not determined yet
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    case .restricted, .denied:
        // If permission restricted/denied, inform the user
        completion(false)
    case .authorized:
        // Permission granted
        completion(true)
    @unknown default:
        // Handle future cases
        completion(false)
    }
}

requestCameraAccess { granted in
    if granted {
        // Start QR code scanner
        startQRCodeScanner()
    } else {
        // Handle camera denied
        print("Camera access denied")
    }
}

// IF PERMISSION NOT GRANTED
if !granted {
    let alert = UIAlertController(title: "Camera Access Needed",
                                  message: "Please enable camera access in Settings to scan QR codes.",
                                  preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true)
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject], 
                        from connection: AVCaptureConnection) {

        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  metadataObject.type == .qr, 
                  let stringValue = metadataObject.stringValue else { return }
        
        print(stringValue)
    }
}

// logo

// Scan QR code

func scanning() {
    // Initialize device object and provide the video as media type parameter.
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    // Get AVCaptureDeviceInput class using previous device object.
    var error:NSError?
    let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)

    if (error != nil) {
        // log error
        println("\(error?.localizedDescription)")
        return
    }

    // Initialize the captureSession object.
    captureSession = AVCaptureSession()
    // Set input device on capture session.
    captureSession?.addInput(input as! AVCaptureInput)

    // Initialize object setting it as output device to capture session.
    let captureMetadataOutput = AVCaptureMetadataOutput()
    captureSession?.addOutput(captureMetadataOutput)

    // calculate a centered square rectangle with red border
    let size = 300
    let screenWidth = self.view.frame.size.width
    let xPos = (CGFloat(screenWidth) / CGFloat(2)) - (CGFloat(size) / CGFloat(2))
    let scanRect = CGRect(x: Int(xPos), y: 150, width: size, height: size)

    // create UIView that will server as a red square to indicate where to place QRCode for scanning
    scanAreaView = UIView()
    scanAreaView?.layer.borderColor = UIColor.redColor().CGColor
    scanAreaView?.layer.borderWidth = 4
    scanAreaView?.frame = scanRect

    // Set delegate and use the default dispatch queue to execute the call back
    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    captureMetadataOutput.rectOfInterest = scanRect


    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    videoPreviewLayer?.frame = view.layer.bounds
    view.layer.addSublayer(videoPreviewLayer)

    // Start video capture.
    captureSession?.startRunning()

    // Initialize QR Code Frame to highlight the QR code
    qrCodeFrameView = UIView()
    qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
    qrCodeFrameView?.layer.borderWidth = 2
    view.addSubview(qrCodeFrameView!)
    view.bringSubviewToFront(qrCodeFrameView!)

    // Add a button that will be used to close out of the scan view
    videoBtn.setTitle("Close", forState: .Normal)
    videoBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
    videoBtn.backgroundColor = UIColor.grayColor()
    videoBtn.layer.cornerRadius = 5.0;
    videoBtn.frame = CGRectMake(10, 30, 70, 45)
    videoBtn.addTarget(self, action: "pressClose:", forControlEvents: .TouchUpInside)
    view.addSubview(videoBtn)

    view.addSubview(scanAreaView!)
}

    // Start specific tour

    // Show wayfinder path

    // Detect area/strucutre

        // give option for more information (i button)

        // 



// Hardcode

