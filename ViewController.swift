//
//  ViewController.swift
//  Question2
//
//
import UIKit
import ARKit
import SceneKit

// First ViewController: Display 3D objects on horizontal and vertical planes
class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the ARSCNView
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        // Set up the AR session
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        // Create the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Create horizontal plane
        let horizontalPlane = SCNPlane(width: 0.5, height: 0.5)
        horizontalPlane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        let horizontalPlaneNode = SCNNode(geometry: horizontalPlane)
        horizontalPlaneNode.eulerAngles.x = -.pi / 2  // Rotate to lay flat horizontally
        horizontalPlaneNode.position = SCNVector3(0, -0.5, -1) // Adjust position
        scene.rootNode.addChildNode(horizontalPlaneNode)
        
        // Add sphere on horizontal plane
        let sphere = SCNSphere(radius: 0.1)
        let sphereNode = SCNNode(geometry: sphere)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.position = SCNVector3(0, -0.5, -1)
        scene.rootNode.addChildNode(sphereNode)
        
        // Create vertical plane
        let verticalPlane = SCNPlane(width: 0.5, height: 0.5)
        verticalPlane.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
        let verticalPlaneNode = SCNNode(geometry: verticalPlane)
        verticalPlaneNode.position = SCNVector3(0, 0, -1)
        scene.rootNode.addChildNode(verticalPlaneNode)
        
        // Add box on vertical plane
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        box.firstMaterial?.diffuse.contents = UIColor.yellow
        boxNode.position = SCNVector3(0, 0, -1)
        scene.rootNode.addChildNode(boxNode)
    }
}

// Second ViewController: Detect planes and anchor 3D models
class PlaneDetectionViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize ARSCNView
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)

        // Set the delegate
        sceneView.delegate = self

        // Enable debug options for visual aids
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]

        // Run AR session with plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical] // Detect both horizontal and vertical planes
        sceneView.session.run(configuration)
        
        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true
    }

    // Called when a new AR anchor is added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            // Visualize the plane
            let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
            plane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.eulerAngles.x = -.pi / 2 // Horizontal orientation
            node.addChildNode(planeNode)

            // Add an external object or a model to the detected plane
            addExternalObject(to: node)
        }
    }

    // Load and add external 3D model
    func addExternalObject(to node: SCNNode) {
        guard let url = Bundle.main.url(forResource: "ExternalObject", withExtension: "obj") else {
            print("Error: Could not find the external 3D model.")
            return
        }
        
        do {
            let scene = try SCNScene(url: url, options: nil)
            if let modelNode = scene.rootNode.childNodes.first {
                // Set position and scale if needed
                modelNode.position = SCNVector3(0, 0, 0) // Adjust to fit the plane
                modelNode.scale = SCNVector3(0.1, 0.1, 0.1) // Scale down the object
                node.addChildNode(modelNode)
            }
        } catch {
            print("Error loading the 3D model: \(error.localizedDescription)")
        }
    }
}
