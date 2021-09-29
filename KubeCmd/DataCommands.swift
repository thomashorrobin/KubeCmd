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
	var body: some Commands {
		CommandMenu("Data") {
			Button("Refreash Data"){
				print("unimplemented")
			}.keyboardShortcut("R").disabled(!refreashable)
		}
	}
}
