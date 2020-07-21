//
//  DefaultAssociatedObjectHolder.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/21.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation

/**
 Components that conform to this protocol have the
 ability to provide lazy initialized associated objects.
 */
public protocol DefaultAssociatedObjectHolder {
}

public extension DefaultAssociatedObjectHolder {
    /**
     Returns an associated object for the corresponding key. If
     it does not exist, a default object is created and stored as
     the associated object.
     
     - parameters:
        - key: The key to associated to the object
        - associationAssign: Optionally provide this as _true_ if you
     want to assign an object. The default behavior is to retain.
        - defaultObject: The closure to be executed if no associated object
     is found.
     */
    func getDefaultAssociatedObject<T>(key: UnsafeRawPointer, associationAssign: Bool = false, defaultObject: () -> T) -> T {
        if let object = objc_getAssociatedObject(self, key) as? T {
            return object
        } else {
            let object = defaultObject()
            objc_setAssociatedObject(self, key, object, associationAssign ? .OBJC_ASSOCIATION_ASSIGN : .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return object
        }
    }
}
