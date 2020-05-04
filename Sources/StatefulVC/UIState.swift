//
//  UIState.swift
// 
//  Created by Filippo Zaffoni on 01/05/2020.
//  Copyright © 2020 Filippo Zaffoni. All rights reserved.
//

/// The various states an UI could be set to.
public enum UIState<D> {
    
    case initial
    case loading
    case data(data: D)
    case error
}
