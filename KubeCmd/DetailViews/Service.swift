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
			if let metadata = service.metadata {
				MetaDataSection(metadata: metadata)
			}
		})
    }
}
