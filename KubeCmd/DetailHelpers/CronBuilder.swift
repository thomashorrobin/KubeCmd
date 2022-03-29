//
//  CronBuilder.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 29/03/2022.
//

import SwiftUI

struct CronBuilder: View {
    var body: some View {
		TabView {
			Text("Tab 1")
				.tabItem {
					Text("Minutes")
				}

			Text("Tab 2")
				.tabItem {
					Text("Hourly")
				}
			
			Text("Tab 2")
				.tabItem {
					Text("Daily")
				}
			
			Text("Tab 2")
				.tabItem {
					Text("Weekly")
				}
			
			Text("Tab 2")
				.tabItem {
					Text("Monthly")
				}
			
			Text("Tab 2")
				.tabItem {
					Text("Yearly")
				}
		}
    }
}

struct CronBuilder_Previews: PreviewProvider {
    static var previews: some View {
        CronBuilder()
    }
}
