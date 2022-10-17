//
//  ContentView.swift
//  PersistenceAR
//
//  Created by Zaid Neurothrone on 2022-10-17.
//

import ARKit
import RealityKit
import SwiftUI

struct ContentView : View {
  @StateObject var viewModel: ViewModel = .init()
  
  var body: some View {
    VStack {
      HStack {
        Text(viewModel.worldMapStatus.rawValue)
          .font(.largeTitle)
      }
      .frame(maxWidth: .infinity, maxHeight: 60)
      .background(.purple)
      
      ARViewContainer(viewModel: viewModel)
        .edgesIgnoringSafeArea(.all)
      
      HStack {
        Button("Clear") {
          viewModel.onClear()
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .padding()
        
        Spacer()
        
        Button("Save") {
          viewModel.onSave()
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .padding()
      }
    }
    .alert("AR World Map has been saved", isPresented: $viewModel.wasSaved) {
      Button(role: .cancel, action: {}) {
        Text("OK")
      }
    }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
