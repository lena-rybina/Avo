//
//  ContentView.swift
//  Clubhouse-Icons
//
//  Created by Vlad Z. on 2/21/21.
//

import SwiftUI

enum PhotoAlertType {
    case success
    case failure
    case none
    
    var message: String {
        switch self {
        case .success:
            return "Photo saved"
        case .failure:
            return "Something went wrong, please try again"
        case .none: return ""
        }
    }
}

struct ContentView: View {
    let constImages = 16
    
    @State var originalImage: UIImage? = UIImage(named: "testImage")
    @State var image: UIImage? = UIImage(named: "testImage")
    @State var showImagePicker: Bool = false
    @State var alertMessage = PhotoAlertType.none
    
    @State var selectedColor1 = Color("initialFrameColor")
    @State var selectedColor2: Color? = nil
    
    private var secondColorProxy: Binding<Color> {
        Binding<Color>(get: { selectedColor2 == nil ? selectedColor1 : selectedColor2! },
                       set: { newValue in
                        selectedColor2 = newValue
                       })
    }
    
    @State var frameWidth: Double = 10
    @State var showDetails = false
    
    @State var selectedBorderType: Int = 0
    
    private var showResetProxy: Binding<Bool> {
        Binding<Bool>(get: { selectedBorderType != 0 },
                      set: {  _ in })
    }
    
    private var alertProxy: Binding<Bool> {
        Binding<Bool>(get: { alertMessage != .none },
                      set: {  _ in })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer ()
                
                Text("Change your photo")
                    .font(.custom("Poppins-Regular",
                                  size: 20))
                    .kerning(1.5)
                    .padding(.top,
                             35)
                
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    ColorPicker(
                        "Select Color", selection: $selectedColor1
                    )
                    .frame(width: 60, height: 55, alignment: .center)
                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                    .labelsHidden()
                    
                    
                    if showDetails {
                        ColorPicker(
                            "Create gradient",
                            selection: secondColorProxy
                        )
                        .frame(width: 60, height: 55, alignment: .center)
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .labelsHidden()
                        
                    }
                    
                    
                    Button(action: {
                        showDetails.toggle()
                        
                        if !showDetails {
                            selectedColor2  = nil
                        } else {
                            selectedColor2 = Color("secondaryColor")
                        }
                    }) {
                        Image(systemName: showDetails ?  "xmark.circle.fill" : "plus.circle.fill") .foregroundColor(Color("accentColor"))
                            .font(.system(size: 35))
                        
                    } .padding(.trailing)
                    
                }
                
                profileImage
                
                VStack {
                    Slider(value: $frameWidth, in: 0...60, step: 2)
                        .accentColor(Color("accentColor"))
                        .frame(width: 250,
                               height: 45)
                    
                    ScrollView(.horizontal,
                               showsIndicators: false) {
                        HStack {
                            ForEach(1...constImages-1,
                                    id: \.self) { row in
                                RoundedRectangle(cornerRadius: 155,
                                                 style: .continuous)
                                    .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
                                    .overlay(
                                        ZStack {
                                            Image(uiImage: image!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
                                                .overlay(
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 155)
                                                            .strokeBorder(LinearGradient(gradient: Gradient(colors: tagSelectionColors(tag: row)), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: CGFloat(tagSelectionFrame(tag: row) / 3))
                                                    }
                                                )
                                                .mask(RoundedRectangle(cornerRadius: 155))
                                            
                                            Image("\(row)")
                                                .resizable()
                                                .foregroundColor(.white)
                                        }
                                        .onTapGesture {
                                            if row == selectedBorderType {
                                                selectedBorderType = 0
                                            } else {
                                                selectedBorderType = row
                                            }
                                        }
                                    )
                            }
                        }
                        .transition(.slide)
                    }
                    .padding(.vertical,
                             10)
                    
                    Spacer()
                    
                    Button(action: {
                        guard let _ = image else { return }
                        
                        print(geometry.size.height * 0.95)
                        
                        let size = geometry.size.height * 0.45
                        
                        let saveImage = generateProfileImage(for: size).asImage(size: CGSize(width: size,height: size))
                        
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: saveImage)
                        
                        imageSaver.successHandler = {
                            alertMessage = .success
                        }
                        
                        imageSaver.errorHandler = { _ in
                            alertMessage = .failure
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Save to Library")
                                .foregroundColor(Color.white)
                                .font(.custom("Poppins-Bold",
                                              size: 16))
                                .kerning(1.5)
                            Spacer()
                        }
                        .frame(height: 55)
                    }
                    .disabled(image == nil)
                    .background(Color("buttonColor"))
                    .cornerRadius(20)
                    .padding(.vertical, 20)
                    .frame(width: 250,
                           height: 55)
                    
                    Button(action: {
                        selectedBorderType = 0
                        image = originalImage
                        selectedColor2 = nil
                        showDetails = false
                        frameWidth = 10
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset selection")
                                .foregroundColor(Color.white)
                                .font(.custom("Poppins-Bold",
                                              size: 16))
                                .kerning(1.5)
                            Spacer()
                        }
                        .frame(height: 55)
                    }
                    .background(Color("buttonColor"))
                    .cornerRadius(20)
                    .padding(.vertical, 20)
                    .transition(.slide)
                    .frame(width: 250,
                           height: 60)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: .photoLibrary) { image in
                    self.image = image
                }
            }
            .alert(isPresented: alertProxy,
                   content: {
                    Alert(title: Text(alertMessage.message))
                   })
            
            .background(Color("backgroundColor"))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var profileImage: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()
                    generateProfileImage(for: geometry.size.height * 0.95)
                        .onTapGesture {
                            showImagePicker.toggle()
                        }
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    func generateProfileImage(for size: CGFloat)-> some View {
        Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size,
                   height: size)
            .mask(RoundedRectangle(cornerRadius: 155,
                                   style: .continuous))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 155)
                        .strokeBorder(LinearGradient(gradient: Gradient(colors: [selectedColor1, secondColorProxy.wrappedValue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: CGFloat(frameWidth))
                    
                    if selectedBorderType != 0 {
                        Image("\(selectedBorderType)")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: size,
                                   height: size)
                    }
                }
            )
    }
    
    func tagSelectionColors(tag: Int)-> [Color] {
        tag == selectedBorderType ? [Color.green] : [selectedColor1, secondColorProxy.wrappedValue]
    }
    
    func tagSelectionFrame(tag: Int)-> CGFloat {
        tag == selectedBorderType ? 20.0 : CGFloat(frameWidth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIView {
    func asImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: self.layer.frame.size, format: format).image { context in
            self.drawHierarchy(in: self.layer.bounds, afterScreenUpdates: true)
        }
    }
}


extension View {
    func asImage(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        let image = controller.view.asImage()
        return image
    }
}
