//
//  ARViewContainer.swift
//  PersistenceAR
//
//  Created by Zaid Neurothrone on 2022-10-17.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
  let viewModel: ViewModel
  
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    arView.addGestureRecognizer(
      UITapGestureRecognizer(
        target: context.coordinator,
        action: #selector(Coordinator.onTap)
      )
    )
    
    context.coordinator.arView = arView
    arView.session.delegate = context.coordinator
    
    viewModel.onSave = {
      context.coordinator.saveWorldMap()
    }
    
    viewModel.onClear = {
      context.coordinator.clearWorldMap()
    }
    
    // On launch load world map if it was saved in a previous session
    context.coordinator.loadWorldMap()
    return arView
  }
  
  func makeCoordinator() -> Coordinator {
    .init(viewModel: viewModel)
  }

  func updateUIView(_ uiView: ARView, context: Context) {}
}
