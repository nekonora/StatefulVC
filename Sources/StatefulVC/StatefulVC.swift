//
//  StatefulVC.swift
//
//  Created by Filippo Zaffoni on 21/11/2019.
//  Copyright © 2020 Filippo Zaffoni. All rights reserved.
//

import Combine
import UIKit

#if canImport(UIKit)

/// `UIViewController subclass that provides generic types for easy configuration and managed data.
/// `C`: This should be a type able to be passed to configure the scene (the view model actually)
/// `D`: This is the main type of data the scene manages and displays
///
/// Example: the scene manages and displays an array of `[Book]` from a given `Author`,
///          we can therefore define this scene as:
///          ```
///          class BooksListViewController: StatefulVC<Author, [Books], BooksListViewModel> { ... }
///          ```
open class StatefulVC<C, D, M: StatefulVM<C, D>>: UIViewController {
    
    // MARK: - Properties
    
    /// The model of the scene
    public final var model: M!
    
    // MARK: - State
    
    private var _state = CurrentValueSubject<UIState<D>, Never>(.initial)
    
    /// The represented state of the UI
    var state: UIState<D> { _state.value }
    
    // MARK: - Lifecycle
    
    /// Creates a new instance of the scene built on the provided view model and a storyboard with
    /// the same name of the controller.
    /// - Parameter viewModel: The view model that manages the scene
    /// - Returns: The view controller of the scene
    static func storyboardInstance(with viewModel: M) -> Self? {
        let vc = UIStoryboard(name: String(describing: Self.self),
                              bundle: Bundle.main).instantiateInitialViewController() as? Self
        vc?.model = viewModel
        vc?.model.onUIUpdate = { vc?.setState($0) }
        return vc
    }
    
    /// Creates a new instance of the scene built on the provided view model.
    /// - Parameter viewModel: The view model that manages the scene
    /// - Returns: The view controller of the scene
    static func instance(with viewModel: M) -> Self? {
        let vc = self.init(viewModel: viewModel)
        return vc
    }
    
    required public init(viewModel: M) {
        self.model = viewModel
        super.init(nibName: nil, bundle: nil)
        self.model.onUIUpdate = { [weak self] in self?.setState($0) }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final public override func viewDidLoad() {
        super.viewDidLoad()
        
        _state
            .dropFirst()
            .sink { self.updateUI($0) }
            .store(in: &model.subscriptions)
        
        _state.send(.initial)
    }
    
    // MARK: - Setter
    
    private func setState(_ newState: UIState<D>) { _state.send(newState) }
    
    // MARK: - Overridables
    
    /// Called when the scene is loaded. Should effectively substitute viewDidLoad().
    open func onStateInitial() { }
    
    /// Should be set when transitioning from a state to another.
    open func onStateLoading() { }
    
    /// Called when data has been retrieved and is ready to be shown in the UI.
    /// - Parameter data: The specific data managed by this scene.
    open func onStateData(data: D) { }
    
    /// Should be called whenever an error occours or when data could not be displayed
    open func onStateError() { }
    
    /// Gets called for every state change. This is useful as a single place to update
    /// UI elements based on the the new provided state.
    /// - Parameter state: The newly set stata.
    open func updateUIElements(_ state: UIState<D>) { }
    
    // MARK: - Private methods
    
    private func updateUI(_ newState: UIState<D>) {
        switch newState {
        case .initial:        self.onStateInitial()
        case .loading:        self.onStateLoading()
        case .data(let data): self.onStateData(data: data)
        case .error:          self.onStateError()
        }

        self.updateUIElements(newState)
    }
}

#endif
