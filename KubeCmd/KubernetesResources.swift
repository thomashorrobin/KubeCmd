//
//  KubernetesResources.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/12/2020.
//

import Foundation

enum KubernetesResources: String {
	case pods = "Pod"
	case cronjobs = "CronJob"
	case deployments = "Deployment"
	case jobs = "Job"
	case configmaps = "ConfigMap"
	case secrets = "Secret"
	case ingresses = "Ingress"
	case services = "Service"
}
