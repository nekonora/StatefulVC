//
//  StatefulVM.swift
//
//  Created by Filippo Zaffoni on 01/05/2020.
//  Copyright © 2020 Filippo Zaffoni. All rights reserved.
//

import Foundation
import Combine

/// An object used to manage a view controller with specified types of data.
open class StatefulVM<C, D> {
    
    // MARK: - Properties
    
    @Published private(set) var config: C?
    @Published var data: D?
    
    internal final var onUIUpdate: ((UIState<D>) -> Void)?
    final var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(config: C? = nil, initialData: D? = nil) {
        self.config = config
        self.data = initialData
        self.bindSubscriptions()
    }
    
    // MARK: - Methods
    
    /// Overridable method in which to set observers and other reactive components.
    func bindSubscriptions() { }
    
    internal final func updateViewState(to state: UIState<D>) { onUIUpdate?(state) }
}
