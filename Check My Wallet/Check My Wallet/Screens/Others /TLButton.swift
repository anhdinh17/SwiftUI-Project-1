//
//  TLButton.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/13/23.
//

import SwiftUI

struct TLButton: View {
    
    let title: String
    let background: Color
    // what happens when click on button
    let action: () -> Void
    
    var body: some View {
        Button{
            // Closure
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
    }
}

struct TLButton_Previews: PreviewProvider {
    static var previews: some View {
        TLButton(title: "Title", background: .blue) {
            // Action
        }
    }
}

