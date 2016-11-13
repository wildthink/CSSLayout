//
//  CSSLayout.swift
//  CSSLayout
//
//  Created by Matias Cudich on 10/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import CoreGraphics

public struct CSSEdges: Equatable {
  let left: Float
  let right: Float
  let bottom: Float
  let top: Float

  public init(left: Float = 0, right: Float = 0, bottom: Float = 0, top: Float = 0) {
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
  }

  public init(_ ref: CSSNodeRef, getEdge: (CSSNodeRef, CSSEdge) -> Float) {
    self.left = getEdge(ref, CSSEdgeLeft)
    self.right = getEdge(ref, CSSEdgeRight)
    self.top = getEdge(ref, CSSEdgeTop)
    self.bottom = getEdge(ref, CSSEdgeBottom)
  }

  public func apply(_ ref: CSSNodeRef, _ applyEdge: (CSSNodeRef, CSSEdge, Float) -> Void) {
    applyEdge(ref, CSSEdgeLeft, left)
    applyEdge(ref, CSSEdgeRight, right)
    applyEdge(ref, CSSEdgeTop, top)
    applyEdge(ref, CSSEdgeBottom, bottom)
  }
}

public func ==(lhs: CSSEdges, rhs: CSSEdges) -> Bool {
  return lhs.left == rhs.left && lhs.right == rhs.right && lhs.top == rhs.top && lhs.bottom == rhs.bottom
}

extension CSSSize: Equatable {}

public func ==(lhs: CSSSize, rhs: CSSSize) -> Bool {
  return lhs.height == rhs.height && lhs.width == rhs.width
}

/*
public struct CSSLayout {
  public let frame: CGRect
  public let children: [CSSLayout]

  public init(nodeRef: CSSNodeRef) {
    let x = CGFloat(CSSNodeLayoutGetLeft(nodeRef))
    let y = CGFloat(CSSNodeLayoutGetTop(nodeRef))
    let width = CGFloat(CSSNodeLayoutGetWidth(nodeRef))
    let height = CGFloat(CSSNodeLayoutGetHeight(nodeRef))

    let children: [CSSLayout] = (0..<CSSNodeChildCount(nodeRef)).map {
      let childRef = CSSNodeGetChild(nodeRef, UInt32($0))!
      return CSSLayout(nodeRef: childRef)
    }

    self.frame = CGRect(x: x, y: y, width: width, height: height)
    self.children = children
  }
}
*/

public struct CSSLayout: CustomStringConvertible
{
    public let userInfo: Any?
    public let frame: CGRect
    public let children: [CSSLayout]

    public init (root: CSSNode,
                             availableWidth: Float = Float.nan, availableHeight: Float = Float.nan)
    {
        CSSNodeCalculateLayout(root.nodeRef, availableWidth, availableHeight, CSSDirectionLTR)
        self.init(node: root)
    }

    init(node: CSSNode) {

        self.frame = node.frame
        self.userInfo = node.userInfo
        self.children =  node.children.map { return CSSLayout(node: $0) }
    }


    public func apply ( f: (CSSLayout) -> Void) {
        f (self)
        for c in children { c.apply(f: f) }
    }

    public var description: String {
        return children.isEmpty ?
            "(CSSLayout frame: \(frame))"
            : "(CSSLayout frame: \(frame) children: \(children))"
    }
}

public class CSSNode: Hashable
{

    public var userInfo: Any?

    public func apply ( f: (CSSNode) -> Void) {
        f (self)
        for c in children { c.apply(f: f) }
    }

    public var frame: CGRect {
        let x = CGFloat(CSSNodeLayoutGetLeft(nodeRef))
        let y = CGFloat(CSSNodeLayoutGetTop(nodeRef))
        let width = CGFloat(CSSNodeLayoutGetWidth(nodeRef))
        let height = CGFloat(CSSNodeLayoutGetHeight(nodeRef))
        return CGRect(x: x, y: y, width: width, height: height)
    }

