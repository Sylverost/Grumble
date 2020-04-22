//
//  GrubSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let baseImageFraction: CGFloat = 0.35
private let dragFraction: CGFloat = 0.5
private let safeImagePadding: CGFloat = 10

private let headerHeight: CGFloat = sWidth() * 0.23
private let grubContentPadding: CGFloat = 20
private let editHeight: CGFloat = 40
private let restaurantHeight: CGFloat = 150
private let addressHeight: CGFloat = 220
private let tagBuilderHeight: CGFloat = 25
private let tagBuilderPadding: CGFloat = 10
private let deleteHeight: CGFloat = 40

public struct GrubSheet: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var selectedFID: Binding<String?>
    private var grub: Grub?
    private var show: Binding<Bool>
    @State private var superOffset: CGFloat = 0
    @State private var imageFraction: CGFloat = baseImageFraction
    @State private var currentImageFraction: CGFloat = baseImageFraction
    @State private var offsetGrubContent: CGFloat = 0
    @State private var currentOffsetGrubContent: CGFloat = 0
    @State private var impactOccurred: Bool = false
    @State private var alertDelete: Bool = false
    private var contentView: ContentView
    private var onHide: Binding<() -> Void>
    
    //Initializer
    public init(_ selectedFID: Binding<String?>, _ show: Binding<Bool>, _ contentView: ContentView, onHide: Binding<() -> Void>) {
        self.selectedFID = selectedFID
        switch selectedFID.wrappedValue {
        case nil:
            self.grub = nil
        default:
            self.grub = UserCookie.uc().foodList()[selectedFID.wrappedValue!]
        }
        self.show = show
        self.contentView = contentView
        self.onHide = onHide
    }
    
    //for testing purposes only
    @available(*, deprecated)
    fileprivate init(_ grub: Grub) {
        self.selectedFID = Binding.constant("")
        self.grub = grub
        self.show = Binding.constant(true)
        self.contentView = ContentView()
        self.onHide = Binding.constant({})
    }
    
    //Function Methods
    private func hideSheet() {
        withAnimation(gAnim(.easeInOut)) {
            self.superOffset = 0
            self.show.wrappedValue = false
        }
        self.onHide.wrappedValue()
    }
    
    private func grubContentHeight() -> CGFloat {
        var height = editHeight + grubContentPadding
        
        if self.grub!.restaurant != nil {
            height += restaurantHeight + grubContentPadding
        }
        if self.grub!.address != nil {
            height += addressHeight + grubContentPadding
        }
        
        let tagLines = ceil(Double(self.grub!.tags.count - 1) / 3.0)
        height += (tagBuilderHeight + tagBuilderPadding) * CGFloat(tagLines) - tagBuilderPadding + grubContentPadding
        height += deleteHeight
        
        return height
    }
    
    private var header: some View {
        HStack(alignment: .bottom, spacing: nil) {
            VStack(alignment: .leading, spacing: nil) {
                Text("Food")
                    .font(gFont(.ubuntuLight, .width, 2))
                
                Text(self.grub!.food)
            }
            
            Spacer()
            
            if self.grub!.price != nil {
                VStack(spacing: nil) {
                    Text("Price")
                    .font(gFont(.ubuntuLight, .width, 2))
                    
                    Text("$" + String(format:"%.2f", self.grub!.price!))
                }
            }
        }.padding(.top, safeAreaInset(.top))
        .padding(10)
    }
    
    private var editButton: some View {
        var tags = self.grub!.tags
        tags["smallestTag"] = nil
        
        return Button(action: {
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.food.rawValue, self.grub!.food)
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.price.rawValue, self.grub!.price == nil ? "" : "$" + String(format:"%.2f", self.grub!.price!))
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.restaurant.rawValue, self.grub!.restaurant ?? "")
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.address.rawValue, self.grub!.address ?? "")
            var tagBoxes: [AddFood.TagBox] = []
            for tag in tags.values.sorted() {
                tagBoxes.append(AddFood.TagBox(capFirst(tagTitles[tag]), id: tag))
            }
            TagBoxHolder.tbh().setTagBoxes(tagBoxes)
            
            self.contentView.toAddFood(self.selectedFID.wrappedValue!)
        }, label: {
            Text("Edit Grub")
                .frame(maxWidth: .infinity)
                .padding(10)
        })
    }
    
    private var restaurantInfo: some View {
        HStack(alignment: .top, spacing: nil) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Restaurant")
                        .font(gFont(.ubuntuLight, .width, 1.5))
                    Text(self.grub!.restaurant!)
                        .font(gFont(.ubuntuBold, .width, 2))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Phone Number")
                        .font(gFont(.ubuntuLight, .width, 1.5))
                    Text("+1 (XXX) XXX-XXXX")
                        .font(gFont(.ubuntuBold, .width, 2))
                }
            }
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Call")
                    .font(gFont(.ubuntuLight, .width, 2))
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gColor(.blue4))
                        .frame(width: 70, height: 70)
                        .shadow(color: gColor(.blue4).opacity(0.1), radius: 5, y: 10)
                    
                    Image(systemName: "phone")
                        .font(.system(size: 50))
                }.foregroundColor(Color.white)
            }
        }
    }
    
    private var addressInfo: some View {
        HStack(alignment: .top, spacing: nil) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Address")
                    .font(gFont(.ubuntuLight, .width, 1.5))
                Text(self.grub!.address!)
                    .font(gFont(.ubuntuBold, .width, 2))
                    .lineLimit(5)
            }
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Map")
                    .font(gFont(.ubuntuLight, .width, 2))
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gColor(.blue0))
                        .frame(width: 150, height: 150)
                        .shadow(color: gColor(.blue0).opacity(0.1), radius: 5, y: 10)
                    
                    Image(systemName: "map")
                        .font(.system(size: 50))
                }.foregroundColor(Color.white)
            }
        }
    }
    
    private var tagBuilder: some View {
        var tags = self.grub!.tags
        tags["smallestTag"] = nil
        let tagIDs = tags.values.sorted()
        
        return VStack(alignment: .center, spacing: tagBuilderPadding) {
            ForEach(0 ... tagIDs.count / 3, id: \.self) { line in
                HStack(spacing: tagBuilderPadding) {
                    ForEach(line * 3 ..< min((line + 1) * 3, tagIDs.count), id: \.self) { index in
                            Text(tagTitles[tagIDs[index]])
                            .padding([.leading, .trailing], 15)
                            .padding(5)
                            .frame(height: tagBuilderHeight)
                            .background(Color.white)
                            .font(gFont(.ubuntuMedium, .width, 2))
                            .foregroundColor(tagColors[tagIDs[index]])
                            .cornerRadius(20)
                    }
                }
            }
        }.frame(maxWidth: .infinity)
    }
    
    private var grubContent: some View {
        VStack(alignment: .leading, spacing: grubContentPadding) {
            self.editButton
                .frame(height: editHeight)
                .background(Color.white)
                .foregroundColor(tagColors[self.grub!.tags["smallestTag"]!])
                .font(gFont(.ubuntuMedium, .width, 2.5))
                .cornerRadius(10)
            
            if self.grub!.restaurant != nil {
                self.restaurantInfo
                    .padding(20)
                    .frame(height: restaurantHeight)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            if self.grub!.address != nil {
                self.addressInfo
                    .padding(20)
                    .frame(height: addressHeight)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            self.tagBuilder
            
            Button(action: { self.alertDelete.toggle() }, label: {
                Text("Delete")
                .padding(10)
                .frame(height: deleteHeight)
                .background(Color.white)
                .cornerRadius(8)
                .font(gFont(.ubuntuBold, .width, 2))
                .foregroundColor(gColor(.coral))
            }).alert(isPresented: self.$alertDelete) {
                Alert(title: Text("Delete Grub?"), primaryButton: Alert.Button.default(Text("Cancel")), secondaryButton: Alert.Button.destructive(Text("Delete")) {
                    Grub.removeFood(self.selectedFID.wrappedValue!)
                })
            }
        }.padding([.leading, .trailing], 20)
        .foregroundColor(Color(white: 0.2))
        .offset(y: self.offsetGrubContent)
    }
    
    private var sheet: some View {
        var tags = self.grub!.tags
        let smallestTag = tags["smallestTag"]!
        tags["smallestTag"] = nil
        
        return ZStack(alignment: .topTrailing) {
            ZStack {
                Image(tagBGs[smallestTag])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: sWidth() + safeImagePadding * 2, height: sHeight() * self.imageFraction + safeAreaInset(.top) + safeImagePadding * 2)
                    .offset(y: -safeAreaInset(.top))
            }.frame(width: sWidth())
            
            if smallestTag != 0 {
                LinearGradient(gradient: Gradient(colors: [Color.clear, tagColors[smallestTag]]), startPoint: .top, endPoint: .bottom)
            }
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(DragGesture().onChanged { drag in
                    withAnimation(gAnim(.spring)) {
                        self.imageFraction = max(drag.translation.height, 0) / sHeight() * dragFraction + baseImageFraction
                    }
                    if !self.impactOccurred && drag.translation.height > sHeight() * 0.4 {
                        self.impactOccurred = true
                        
                        let impactLight = UIImpactFeedbackGenerator(style: .light)
                        impactLight.impactOccurred()
                    } else if drag.translation.height < sHeight() * 0.4 {
                        self.impactOccurred = false
                    }
                }.onEnded { drag in
                    if drag.translation.height > sHeight() * 0.4 {
                        self.hideSheet()
                    }
                    withAnimation(gAnim(.spring)) {
                        self.imageFraction = baseImageFraction
                    }
                })
            
            Button(action: self.hideSheet, label: {
                Image(systemName: "chevron.down.circle.fill")
                    .padding(20)
                    .foregroundColor(Color.white.opacity(0.5))
                    .font(.system(size: 30))
            })
            
            ZStack(alignment: .topLeading) {
                Color(white: 0.95)
                
                VStack(spacing: 20) {
                    Spacer().frame(height: headerHeight)
                    
                    self.grubContent
                }.shadow(color: Color.black.opacity(0.1), radius: 3)
                
                self.header
                    .font(gFont(.ubuntuMedium, .width, 3.5))
                    .padding([.leading, .trailing], 10)
                    .frame(height: headerHeight)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
            }.frame(height: sHeight() * (1 - self.imageFraction) + safeImagePadding, alignment: .top)
            .foregroundColor(Color.black)
            .offset(y: sHeight() * self.imageFraction + safeAreaInset(.top))
        }.frame(width: sWidth(), height: sHeight() - safeAreaInset(.top))
        .gesture(DragGesture().onChanged { drag in
            withAnimation(gAnim(.easeOut)) {
                if self.offsetGrubContent == 0 {
                    self.imageFraction = max(min(drag.translation.height / sHeight() + self.currentOffsetGrubContent / sHeight() + self.currentImageFraction, baseImageFraction), -safeAreaInset(.top) / sHeight())
                }
                
                if self.imageFraction == -safeAreaInset(.top) / sHeight() {
                    let attemptedOffset = min(drag.translation.height + self.currentImageFraction * sHeight() + safeAreaInset(.top) + self.currentOffsetGrubContent, 0)
                    self.offsetGrubContent = max(attemptedOffset, min(sHeight() * ( 1 - baseImageFraction) + headerHeight - self.grubContentHeight(), 0))
                }
            }
        }.onEnded { drag in
            self.currentImageFraction = self.imageFraction
            self.currentOffsetGrubContent = self.offsetGrubContent
        }).offset(y: self.show.wrappedValue ? self.superOffset : sHeight() * 1.2)
    }
    
    public var body: some View {
        if self.grub != nil {
            return AnyView(self.sheet)
        } else {
            return AnyView(Color.clear)
        }
    }
}

struct GrubSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrubSheet(Grub.testGrub())
    }
}
