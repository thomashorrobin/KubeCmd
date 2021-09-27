//
//  KubernetesMenuView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import SwiftUI
import SwiftkubeClient
import SwiftkubeModel

struct TopLevelK8sMenu: View {
	@EnvironmentObject var resources: ClusterResources
	var body: some View {
		List {
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .cronjobs)}, name: "CronJobs", imageName: "cronjob", itemCount: resources.cronjobs.count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:(.deployments))}, name: "Deployments", imageName: "deploy", itemCount: resources.deployments.count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource: .pods)}, name: "Pods", imageName: "pod", itemCount: resources.pods.count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.jobs)}, name: "Jobs", imageName: "job", itemCount: resources.jobs.count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.configmaps)}, name: "Config Maps", imageName: "cm", itemCount: resources.configmaps.count)
			TopLevelK8sMenuItem(a: {resources.setSelectedResource(resource:.secrets)}, name: "Secrets", imageName: "secret", itemCount: resources.secrets.count)
		}.listStyle(SidebarListStyle())
	}
}
