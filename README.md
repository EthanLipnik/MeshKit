# MeshKit

A powerful and easy to use live mesh gradient renderer for iOS.

**This project wouldn't be possible without the awesome work from [Moving Parts](https://movingparts.io/gradient-meshes) and their [Swift Playground](https://github.com/movingparts-io/Gradient-Meshes-with-SceneKit)**

## What is MeshKit?

MeshKit is an easy to use live mesh gradient renderer for iOS. In just a few lines of code, you can create a mesh gradient.

## Usage

You can use the `MeshView` to render the view. This basically contains a SCNView with some extra magic.

##### To generate a mesh with the MeshView, you call the create method after initializing it.

```swift
let meshView = MeshView()
view.addSubview(meshView)

meshView.create([
                .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
                .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
                .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
                
                .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 1), location: (Float.random(in: 0.3...1.8), Float.random(in: 0.3...1.5)), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
                
                .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
                .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
                .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
            ])
```

This can be called as many times as you want if you ever want to change the gradient.

The `MeshView.create` method needs a `MeshNode.Color` array. These are simple ways to interface with the points on the mesh gradient.

##### The `Color` struct has 3 parts. `point`, `location`, and `color`.

`point` – Where the color should exist on the gradient. This is different from `location` as this is meant for where on the square it should exist. For example, `0, 0` is one of the corners. No interpolation is involved here.

*No two colors should have the same point.*

`location` – Two floats on the x and y axis that will move the color and interpolate it's neighboring colors. What this basically means is where you actually want the color to go on the gradient.

*Don't change the location for the edges of the gradient or it will have a weird shape.*

`color` – A UIColor for the point. Be sure to choose colors that will interpolate with each other well.

*Alphas are not used and will be ignored.*

##### You can also set the `width` and `height` when creating the mesh.

For simplicity, the width and height should be the same. By default both are set to `3`. If you increase/decrease it, then you will need to supply the width/height **squared**. So if you set it to `2` then you will need to give it `4` colors. It would look like this

```swift
meshView.create([
                .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
                .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
                
                .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 1), location: (Float.random(in: 0.3...1.8), Float.random(in: 0.3...1.5)), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
]
```

If you set it to `4` then you would need to give it `16` colors and so on.

##### As well as setting the width and height, you can also change the subdivisions.

This is the easiest setting to change. It changes the "resolution" of the wireframe. By default it is set to `18`. Raising it will exponentially decrease performance.

## Plans

* More shape options
* Easier methods to animate location changes
* Color generating
* Display P3 and other color profiles rendering/exporting
* HDR support
* More efficient rendering (Metal?)
* macOS support
* XCTests

## Acknowledgments

* [Moving Parts](https://movingparts.io/gradient-meshes)
