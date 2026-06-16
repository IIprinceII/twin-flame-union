// Flattens a PNG's alpha channel by compositing onto opaque black and re-encoding
// with no alpha. Dependency-free (CoreGraphics/ImageIO). Usage: swift flatten-icon-alpha.swift <in> <out>
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 3 else { fputs("usage: flatten <in> <out>\n", stderr); exit(2) }
let inURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let src = CGImageSourceCreateWithURL(inURL as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fputs("cannot read\n", stderr); exit(1) }
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fputs("ctx fail\n", stderr); exit(1) }
ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
guard let flat = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else { fputs("write fail\n", stderr); exit(1) }
CGImageDestinationAddImage(dest, flat, nil)
CGImageDestinationFinalize(dest)
