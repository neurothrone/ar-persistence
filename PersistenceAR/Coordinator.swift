//
//  Coordinator.swift
//  PersistenceAR
//
//  Created by Zaid Neurothrone on 2022-10-17.
//

import ARKit
import RealityKit

final class Coordinator: NSObject, ARSessionDelegate {
  let viewModel: ViewModel
  var arView: ARView?
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  func clearWorldMap() {
    guard let arView = arView else { return }
    
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = .horizontal
    arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "worldMap")
    userDefaults.synchronize()
  }
  
  func loadWorldMap() {
    guard let arView = arView else { return }
    
    let userDefaults = UserDefaults.standard
    
    guard let data = userDefaults.data(forKey: "worldMap"),
          let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
    else {
      return
    }
    
    for anchor in worldMap.anchors {
      let anchorEntity = AnchorEntity(anchor: anchor)
      let box = ModelEntity(
        mesh: .generateBox(size: 0.3),
        materials: [SimpleMaterial(color: .green, isMetallic: true)]
      )
      
      anchorEntity.addChild(box)
      arView.scene.addAnchor(anchorEntity)
    }
    
    let config = ARWorldTrackingConfiguration()
    config.initialWorldMap = worldMap
    config.planeDetection = .horizontal
    
    arView.session.run(config)
  }
  
  func saveWorldMap() {
    guard let arView = arView else { return }
    
    arView.session.getCurrentWorldMap { [weak self] worldMap, error in
      if let error {
        print("❌ -> Failed to get current world map. Error: \(error)")
        return
      }
      
      if let worldMap {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true) else {
          return
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "worldMap")
        userDefaults.synchronize() // Leave out synchronize, it will be saved on its own
        
        self?.viewModel.wasSaved = true
      }
    }
  }
  
  @objc func onTap(_ recognizer: UITapGestureRecognizer) {
    guard let arView = arView else { return }
    
    let tapLocation = recognizer.location(in: arView)
    let raycastResults = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
    
    guard let firstRaycast = raycastResults.first else { return }
    
    //    let anchor = AnchorEntity(raycastResult: firstRaycast)
    
    let arAnchor = ARAnchor(name: "boxAnchor", transform: firstRaycast.worldTransform)
    arView.session.add(anchor: arAnchor)
    
    let anchor = AnchorEntity(anchor: arAnchor)
    let box = ModelEntity(
      mesh: .generateBox(size: 0.3),
      materials: [SimpleMaterial(color: .green, isMetallic: true)]
    )
    
    anchor.addChild(box)
    arView.scene.addAnchor(anchor)
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    switch frame.worldMappingStatus {
    case .notAvailable:
      viewModel.worldMapStatus = .notAvailable
    case .limited:
      viewModel.worldMapStatus = .limited
    case .extending:
      viewModel.worldMapStatus = .extending
    case .mapped:
      viewModel.worldMapStatus = .mapped
    @unknown default:
      fatalError("❌ -> Unknown case of ARFrame.WorldMappingStatus")
    }
  }
}
