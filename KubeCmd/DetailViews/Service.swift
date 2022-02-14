//
//  Service.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/12/2021.
//

import SwiftUI
import SwiftkubeModel

struct Service: View {
	var service:core.v1.Service
    var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if service.metadata != nil {
				MetaDataSection(resource: service)
			}
			if let spec = service.spec {
				Divider().padding(.vertical, 30)
				Text("Spec").font(.title2)
				if let type1 = spec.type {
					Text("Type: \(type1)")
				}
				if let allocateLoadBalancerNodePorts = spec.allocateLoadBalancerNodePorts {
					Text("Allocate LoadBalancer node ports: \(allocateLoadBalancerNodePorts.description)")
				}
				if let clusterIP = spec.clusterIP {
					Text("ClusterIP: \(clusterIP)")
				}
				if let externalName = spec.externalName {
					Text("External Name: \(externalName)")
				}
				if let externalTrafficPolicy = spec.externalTrafficPolicy {
					Text("External Traffic Policy: \(externalTrafficPolicy)")
				}
				if let healthCheckNodePort = spec.healthCheckNodePort {
					Text("HealthCheck node port: \(healthCheckNodePort)")
				}
				if let ipFamilyPolicy = spec.ipFamilyPolicy {
					Text("IP Family Policy: \(ipFamilyPolicy)")
				}
				if let loadBalancerIP = spec.loadBalancerIP {
					Text("Load Balancer IP: \(loadBalancerIP)")
				}
			}
		})
    }
}
