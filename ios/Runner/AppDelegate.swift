import UIKit
import Flutter
import AVFoundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        application.registerForRemoteNotifications()

        GeneratedPluginRegistrant.register(with: self)

        guard let registrar = self.registrar(forPlugin: "NativeAudioConverter") else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(
            name: "native_audio_converter",
            binaryMessenger: registrar.messenger()
        )

        channel.setMethodCallHandler { call, result in
            if call.method == "convertToMp3" {
                guard let args = call.arguments as? [String: Any],
                      let inputPath = args["inputPath"] as? String,
                      let outputPath = args["outputPath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing paths", details: nil))
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let mp3Path = try self.convertToMp3(inputPath: inputPath, outputPath: outputPath)
                        DispatchQueue.main.async {
                            result(mp3Path)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "CONVERSION_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func convertToMp3(inputPath: String, outputPath: String) throws -> String {
        let inputUrl = URL(fileURLWithPath: inputPath)
        let outputUrl = URL(fileURLWithPath: outputPath)

        if FileManager.default.fileExists(atPath: outputPath) {
            try FileManager.default.removeItem(at: outputUrl)
        }

        let audioFile = try AVAudioFile(forReading: inputUrl)
        let inputFormat = audioFile.processingFormat

        guard let pcmFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 44100,
            channels: 2,
            interleaved: false
        ) else {
            throw NSError(domain: "Audio", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid PCM format"])
        }

        guard let converter = AVAudioConverter(from: inputFormat, to: pcmFormat) else {
            throw NSError(domain: "Audio", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to create converter"])
        }

        let inputBuffer = AVAudioPCMBuffer(
            pcmFormat: inputFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        )!

        try audioFile.read(into: inputBuffer)

        let outputCapacity = AVAudioFrameCount(
            Double(inputBuffer.frameLength) * pcmFormat.sampleRate / inputFormat.sampleRate
        ) + 1024

        let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: pcmFormat,
            frameCapacity: outputCapacity
        )!

        var error: NSError?

        converter.convert(to: outputBuffer, error: &error) { _, status in
            status.pointee = .haveData
            return inputBuffer
        }

        if let error = error {
            throw error
        }

        guard let floatData = outputBuffer.floatChannelData else {
            throw NSError(domain: "Audio", code: -3, userInfo: [NSLocalizedDescriptionKey: "No PCM data"])
        }

        let frames = Int(outputBuffer.frameLength)

        var left = [Int16](repeating: 0, count: frames)
        var right = [Int16](repeating: 0, count: frames)

        for i in 0..<frames {
            left[i] = floatToInt16(floatData[0][i])
            right[i] = floatToInt16(floatData[1][i])
        }

        let lame = lame_init()

        lame_set_in_samplerate(lame, 44100)
        lame_set_num_channels(lame, 2)
        lame_set_brate(lame, 64)
        lame_set_quality(lame, 5)
        lame_init_params(lame)

        let mp3BufferSize = Int(1.25 * Double(frames)) + 7200
        var mp3Buffer = [UInt8](repeating: 0, count: mp3BufferSize)

        let encodedSize: Int32 = left.withUnsafeMutableBufferPointer { leftPtr in
            right.withUnsafeMutableBufferPointer { rightPtr in
                mp3Buffer.withUnsafeMutableBufferPointer { mp3Ptr in
                    lame_encode_buffer(
                        lame,
                        leftPtr.baseAddress,
                        rightPtr.baseAddress,
                        Int32(frames),
                        mp3Ptr.baseAddress,
                        Int32(mp3BufferSize)
                    )
                }
            }
        }

        let writtenSize = max(0, Int(encodedSize))

        let flushSize: Int32 = mp3Buffer.withUnsafeMutableBufferPointer { mp3Ptr in
            let flushPointer = mp3Ptr.baseAddress!.advanced(by: writtenSize)

            return lame_encode_flush(
                lame,
                flushPointer,
                Int32(mp3BufferSize - writtenSize)
            )
        }

        lame_close(lame)

        let totalSize = writtenSize + max(0, Int(flushSize))

        if totalSize <= 0 {
            throw NSError(domain: "Audio", code: -4, userInfo: [NSLocalizedDescriptionKey: "MP3 encoding failed"])
        }

        let data = Data(bytes: mp3Buffer, count: totalSize)
        try data.write(to: outputUrl)

        return outputPath
    }

    private func floatToInt16(_ value: Float) -> Int16 {
        let clipped = max(-1.0, min(1.0, value))
        return Int16(clipped * Float(Int16.max))
    }
}