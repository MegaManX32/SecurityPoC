//
//  ContentBlockerRequestHandler.swift
//  SafariContentBlocker
//
//  Created by Vladislav Simovic on 24.12.24..
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    
    private enum ContentBlockerError: String, Error {
        case couldNotCreateNSItemWithUrl
        case sharedContainerNotFound
        case blockerFileNotFound
    }
    
    func beginRequest(with context: NSExtensionContext) {
        do {
            let url = try blockedListURL()
            let item = try Self.extensionItemProvider(from: url)
            context.completeRequest(returningItems: [item], completionHandler: nil)
        } catch {
            Logger.shared.log(message: error.localizedDescription, level: .error)
            context.completeRequest(returningItems: nil)
        }
    }
    
    private func blockedListURL() throws -> URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PhishingKeys.suiteName)
        guard let container else { throw ContentBlockerError.sharedContainerNotFound }
        
        let blockerPath = container.appendingPathComponent(PhishingKeys.contentBlockerPath)
        if FileManager.default.fileExists(atPath: blockerPath.path) {
            return blockerPath
        } else {
            throw ContentBlockerError.blockerFileNotFound
        }
    }
    
    private static func extensionItemProvider(from url: URL) throws -> NSExtensionItem {
        guard let attachment = NSItemProvider(contentsOf: url) else {
            throw ContentBlockerError.couldNotCreateNSItemWithUrl
        }
        Logger.shared.log(message: "Loaded blocked list with attachment: \(attachment)")
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        return item
    }
}
