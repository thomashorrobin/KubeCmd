//
//  Secret.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 28/07/2021.
//

import SwiftUI
import SwiftkubeModel

struct Secret: View {
	let secret:core.v1.Secret
	var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content:{
			if secret.metadata != nil {
				MetaDataSection(resource: secret)
				Divider().padding(.vertical, 30)
			}
			if let data = secret.data {
				KeyValueDetailPanel(data: data)
			} else {
				Text("No data")
			}
		})
	}
}