  public var direction: CSSDirection {
    set {
      if newValue != direction {
        CSSNodeStyleSetDirection(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetDirection(nodeRef)
    }
  }

  public var flexDirection: CSSFlexDirection {
    set {
      if newValue != flexDirection {
        CSSNodeStyleSetFlexDirection(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetFlexDirection(nodeRef)
    }
  }

  public var justifyContent: CSSJustify {
    set {
      if newValue != justifyContent {
        CSSNodeStyleSetJustifyContent(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetJustifyContent(nodeRef)
    }
  }

  public var alignContent: CSSAlign {
    set {
      if newValue != alignContent {
        CSSNodeStyleSetAlignContent(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetAlignContent(nodeRef)
    }
  }

  public var alignItems: CSSAlign {
    set {
      if newValue != alignItems {
        CSSNodeStyleSetAlignItems(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetAlignItems(nodeRef)
    }
  }

  public var alignSelf: CSSAlign {
    set {
      if newValue != alignSelf {
        CSSNodeStyleSetAlignSelf(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetAlignSelf(nodeRef)
    }
  }

  public var positionType: CSSPositionType {
    set {
      if newValue != positionType {
        CSSNodeStyleSetPositionType(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetPositionType(nodeRef)
    }
  }

  public var flexWrap: CSSWrapType {
    set {
      if newValue != flexWrap {
        CSSNodeStyleSetFlexWrap(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetFlexWrap(nodeRef)
    }
  }

  public var overflow: CSSOverflow {
    set {
      if newValue != overflow {
        CSSNodeStyleSetOverflow(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetOverflow(nodeRef)
    }
  }

  public var flex: Float {
    set {
      CSSNodeStyleSetFlex(nodeRef, newValue)
    }
    get {
      if flexGrow > 0 {
        return flexGrow
      } else {
        return flexShrink
      }
    }
  }

  public var flexGrow: Float {
    set {
      if newValue != flexGrow {
        CSSNodeStyleSetFlexGrow(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetFlexGrow(nodeRef)
    }
  }

  public var flexShrink: Float {
    set {
      if newValue != flexShrink {
        CSSNodeStyleSetFlexShrink(nodeRef, newValue)
      }
    }
    get {
      return CSSNodeStyleGetFlexShrink(nodeRef)
    }
  }

  public var margin: CSSEdges {
    set {
      if newValue != margin {
        newValue.apply(nodeRef, CSSNodeStyleSetMargin)
      }
    }
    get {
      return CSSEdges(nodeRef, getEdge: CSSNodeStyleGetMargin)
    }
  }

  public var position: CSSEdges {
    set {
      if newValue != position {
        newValue.apply(nodeRef, CSSNodeStyleSetPosition)
      }
    }
    get {
      return CSSEdges(nodeRef, getEdge: CSSNodeStyleGetPosition)
    }
  }

  public var padding: CSSEdges {
    set {
      if newValue != padding {
        newValue.apply(nodeRef, CSSNodeStyleSetPadding)
      }
    }
    get {
      return CSSEdges(nodeRef, getEdge: CSSNodeStyleGetPadding)
    }
  }

  public var size: CSSSize {
    set {
      if newValue.width != size.width {
        CSSNodeStyleSetWidth(nodeRef, newValue.width)
      }
      if newValue.height != size.height {
        CSSNodeStyleSetHeight(nodeRef, newValue.height)
      }
    }
    get {
      let width = CSSNodeStyleGetWidth(nodeRef)
      let height = CSSNodeStyleGetHeight(nodeRef)
      return CSSSize(width: width, height: height)
    }
  }

  public var minSize: CSSSize {
    set {
      if newValue.width != minSize.width {
        CSSNodeStyleSetMinWidth(nodeRef, newValue.width)
      }
      if newValue.height != minSize.height {
        CSSNodeStyleSetMinHeight(nodeRef, newValue.height)
      }
    }
    get {
      let width = CSSNodeStyleGetMinWidth(nodeRef)
      let height = CSSNodeStyleGetMinHeight(nodeRef)
      return CSSSize(width: width, height: height)
    }
  }

  public var maxSize: CSSSize {
    set {
      if newValue.width != maxSize.width {
        CSSNodeStyleSetMaxWidth(nodeRef, newValue.width)
      }
      if newValue.height != maxSize.height {
        CSSNodeStyleSetMaxHeight(nodeRef, newValue.height)
      }
    }
    get {
      let width = CSSNodeStyleGetMaxWidth(nodeRef)
      let height = CSSNodeStyleGetMaxHeight(nodeRef)
      return CSSSize(width: width, height: height)
    }
  }

  public var measure: CSSMeasureFunc? {
    set {
      CSSNodeSetMeasureFunc(nodeRef, newValue)
    }
    get {
      return CSSNodeGetMeasureFunc(nodeRef)
    }
  }

  public var context: UnsafeMutableRawPointer? {
    set {
      CSSNodeSetContext(nodeRef, newValue)
    }
    get {
      return CSSNodeGetContext(nodeRef)
    }
  }

    // jmj
    /*
  public var isTextNode: Bool {
    set {
      CSSNodeSetIsTextnode(nodeRef, isTextNode)
    }
    get {
      return CSSNodeGetIsTextnode(nodeRef)
    }
  }

  public var children: [CSSNode] {
    set {
      var oldValue = children
      var remainingChildren = Set(oldValue)
      for (index, child) in newValue.enumerated() {
        if index < children.count && child != oldValue[index] {
          remainingChildren.remove(oldValue[index])
          removeChild(child: oldValue[index])
          insertChild(child: child, at: index)
        } else if index >= oldValue.count {
          insertChild(child: child, at: index)
        } else {
          remainingChildren.remove(oldValue[index])
        }
      }
      for child in remainingChildren {
        removeChild(child: child)
      }
    }
    get {
      let childCount = CSSNodeChildCount(nodeRef)
      return (0..<childCount).map {
        return CSSNode(nodeRef: CSSNodeGetChild(nodeRef, $0))
      }
    }
  }
 */

    public var children: [CSSNode] = [] {
        didSet {
            var ndx = 0
            for c in children {
                insertChild(child: c, at: ndx)
                ndx += 1
            }
        }
    }

  public var hashValue: Int {
    return nodeRef.hashValue
  }

  public let nodeRef: CSSNodeRef

  public init() {
    self.nodeRef = CSSNodeNew()
  }

  public init(nodeRef: CSSNodeRef) {
    self.nodeRef = nodeRef
  }

  public init(direction: CSSDirection = CSSDirectionLTR, flexDirection: CSSFlexDirection = CSSFlexDirectionColumn, justifyContent: CSSJustify = CSSJustifyFlexStart, alignContent: CSSAlign = CSSAlignAuto, alignItems: CSSAlign = CSSAlignStretch, alignSelf: CSSAlign = CSSAlignStretch, positionType: CSSPositionType = CSSPositionTypeRelative, flexWrap: CSSWrapType = CSSWrapTypeNoWrap, overflow: CSSOverflow = CSSOverflowVisible, flexGrow: Float = 0, flexShrink: Float = 0, margin: CSSEdges = CSSEdges(), position: CSSEdges = CSSEdges(), padding: CSSEdges = CSSEdges(), size: CSSSize = CSSSize(width: Float.nan, height: Float.nan), minSize: CSSSize = CSSSize(width: 0, height: 0), maxSize: CSSSize = CSSSize(width: Float.greatestFiniteMagnitude, height: Float.greatestFiniteMagnitude), measure: CSSMeasureFunc? = nil, context: UnsafeMutableRawPointer? = nil,
      userInfo: Any? = nil,
      children: [CSSNode] = [])
  {
    self.nodeRef = CSSNodeNew()

    self.direction = direction
    self.flexDirection = flexDirection
    self.justifyContent = justifyContent
    self.alignContent = alignContent
    self.alignItems = alignItems
    self.alignSelf = alignSelf
    self.positionType = positionType
    self.flexWrap = flexWrap
    self.overflow = overflow
    self.flexGrow = flexGrow
    self.flexShrink = flexShrink
    self.margin = margin
    self.position = position
    self.padding = padding
    self.size = size
    self.minSize = minSize
    self.maxSize = maxSize
    self.measure = measure
    self.context = context
    self.userInfo = userInfo
    self.children = children
  }

  public func insertChild(child: CSSNode, at index: Int) {
    CSSNodeInsertChild(nodeRef, child.nodeRef, UInt32(index))
  }

  public func removeChild(child: CSSNode) {
    CSSNodeRemoveChild(nodeRef, child.nodeRef)
  }

  public func markDirty() {
    CSSNodeMarkDirty(nodeRef)
  }

  public func calculateLayout(availableWidth: Float = Float.nan, availableHeight: Float = Float.nan) {
    CSSNodeCalculateLayout(nodeRef, availableWidth, availableHeight, CSSDirectionLTR)
  }

  public func layout(availableWidth: Float = Float.nan, availableHeight: Float = Float.nan) -> CSSLayout {
    CSSNodeCalculateLayout(nodeRef, availableWidth, availableHeight, CSSDirectionLTR)
    return CSSLayout(node: self)
  }

  public func debugPrint() {
    let options = CSSPrintOptionsLayout.rawValue | CSSPrintOptionsStyle.rawValue | CSSPrintOptionsChildren.rawValue
    CSSNodePrint(nodeRef, CSSPrintOptions(options))
  }
}

public func ==(lhs: CSSNode, rhs: CSSNode) -> Bool {
  return lhs.nodeRef == rhs.nodeRef
}
