//
//  jobHelpers.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 22/03/2022.
//

import Foundation
import SwiftkubeModel

func createJobFromCronJob(cronJob:batch.v1.CronJob) -> batch.v1.Job {
	let tmp = cronJob.spec?.jobTemplate.spec
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
	let dateStr = dateFormatter.string(from: Date())
	let x = "\(cronJob.name ?? "terrible-error")-manual-\(dateStr)"
	var existingMetadata = cronJob.metadata
	existingMetadata?.name = x
	var job = batch.v1.Job()
	existingMetadata?.resourceVersion = nil
	job.spec = tmp
	job.metadata = existingMetadata
	return job
}

enum createJobFromJobErrors : Error {
	case jobSpecDoesntExist
	case jobMetadataDoesntExist
}

func createJobFromJob(job:batch.v1.Job) throws -> batch.v1.Job {
	guard var tmp = job.spec else { throw createJobFromJobErrors.jobSpecDoesntExist }
	guard var existingMetadata = job.metadata else { throw createJobFromJobErrors.jobMetadataDoesntExist }
	if var templateMetadate = tmp.template.metadata {
		templateMetadate.labels = [String:String]()
		tmp.selector = nil
		tmp.template.metadata = templateMetadate
	}
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "HHmmss-SSS"
	let dateStr = dateFormatter.string(from: Date())
	let x = "\(job.name ?? "terrible-error")-rerun-\(dateStr)"
	existingMetadata.name = x
	existingMetadata.labels = [String:String]()
	existingMetadata.managedFields = nil
	existingMetadata.creationTimestamp = nil
	existingMetadata.uid = nil
	existingMetadata.ownerReferences = nil
	existingMetadata.resourceVersion = nil
	var job = batch.v1.Job()
	job.spec = tmp
	job.metadata = existingMetadata
	return job
}
