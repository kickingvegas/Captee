//
// Copyright © 2023 Charles Choi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension CapteeManager {
    
    private static let templateKey = "template"
    private static let markupFormatKey = "markup_format"
    private static let payloadTypeKey = "payload_type"
    private static let transmitTypeKey = "transmit_type"
    private static let showOnboardingAlertKey = "show_onboarding_alert"
    
    public var persistedShowOnboardingAlert: Bool? {
        get {
            var result: Bool?
            let defaults = UserDefaults.standard
            result = defaults.value(forKey: Self.showOnboardingAlertKey) as? Bool
            return result
        }
        
        set(newValue) {
            let defaults = UserDefaults.standard
            if let newValue = newValue {
                defaults.setValue(newValue, forKey: Self.showOnboardingAlertKey)
            } else {
                defaults.removeObject(forKey: Self.showOnboardingAlertKey)
            }
        }
    }
    
    public var persistedTemplateKey: String? {
        get {
            var result: String?
            let defaults = UserDefaults.standard
            result = defaults.value(forKey: Self.templateKey) as? String
            return result
        }
        
        set(newValue) {
            let defaults = UserDefaults.standard
            if let newValue = newValue {
                defaults.setValue(newValue, forKey: Self.templateKey)
            } else {
                defaults.removeObject(forKey: Self.templateKey)
            }
        }
    }
    
    
    public var persistedMarkupFormat: MarkupFormat? {
        get {
            var result: MarkupFormat?
            let defaults = UserDefaults.standard
            if let persistedValue = defaults.value(forKey: Self.markupFormatKey) as? String {
                result = MarkupFormat(rawValue: persistedValue)
            }
            return result
        }
        
        set(newValue) {
            let defaults = UserDefaults.standard

            if let newValue = newValue {
                defaults.setValue(newValue.rawValue, forKey: Self.markupFormatKey)
            } else {
                defaults.removeObject(forKey: Self.markupFormatKey)
            }
        }
        
    }

    public var persistedPayloadType: PayloadType? {
        get {
            var result: PayloadType?
            let defaults = UserDefaults.standard
            if let persistedValue = defaults.value(forKey: Self.payloadTypeKey) as? String {
                result = PayloadType(rawValue: persistedValue)
            }
            return result
        }
        
        set(newValue) {
            let defaults = UserDefaults.standard

            if let newValue = newValue {
                defaults.setValue(newValue.rawValue, forKey: Self.payloadTypeKey)
            } else {
                defaults.removeObject(forKey: Self.payloadTypeKey)
            }
        }
    }


    public var persistedTransmitType: TransmitType? {
        get {
            var result: TransmitType?
            let defaults = UserDefaults.standard
            if let persistedValue = defaults.value(forKey: Self.transmitTypeKey) as? String {
                result = TransmitType(rawValue: persistedValue)
            }
            return result
        }
        
        set(newValue) {
            let defaults = UserDefaults.standard

            if let newValue = newValue {
                defaults.setValue(newValue.rawValue, forKey: Self.transmitTypeKey)
            } else {
                defaults.removeObject(forKey: Self.transmitTypeKey)
            }
        }
    }
}

