//
//  GIFView.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//

import SwiftUI
import AppKit
import ImageIO

struct GIFView: NSViewRepresentable {
    let gifName: String

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageFrameStyle = .none
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.clear.cgColor
        
        loadGif(imageView: imageView, name: gifName)
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        // GIF名が変更された場合のみ再読み込み
        if let currentGif = context.coordinator.currentGifName, currentGif != gifName {
            loadGif(imageView: nsView, name: gifName)
            context.coordinator.currentGifName = gifName
        }
    }
    
    private func loadGif(imageView: NSImageView, name: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // ResourcesフォルダからGIFファイルを読み込み
            guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("GIF named \(name) not found in Resources folder")
                DispatchQueue.main.async {
                    // GIFが見つからない場合はデフォルト画像を表示
                    imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                }
                return
            }
            
            guard let imageData = try? Data(contentsOf: bundleURL) else {
                print("Cannot turn GIF named \(name) into data")
                DispatchQueue.main.async {
                    imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                }
                return
            }
            
            DispatchQueue.main.async {
                if let animatedImage = NSImage.animatedImageWithGIFData(imageData) {
                    imageView.image = animatedImage
                } else {
                    // GIFの読み込みに失敗した場合はデフォルト画像を表示
                    imageView.image = NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var currentGifName: String?
    }
}

extension NSImageView {
    func loadGif(name: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // ResourcesフォルダからGIFファイルを読み込み
            guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("GIF named \(name) not found in Resources folder")
                return
            }
            guard let imageData = try? Data(contentsOf: bundleURL) else {
                print("Cannot turn GIF named \(name) into data")
                return
            }
            DispatchQueue.main.async {
                self.image = NSImage.animatedImageWithGIFData(imageData) ?? NSImage(named: "main") ?? NSImage(named: "NSApplicationIcon")
            }
        }
    }
}

extension NSImage {
    static func animatedImageWithGIFData(_ data: Data) -> NSImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }
        
        // 最初のフレームを取得
        if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            
            // アニメーション情報を設定（簡易版）
            if count > 1 {
                // 複数フレームがある場合は、最初のフレームを表示
                // 完全なGIFアニメーション実装は別途必要
                print("GIF has \(count) frames, showing first frame")
            }
            
            return nsImage
        }
        
        return nil
    }

    static func frameDurationAtIndex(_ index: Int, source: CGImageSource) -> Double {
        var frameDuration = 0.1
        let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        if let frameProperties = cfFrameProperties as? [String: Any],
           let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
            if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
                frameDuration = delayTime
            } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                frameDuration = delayTime
            }
        }
        return frameDuration
    }
}

