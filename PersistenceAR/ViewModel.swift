//
//  ViewModel.swift
//  PersistenceAR
//
//  Created by Zaid Neurothrone on 2022-10-17.
//

import Foundation

enum WorldMapStatus: String {
  case notAvailable = "Not Available"
  case limited = "Limited"
  case extending = "Extending"
  case mapped = "Mapped"
}

final class ViewModel: ObservableObject {
  @Published var wasSaved = false
  @Published var worldMapStatus: WorldMapStatus = .notAvailable
  
  var onSave: () -> Void = {}
  var onClear: () -> Void = {}
}
