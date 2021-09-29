//
//  DataCommands.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/09/2021.
//

import Foundation
import SwiftUI

struct DataCommands: Commands {
	var refreashable: Bool
	var reload: () -> Void
	var body: some Commands {
		CommandMenu("Data") {
			Button("Refreash Data"){
				print("unimplemented")
				reload()
			}.keyboardShortcut("R").disabled(!refreashable)
		}
	}
}
