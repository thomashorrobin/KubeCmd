//
//  KubernetesResources.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import Foundation

enum KubernetesResources: String {
	case pods = "Pods"
	case cronjobs = "Cronjobs"
	case deployments = "Deployments"
	case jobs = "Jobs"
	case configmaps = "ConfigMaps"
	case secrets = "Secrets"
}
