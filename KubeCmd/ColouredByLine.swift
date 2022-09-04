//
//  ColouredByLine.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 04/09/2022.
//

import Foundation
import SwiftUI

struct ColouredByLine: View {
	var byLineText: String
	var byLineColor: Color
	var body: some View {
		Text(byLineText).bold().foregroundColor(byLineColor)
	}
}
