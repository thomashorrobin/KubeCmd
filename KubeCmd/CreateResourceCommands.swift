//
//  CreateResourceCommands.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 02/10/2021.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

struct CreateResourceCommands: Commands {
	var client:KubernetesClient?
	var body: some Commands {
		let activeClient = client != nil
		CommandMenu("Cluster") {
//			Button("Create Cronjob"){
//				CreateCronjob().openInWindow(title: "Cronjob", sender: self)
//			}.disabled(!activeClient)
//			Button("Create Job"){
//				CreateJob().openInWindow(title: "Job", sender: self)
//			}.disabled(!activeClient)
			Button("Create ConfigMap"){
				func createConfigMap(configMap: core.v1.ConfigMap) {
					do {
						let _ = try client!.configMaps.create(inNamespace: .default, configMap).wait()
					} catch {
						print(error)
					}
				}
				CreateConfigMap(onConfigMapCreate: createConfigMap).openInWindow(title: "ConfigMap", sender: self)
			}.disabled(!activeClient)
			Button("Create Secret"){
				CreateSecret().openInWindow(title: "Secret", sender: self)
			}.disabled(!activeClient)
		}
	}
}
