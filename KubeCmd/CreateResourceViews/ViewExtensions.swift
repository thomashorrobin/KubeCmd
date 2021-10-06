//
//  Extensions.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 06/10/2021.
//

import Foundation
import SwiftUI

public extension View {
	@discardableResult
	func openInWindow(title: String, sender: Any?) -> NSWindow {
		let controller = NSHostingController(rootView: self)
		let win = NSWindow(contentViewController: controller)
		win.contentViewController = controller
		win.title = title
		win.makeKeyAndOrderFront(sender)
		return win
	}
}
