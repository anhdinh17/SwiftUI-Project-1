//
//  StandardButton.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/26/23.
//

import SwiftUI

struct StandardButton: View {
    
    var title: String
    var backgroundColor: Color
    var buttonAction: () -> Void

    var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 40)
        .background(backgroundColor)
        .cornerRadius(5)
        .padding()
    }
}

struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardButton(title: "Sign Out", backgroundColor: .red) {
            
        }
    }
}
