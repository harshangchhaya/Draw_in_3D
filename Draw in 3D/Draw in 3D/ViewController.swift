//
//  ViewController.swift
//  Draw in 3D
//
//  Created by Harshang Chhaya on 7/15/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var currentSpherePosition: SCNVector3!
    var currentSphereColor: UIColor!
    var sphereNode: SCNNode!
    var colorPicker: UIColorWell!
    let placeButton = UIButton()
    let radiusLabel = UILabel()
    var radiusValue: Int = 50
    var rawRadiusScale: Double = 50 {
        didSet {
            // Ensure value stays within the range of 10 to 100
            rawRadiusScale = max(1, min(91, rawRadiusScale))
            radiusValue = Int(ceil(100 - rawRadiusScale + 1))
            updateRadiusLabel(radiusValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        self.configureButton()
        self.configureColorPicker()
        self.configureRadiusLabel()
        let sphere = SCNSphere(radius: 0.02)
        sphere.isGeodesic = true
        sphereNode = SCNNode(geometry: sphere)
        sphereNode.opacity = 0.5
        
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = ARConfiguration.WorldAlignment.gravity

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
    }
    
    // MARK: - UI Interaction
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let pinchScale = Double(gesture.scale)
            let sensitivity: Double = 10.0
            let delta: Double = sensitivity * (1-pinchScale)

            // Update the value based on the pinch gesture
            rawRadiusScale += delta
            gesture.scale = 1.0
        }
    }
    
    @objc func placeSphereAtLocation() {
        let sphere = SCNSphere(radius: 0.025)
        sphere.isGeodesic = true
        let placedSphere = SCNNode(geometry: sphere)
        placedSphere.position = currentSpherePosition
        placedSphere.geometry?.firstMaterial?.diffuse.contents = currentSphereColor
        placedSphere.geometry?.setValue( (Float(radiusValue)/10)*0.025, forKey: "radius")
        
        sceneView.scene.rootNode.addChildNode(placedSphere)
    }
    
    @objc func changeColor() {
        currentSphereColor = colorPicker.selectedColor
    }
    
    // MARK: - UI Config
    
    func configureRadiusLabel() {
        radiusLabel.translatesAutoresizingMaskIntoConstraints = false
        radiusLabel.textAlignment = .center
        view.addSubview(radiusLabel)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        NSLayoutConstraint.activate([
                radiusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                radiusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
            ])
    }
    
    func configureColorPicker() {
        colorPicker = UIColorWell()
        view.addSubview(colorPicker)
        colorPicker.addTarget(self, action: #selector(changeColor), for: .valueChanged)
        
        colorPicker.supportsAlpha = false
        colorPicker.title = "Color"
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            colorPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
    }
    
    func configureButton() {
        view.addSubview(placeButton)
        placeButton.configuration = .gray()
        placeButton.configuration?.title = "Place"
        placeButton.addTarget(self, action: #selector(placeSphereAtLocation), for: .touchUpInside)
        
        placeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            placeButton.heightAnchor.constraint(equalToConstant: 64),
            placeButton.widthAnchor.constraint(equalToConstant: 256)
        ])
    }
    
    
    // MARK: - Functions
    func createSphereNode(position: SCNVector3, rotation: SCNVector4) -> SCNNode {
        // Returns a new sphere to be placed in scene
            let radius: CGFloat = 0.01  // Radius of the circle
            let sphereGeometry = SCNSphere(radius: radius)
        sphereGeometry.isGeodesic = true
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            sphereNode.position = position
            sphereNode.rotation = rotation
            
            return sphereNode
        }
    
    func updateRadiusLabel(_ value: Int) {
        // Updates zoom value
        radiusLabel.text = "zoom: \(value)"
    }
    
    
    func updateSpherePosition(_ position: SCNVector3){
        // Updates the reference sphere's position
        sphereNode.position = position
        sphereNode.geometry?.firstMaterial?.diffuse.contents = currentSphereColor
        sphereNode.geometry?.setValue( (Float(radiusValue)/10)*0.025, forKey: "radius")
       
        
    }
    
    // MARK: - Render
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let frame = sceneView.session.currentFrame else { return }
            
            let ref = simd_make_float4(0, 0, -1, 1)
            let position = SCNVector3(x: 0, y: 0, z: 0)
            let rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)  // Adjust rotation if needed
            
            let sphereNode = createSphereNode(position: position, rotation: rotation)
        
            let ct = frame.camera.transform
            let transformedPoint = simd_mul(ct, ref)
            let transformedPosition = SCNVector3(x: transformedPoint.x, y: transformedPoint.y, z: transformedPoint.z)
            self.currentSpherePosition = transformedPosition
        
            self.updateSpherePosition(SCNVector3(x: transformedPoint.x, y: transformedPoint.y, z: transformedPoint.z))
            
            sphereNode.position = transformedPosition
        }

}
