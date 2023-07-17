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
    var sphereNode: SCNNode!
    var colorPicker: UIColorWell!
    let placeButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        self.configureButton()
        self.configureColorPicker()
        let sphere = SCNSphere(radius: 0.1)
        sphereNode = SCNNode(geometry: sphere)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
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
    func configureColorPicker() {
        colorPicker = UIColorWell()
        view.addSubview(colorPicker)
        
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
        
        placeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            placeButton.heightAnchor.constraint(equalToConstant: 64),
            placeButton.widthAnchor.constraint(equalToConstant: 256)
        ])
    }
    
    func createSphereNode(position: SCNVector3, rotation: SCNVector4) -> SCNNode {
            let radius: CGFloat = 0.01  // Radius of the circle
            let circleGeometry = SCNSphere(radius: radius)
            let circleNode = SCNNode(geometry: circleGeometry)
            
            // Customize appearance, materials, or add additional components to the circle node if desired
            
            circleNode.position = position
            circleNode.rotation = rotation
            
            return circleNode
        }
    
    func updateSpherePosition(_ position: SCNVector3){
        sphereNode.position = position
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let frame = sceneView.session.currentFrame else { return }
            
            let distance: Float = 1.0  // Distance of the circle from the camera in meters
            let ref = simd_make_float4(0, 0, -1, 1)
            let reference = SCNVector4(x: 0, y: 0, z: -distance, w: 0)
            let position = SCNVector3(x: 0, y: 0, z: 0)
            let rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)  // Adjust rotation if needed
            
            let circleNode = createSphereNode(position: position, rotation: rotation)
            
            let cameraTransform = SCNMatrix4(frame.camera.transform)
        /*
            let transformedPosition = GLKMatrix4Multiply(SCNMatrix4ToGLKMatrix4(cameraTransform),SCNVector4ToGLKVector4(reference) )//SCNMatrix4Mult(cameraTransform,reference)
        //SCNMatrix4ToGLKMatrix4(cameraTransform) * SCNVector4ToGLKVector4(reference)
        */
            let ct = frame.camera.transform
            let transformedPoint = simd_mul(ct, ref)
            let transformedPosition = SCNVector3(x: transformedPoint.x, y: transformedPoint.y, z: transformedPoint.z)
        
        self.updateSpherePosition(SCNVector3(x: transformedPoint.x, y: transformedPoint.y, z: transformedPoint.z))
            
            //let cameraPosition = SCNVector3(cameraTransform.m41, cameraTransform.m42, cameraTransform.m43-distance)
        
            //print(cameraTransform)
            
            circleNode.position = transformedPosition
            //sceneView.scene.rootNode.addChildNode(circleNode)
        }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
/*
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
*/
}
