//
//  CreateResourceCommands.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 02/10/2021.
//

import SwiftUI

struct CreateResourceCommands: Commands {
	var activeClient: Bool
	var body: some Commands {
		CommandMenu("Cluster") {
			Button("Create Cronjob"){
				print("unimplemented")
			}.disabled(!activeClient)
			Button("Create Job"){
				print("unimplemented")
			}.disabled(!activeClient)
			Button("Create ConfigMap"){
				print("unimplemented")
			}.disabled(!activeClient)
			Button("Create Secret"){
				print("unimplemented")
			}.disabled(!activeClient)
		}
	}
}
