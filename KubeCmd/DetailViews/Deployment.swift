//
//  Deployment.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Deployment: View {
	let deployment:apps.v1.Deployment
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if let metadata = deployment.metadata {
				MetaDataSection(metadata: metadata)
			}
			if let status = deployment.status {
				Divider().padding(.vertical, 30)
				Text("Status").font(.title2)
				if let availableReplicas = status.availableReplicas {
					Text("Available Replicas: \(availableReplicas)")
				}
				if let collisionCount = status.collisionCount {
					Text("Collision Count: \(collisionCount)")
				}
				if let observedGeneration = status.observedGeneration {
					Text("Observed Generation: \(observedGeneration)")
				}
				if let readyReplicas = status.readyReplicas {
					Text("Ready Replicas: \(readyReplicas)")
				}
				if let replicas = status.replicas {
					Text("Replicas: \(replicas)")
				}
				if let unavailableReplicas = status.unavailableReplicas {
					Text("Unavailable Replicas: \(unavailableReplicas)")
				}
				if let updatedReplicas = status.updatedReplicas {
					Text("Updated Replicas: \(updatedReplicas)")
				}
			}
			if let spec = deployment.spec {
				Divider().padding(.vertical, 30)
				Text("Spec").font(.title2)
				Text("Suspended: \(String(spec.paused ?? false))")
				if let replicas = spec.replicas {
					Text("Desired Replicas: \(replicas)")
				}
			}
		})
	}
}

struct RestartDeployment: View {
	let deployment: apps.v1.Deployment
	@EnvironmentObject var resources: ClusterResources
	var body: some View{
		Button("Restart", action: {
			do {
				try resources.restartDeployment(deployment: self.deployment)
			} catch {
				print(error)
			}
		})
	}
}

//struct Deployment_Previews: PreviewProvider {
//    static var previews: some View {
//        Deployment()
//    }
//}
