//
//  ViewController.swift
//  ObjectTracker
//
//  Created by Jeffrey Bergier on 6/8/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import AVFoundation
import Vision
import UIKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet private weak var cameraView: UIView?
    @IBOutlet private weak var trackingView: TrackingView?
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private let machineQueue = DispatchQueue(label: "MachineQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    private let videoQueue = DispatchQueue(label: "VideoQueue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    private let model = try! VNCoreMLModel(for: Resnet50().model)
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
        else { return session }
        session.addInput(input)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make the camera appear on the screen
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
        self.captureSession.addOutput(videoOutput)
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    private var lastObservation: VNDetectedObjectObservation?
    private var currentWorkItem: DispatchWorkItem?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            guard
                self.currentWorkItem == nil,
                // make sure that there is a previous observation we can feed into the request
                let lastObservation = self.lastObservation,
                // make sure the pixel buffer can be converted
                let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }
            
            // create the request
            let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: self.handleTrackingUpdate)
            // set the accuracy to high
            // this is slower, but it works a lot better
            trackingRequest.trackingLevel = .accurate
            trackingRequest.preferBackgroundProcessing = false
            
            // create the classifier request
            let classifierRequest = VNCoreMLRequest(model: self.model, completionHandler: self.handleClassificationUpdate)
            classifierRequest.regionOfInterest = lastObservation.boundingBox
            classifierRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionScaleFill
            classifierRequest.preferBackgroundProcessing = false
            
            let work = DispatchWorkItem {
                // perform the request
                do {
                    try self.visionSequenceHandler.perform([trackingRequest, classifierRequest], on: pixelBuffer)
                } catch {
                    print("Throws: \(error)")
                }
                DispatchQueue.main.async {
                    self.currentWorkItem = nil
                }
            }
            self.currentWorkItem = work
            self.machineQueue.async(execute: work)
        }
    }
    
    private func handleTrackingUpdate(_ request: VNRequest, error: Error?) {
        // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
        DispatchQueue.main.async {
            // make sure we have an actual result
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation, self.currentWorkItem != nil else { return }
            
            // prepare for next loop
            self.lastObservation = newObservation
            
            // check the confidence level before updating the UI
            guard newObservation.confidence >= 0.3 else {
                // hide the rectangle when we lose accuracy so the user knows something is wrong
                self.trackingView?.setRedViewFrame(.zero)
                return
            }
            
            // calculate view rect
            var transformedRect = newObservation.boundingBox
            transformedRect.origin.y = 1 - transformedRect.origin.y
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
            
            // move the highlight view
            self.trackingView?.setRedViewFrame(convertedRect)
        }
    }
    
    private func handleClassificationUpdate(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard
                self.currentWorkItem != nil,
                let request = request as? VNCoreMLRequest,
                let classificationObservation = request.results?.first as? VNClassificationObservation,
                request.regionOfInterest.size.width != 1 && request.regionOfInterest.size.width != 1
            else { return }
            
            // calculate view rect
            var transformedRect = request.regionOfInterest
            transformedRect.origin.y = 1 - transformedRect.origin.y
            let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
            
            self.trackingView?.setYellowViewLabelText(classificationObservation.identifier)
            self.trackingView?.setYellowViewFrame(convertedRect)
        }
    }
    
    @IBAction private func userTapped(_ sender: UITapGestureRecognizer) {
        // reset the handler
        self.resetTapped(nil)
        
        // get the center of the tap
        let tapRect = CGRect(origin: sender.location(in: self.view), size: CGSize(width: 120, height: 120))
        let centeredRect = tapRect.centeringRect()
        self.trackingView?.setRedViewFrame(centeredRect)
        
        // convert the rect for the initial observation
        var convertedRect = self.cameraLayer.metadataOutputRectConverted(fromLayerRect: centeredRect)
        convertedRect.origin.y = 1 - convertedRect.origin.y
        
        // set the observation
        let newObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
        self.lastObservation = newObservation
    }
    
    @IBAction private func resetTapped(_ sender: UIBarButtonItem?) {
        self.currentWorkItem?.cancel()
        self.currentWorkItem = nil
        self.lastObservation = nil
        self.trackingView?.reset()
    }
}

