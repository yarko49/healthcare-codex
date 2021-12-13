//
//  ProfileEntryViewModel.swift
//  Allie
//
//  Created by Onseen on 11/30/21.
//

import Combine

class ProfileEntryViewModel: ObservableObject {
    
    @Published var patient: CHPatient? = nil
    
    // MARK: - Computed Properties
    
    // MARK: - Initializers
    
    init(patient: CHPatient?) {
        self.patient = patient
    }
    
}

