//
//  SwiftUIView.swift
//  
//
//  Created by Ethan Lipnik on 8/28/22.
//

import SwiftUI

struct GrabberView: View {
    @Binding var grid: MeshColorGrid
    @Binding var selectedPoint: MeshColor?
    
    var updateGrid: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<grid.width, id: \.self) { x in
                    ForEach(0..<grid.height, id: \.self) { y in
                        let offset = (grid.height - 1)
                        let isEdge = grid.isEdge(x: x, y: y)
                        
                        let xOffset = Self.getOffset(grid.width, 
                                                     sizeWidth: Int(proxy.size.width), 
                                                     point: CGFloat(x))
                        let yOffset = Self.getOffset(grid.height,
                                                     sizeWidth: Int(proxy.size.height), 
                                                     point: CGFloat(y))
                        
                        PointView(
                            point: $grid[x, offset - y], 
                            grid: $grid, 
                            selectedPoint: $selectedPoint,
                            proxy: proxy, 
                            isEdge: isEdge
                        ) { _ in
                            updateGrid()
                        }
                        .offset(
                            x: xOffset - (x + 1 == grid.width ? 30 : 0) + (x == 0 ? 30 : -30),
                            y: yOffset - (y + 1 == grid.height ? 30 : 0) + (y == 0 ? 30 : -30)
                        )
                    }
                }
            }
        }
    }
    
    // (viewWidth*point) / (gridWidth - 1)
    private static func getOffset(_ width: Int, sizeWidth: Int, point: CGFloat) -> CGFloat {
        return (CGFloat(sizeWidth) * point) / CGFloat(width - 1)
    }
    
    struct PointView: View {
        @Binding var point: MeshColor
        @Binding var grid: MeshColorGrid
        @Binding var selectedPoint: MeshColor?
        let proxy: GeometryProxy
        let isEdge: Bool
        var didMove: (_ translation: CGSize) -> Void
        
        @State private var isShowingOptions: Bool = false
        @State private var selectedColor: CGColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        
        @State private var offset: CGSize = .zero
        
        var body: some View {
            Circle()
                .fill(selectedPoint == point ? Color.white : Color.black.opacity(0.2))
                .scaleEffect(selectedPoint == point ? 1.1 : 1)
                .scaleEffect(isEdge ? 0.5 : 1)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 8)
                .offset(offset)
                .animation(.interactiveSpring(), value: offset)
                .animation(.easeInOut, value: selectedPoint)
                .frame(maxWidth: 35, maxHeight: 35)
                .popover(isPresented: $isShowingOptions) {
                    optionsView
                }
                .onTapGesture {
                    selectedPoint = point
                    isShowingOptions.toggle()
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            selectedPoint = point
                            
                            guard !isEdge else { return }
                            
                            let location = value.location
                            var width = location.x / (proxy.size.width / 2)
                            var height = location.y / (proxy.size.height / 2)
                            
                            width = min(0.8, max(-0.8, width))
                            height = min(0.8, max(-0.8, height))
                            
                            let meshPoint = MeshPoint(x: Float(width) + point.startLocation.x, 
                                                      y: -Float(height) + point.startLocation.y)
                            point.location = meshPoint
                            
                            updateOffset(location: location)
                            
                            didMove(CGSize(width: width, height: 1 - height))
                        })
                )
                .onAppear {
                    selectedColor = point.color.cgColor
                }
                .onChange(of: point.color) { newValue in
                    selectedColor = newValue.cgColor
                }
        }
        
        var optionsView: some View {
            VStack {
                ColorPicker(selection: $selectedColor, supportsOpacity: false) { 
                    Text("Color")
                }
                .onChange(of: selectedColor) { newValue in
                    #if os(macOS)
                    point.color = SystemColor(cgColor: newValue) ?? point.color
                    #else
                    point.color = SystemColor(cgColor: newValue)
                    #endif
                    didMove(CGSize(width: CGFloat.random(in: 0..<500), height: CGFloat.random(in: 0..<500)))
                }
            }
            .padding()
        }
        
        func updateOffset(location: CGPoint) {
            guard !isEdge else { return }
            
            let offsetWidth = -proxy.size.width / CGFloat(grid.width)
            let offsetX = min(abs(offsetWidth), max(offsetWidth, location.x))
            
            let offsetHeight = -proxy.size.height / CGFloat(grid.height)
            let offsetY = min(abs(offsetHeight), max(offsetHeight, location.y))
            offset = CGSize(width: offsetX, height: offsetY)
        }
    }
}
