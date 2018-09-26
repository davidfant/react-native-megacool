//
//  UIImagesToVideo.swift
//  RNMegacool
//
//  Created by  on 2018-09-21.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit
import AVFoundation

@objc public class RNMegacoolVideoWriter: NSObject {
    
    // A start to rewrite the messy code below
    // https://stackoverflow.com/questions/40883784/build-video-from-uiimage-using-swift
    
    @objc public static func create(from urls: [URL], frameRate: Int32, callback: @escaping (URL?) -> Void) {
        if urls.isEmpty { return callback(nil) }
        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/video-\(UUID()).mp4")
        
        // get the size of the first image (and assume that all images are that big
        guard let firstImageUrl = urls.first else { NSLog("[RNMegacoolVideoWriter] no first image"); return callback(nil) }
        guard let size = imageSize(from: firstImageUrl) else { NSLog("[RNMegacoolVideoWriter] no image size"); return callback(nil) }
        
        // create asset writer
        guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mp4) else { NSLog("[RNMegacoolVideoWriter] no asset writer"); return callback(nil) }
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height,
        ])
        writer.add(input)
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height,
        ])
        
        guard writer.startWriting() else { NSLog("[RNMegacoolVideoWriter] failed to start writing: \(writer.error)"); return callback(nil) }
        writer.startSession(atSourceTime: kCMTimeZero)
        
        guard pixelBufferAdaptor.pixelBufferPool != nil else { NSLog("[RNMegacoolVideoWriter] no pixel buffer pool"); return callback(nil) }
        let mediaQueue = DispatchQueue(label: "MediaInputQueue")
        
        var index = 0
        input.requestMediaDataWhenReady(on: mediaQueue) {
            while input.isReadyForMoreMediaData && index < urls.count {
                let time = CMTimeMake(Int64(index), frameRate)
                guard input.isReadyForMoreMediaData else { return }
                guard let imageData = try? Data(contentsOf: urls[index]) else { return }
                guard let image = UIImage(data: imageData) else { return }
                
                autoreleasepool {
                    guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else { NSLog("[RNMegacoolVideoWriter] no pixel buffer pool 2"); return }
                    let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                    let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
                    guard status == 0 else { NSLog("[RNMegacoolVideoWriter] invalid status: \(status)"); return }
                    guard let pixelBuffer = pixelBufferPointer.pointee else { NSLog("[RNMegacoolVideoWriter] no pixel buffer"); return }
                    
                    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                    
                    let context = CGContext(
                        data: CVPixelBufferGetBaseAddress(pixelBuffer),
                        width: Int(image.size.width),
                        height: Int(image.size.height),
                        bitsPerComponent: 8,
                        bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                        space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                    )
                    
                    // Draw image into context"
                    context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                    
                    CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
                    
                    let appended = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: time)
                    if !appended { NSLog("[RNMegacoolVideoWriter] failed to append"); return }
                    pixelBufferPointer.deinitialize()
                    pixelBufferPointer.deallocate(capacity: 1)
                }
                
                index += 1
            }
            
            if index >= urls.count {
                input.markAsFinished()
                writer.finishWriting {
                    callback(url)
                }
            }
        }
    }
    
    static func imageSize(from url: URL) -> CGSize? {
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }
        return image.size
    }
}
