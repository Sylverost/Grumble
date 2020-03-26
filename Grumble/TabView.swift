//
//  TabView.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct TabView: View {
    @ObservedObject var viewRouter: ViewRouter
    private var geometry: GeometryProxy
    private var contentView: ContentView
    var iconHeight: CGFloat = 25
    
    init(_ viewRouter: ViewRouter, _ geometry: GeometryProxy, _ contentView: ContentView){
        self.viewRouter = viewRouter
        self.geometry = geometry
        self.contentView = contentView
    }
    
    var body: some View {
        HStack{
            if self.viewRouter.currentView == "list" {
                Image(systemName: "bag.fill").resizable().aspectRatio(contentMode: .fit).frame(width: geometry.size.width/2, height: self.iconHeight).contentShape(Rectangle())
                    .onTapGesture{
                        self.toList()
                    }
            } else {
                Image(systemName: "bag").resizable().aspectRatio(contentMode: .fit).frame(width: geometry.size.width/2, height: self.iconHeight).contentShape(Rectangle())
                .onTapGesture{
                    self.toList()
                }
            }
            
            if self.viewRouter.currentView == "settings" {
                Image(systemName: "gear").resizable().aspectRatio(contentMode: .fit).frame(width: geometry.size.width/2, height: self.iconHeight).contentShape(Rectangle())
                    .font(Font.title.weight(.black))
                    .onTapGesture{
                        self.toSettings()
                    }
            } else {
                Image(systemName: "gear").resizable().aspectRatio(contentMode: .fit).frame(width: geometry.size.width/2, height: self.iconHeight).contentShape(Rectangle())
                .font(Font.title.weight(.medium))
                .onTapGesture{
                    self.toSettings()
                }
            }
        }.foregroundColor(Color.black)
            .frame(width: geometry.size.width, height: geometry.size.height * 0.085)
            .background(Color.white.shadow(radius: 3))
            .edgesIgnoringSafeArea(.all)
    }
    
    func toList(){
        self.viewRouter.currentView = "list"
        
        contentView.toList(false)
    }
    
    func toSettings(){
        self.viewRouter.currentView = "settings"
    }
}

#if DEBUG
struct TabView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif