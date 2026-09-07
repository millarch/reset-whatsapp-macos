import Foundation

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: build-icon.swift <iconset> <output.icns>\n", stderr)
    exit(EXIT_FAILURE)
}

let iconsetURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let representations = [
    ("icp4", "icon_16x16.png"),
    ("ic11", "icon_16x16@2x.png"),
    ("icp5", "icon_32x32.png"),
    ("ic12", "icon_32x32@2x.png"),
    ("icp6", "icon_32x32@2x.png"),
    ("ic07", "icon_128x128.png"),
    ("ic13", "icon_128x128@2x.png"),
    ("ic08", "icon_256x256.png"),
    ("ic14", "icon_256x256@2x.png"),
    ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png")
]

func bigEndianData(_ value: UInt32) -> Data {
    var number = value.bigEndian
    return Data(bytes: &number, count: MemoryLayout<UInt32>.size)
}

do {
    var body = Data()
    for (type, filename) in representations {
        let imageData = try Data(contentsOf: iconsetURL.appendingPathComponent(filename))
        guard let typeData = type.data(using: .ascii), typeData.count == 4 else {
            throw CocoaError(.fileWriteUnknown)
        }
        body.append(typeData)
        body.append(bigEndianData(UInt32(imageData.count + 8)))
        body.append(imageData)
    }

    var icns = Data("icns".utf8)
    icns.append(bigEndianData(UInt32(body.count + 8)))
    icns.append(body)
    try icns.write(to: outputURL, options: .atomic)
} catch {
    fputs("Could not create ICNS: \(error.localizedDescription)\n", stderr)
    exit(EXIT_FAILURE)
}
