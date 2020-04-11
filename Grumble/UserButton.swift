//
//  UserButton.swift
//  Grumble
//
//  Created by Allen Chang on 3/30/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct UserButton: View {
    private var action: () -> Void
    private var disabled: Bool
    private var text: String
    private var fgEmpty: Color = Color.white.opacity(0.4)
    private var fgFull: Color = Color.white
    private var bgEmpty: Color = Color.clear
    private var bgFull: Color = gColor(.blue4).opacity(0.4)
    private var padding: CGFloat = 15
    
    //Initializer
    public init(action: @escaping () -> Void, disabled: Bool, text: String, fgEmpty: Color = Color.white.opacity(0.4), fgFull: Color = Color.white, bgEmpty: Color = Color.clear, bgFull: Color = gColor(.blue4).opacity(0.4), padding: CGFloat = 15) {
        self.action = action
        self.disabled = disabled
        self.text = text
        self.fgEmpty = fgEmpty
        self.fgFull = fgFull
        self.bgEmpty = bgEmpty
        self.bgFull = bgFull
        self.padding = padding
    }
    
    public var body: some View {
        ZStack {
            Button(action: self.action, label: {
                Text(self.text)
                    .padding(self.padding)
                    .frame(width: sWidth() * 0.85)
                    .font(gFont(.ubuntuMedium, .width, 2.5))
                    .animation(.easeInOut)
            }).disabled(self.disabled)
            .background(self.disabled ? self.bgEmpty : self.bgFull)
            .foregroundColor(self.disabled ? self.fgEmpty : self.fgFull)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(self.disabled ? self.fgEmpty : self.fgFull, lineWidth: 2))
            .cornerRadius(8)
        }
    }
}