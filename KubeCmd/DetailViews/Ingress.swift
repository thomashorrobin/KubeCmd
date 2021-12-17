//
//  Ingress.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/12/2021.
//

import SwiftUI
import SwiftkubeModel

struct Ingress: View {
	var ingress:networking.v1.Ingress
    var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if let metadata = ingress.metadata {
				MetaDataSection(metadata: metadata)
			}
		})
    }
}
