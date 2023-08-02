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

func pluralizeResourceType(resourceType: KubernetesResources) -> String {
    switch resourceType {
    case .configmaps:
        return "Configmaps"
    case .pods:
        return "Pods"
    case .cronjobs:
        return "Cronjobs"
    case .deployments:
        return "Deployments"
    case .jobs:
        return "Jobs"
    case .secrets:
        return "Secrets"
    case .ingresses:
        return "Ingresses"
    case .services:
        return "Services"
    }
}
func getImageNameFromKubernetesResources(resourceType: KubernetesResources) -> String {
    switch resourceType {
    case .configmaps:
        return "cm"
    case .pods:
        return "pod"
    case .cronjobs:
        return "cronjob"
    case .deployments:
        return "deploy"
    case .jobs:
        return "job"
    case .secrets:
        return "secret"
    case .ingresses:
        return "ingress"
    case .services:
        return "service"
    }
}
