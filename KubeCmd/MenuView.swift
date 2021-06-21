//
//  MenuView.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 21/06/2021.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        HStack {
            TopLevelK8sMenu()
            Divider()
            SecondLevelK8sItems()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
