# MeshKit

A powerful and easy to use live mesh gradient renderer for iOS.

**This project wouldn't be possible without the awesome work from [Nikita's Mesh Gradient Library](https://github.com/Nekitosss/MeshGradient)**

## What is MeshKit?

MeshKit is an easy to use live mesh gradient renderer for iOS, macOS, tvOS, and visionOS. In just a few lines of code, you can create a mesh gradient.

## Usage

You can use the `Mesh` to render the SwiftUI view.
Mesh comes with all the essentials from MeshGradient but MeshKit adds some improvements to make it easier to use.

##### Generate a color palette mesh
```swift
Mesh(colors: MeshKit.generate(palette: [.blue, .green]))
```

## Known Issues
- The mesh crashes in SwiftUI previews.

## Acknowledgments

* [MeshGradient](https://github.com/Nekitosss/MeshGradient)
