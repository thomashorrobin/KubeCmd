//
//  KubernetesResourceListExtensions.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 26/02/2023.
//

import Foundation
import SwiftkubeModel

public extension batch.v1.CronJobList {
    mutating func replaceOrAdd(cj:batch.v1.CronJob) throws {
        let uid = try UUID.fromK8sMetadata(resource: cj as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = cj
                return
            }
        }
        items.append(cj)
    }
}

public extension core.v1.SecretList {
    mutating func replaceOrAdd(s:core.v1.Secret) throws {
        let uid = try UUID.fromK8sMetadata(resource: s as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = s
                return
            }
        }
        items.append(s)
    }
}

public extension core.v1.ConfigMapList {
    mutating func replaceOrAdd(cm:core.v1.ConfigMap) throws {
        let uid = try UUID.fromK8sMetadata(resource: cm as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = cm
                return
            }
        }
        items.append(cm)
    }
}

public extension apps.v1.DeploymentList {
    mutating func replaceOrAdd(d:apps.v1.Deployment) throws {
        let uid = try UUID.fromK8sMetadata(resource: d as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = d
                return
            }
        }
        items.append(d)
    }
}

public extension networking.v1.IngressList {
    mutating func replaceOrAdd(ing:networking.v1.Ingress) throws {
        let uid = try UUID.fromK8sMetadata(resource: ing as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = ing
                return
            }
        }
        items.append(ing)
    }
}

public extension core.v1.ServiceList {
    mutating func replaceOrAdd(s:core.v1.Service) throws {
        let uid = try UUID.fromK8sMetadata(resource: s as (any KubernetesAPIResource))
        for (i, item) in items.enumerated() {
            let xx_uid = try UUID.fromK8sMetadata(resource: item as (any KubernetesAPIResource))
            if xx_uid == uid {
                items[i] = s
                return
            }
        }
        items.append(s)
    }
}
