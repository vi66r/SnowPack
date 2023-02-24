import UIKit
public typealias RemoteAction = (()->Void)
public typealias RemoteTypedAction<T> = ((T?)->Void)
public typealias Remote2DTypedAction<T, X> = ((T?, X?)->Void)
public typealias RemoteMultiAction<T> = ((_ args: T?...)->Void)?
public typealias RemoteTextAction = ((String?)->Void)?
public typealias RemoteImageAction = ((UIImage?)->Void)
public typealias RemoteIndexedAction = ((_ index: Int)->Void)?
