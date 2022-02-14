//
//  Ingress.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 17/12/2021.
//

import SwiftUI
import SwiftkubeModel

struct usableRule:Codable {
	var id:UUID
	var host:String
	var path:String?
	var service:String?
	var port:String?
	init(host:String) {
		self.id = UUID()
		self.host = host
	}
}

struct Ingress: View {
	var ingress:networking.v1.Ingress
	var usableRules:[usableRule] = [usableRule]()
	init(i: networking.v1.Ingress) {
		self.ingress = i
		if let rules = i.spec?.rules {
			for rule in rules {
				guard let host = rule.host else { continue }
				var ur = usableRule(host: host)
				if let paths = rule.http?.paths {
					for pathObject in paths {
						if let path = pathObject.path {
							ur.path = path
						}
						if let port = pathObject.backend.service?.port?.name {
							ur.port = port
						}
						if let serviceName = pathObject.backend.service?.name {
							ur.service = serviceName
						}
					}
				}
				usableRules.append(ur)
			}
		}
	}
    var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(5), content: {
			if ingress.metadata != nil {
				MetaDataSection(resource: ingress)
			}
			if let ingress = ingress.status?.loadBalancer?.ingress {
				Divider().padding(.vertical, 30)
				Text("Load Balancers").font(.title2)
				ForEach(ingress, id: \.ip) { x in
					Text(("ip: \(x.ip ?? "error")"))
				}
			}
			if usableRules.count > 0 {
				Divider().padding(.vertical, 30)
				Text("Rules").font(.title2)
				ForEach(usableRules, id: \.id) { usableRule in
					Text(usableRule.host).font(.title3)
					if let path = usableRule.path {
						Text("path: \(path)")
					}
					if let service = usableRule.service {
						Text("service: \(service)")
					}
					if let port = usableRule.port {
						Text("port: \(port)")
					}
				}
			}
		})
    }
}
