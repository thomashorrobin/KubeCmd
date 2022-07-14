//
//  jobHelpers.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 22/03/2022.
//

import Foundation
import SwiftkubeModel

func manualJobSlug() -> String {
	// We omit vowels from the set of available characters to reduce the chances
	// of "bad words" being formed.
	let alphanums = ["b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","z","2","4","5","6","7","8","9"]
	var seedAlphanum = alphanums.randomElement()!
	var slug = seedAlphanum
	var neededAlphanums = 2
	while neededAlphanums > 0 {
		let nextAlphanum = alphanums.randomElement()!
		if nextAlphanum != seedAlphanum {
			seedAlphanum = nextAlphanum
			slug = slug + nextAlphanum
			neededAlphanums -= 1
		}
	}
	return slug
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
	let x = "\(job.name ?? "terrible-error")-rerun-\(manualJobSlug())"
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
