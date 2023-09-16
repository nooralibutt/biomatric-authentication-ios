//
//  ViewController.swift
//  BioAuth
//
//  Created by Noor on 9/16/23.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    let context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.localizedCancelTitle = "End Session"
        context.localizedFallbackTitle = "Use passcode"
        context.localizedReason = "We need this in order to successfull log you in"
        context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
        
        evaluatePolicy()
    }

    private func evaluatePolicy() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            switch context.biometryType {
            case .faceID:
                print("face id")
            case .touchID:
                print("Touch id")
            case .none:
                print("none")
            default:
                print("Unknown")
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Fall Back Reason") { success, error in
                print(success)
                if let error = error {
                    let errCode = LAError(_nsError: error as NSError)
                    
                    switch errCode.code {
                    case .userCancel:
                        print("User cancelled")
                    case .appCancel:
                        print("App Cancelled it")
                    case .authenticationFailed:
                        print("failed")
                    case .userFallback:
                        print("Fallback")
                        self.promptForUserCode()
                    default:
                        print("Unknown error")
                    }
                }
            }
            
//            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
//                self.context.invalidate()
//            }
        } else {
            print("cant evalue policy with error \(error?.localizedDescription ?? "error")")
            
            if let error = error {
                let errCode = LAError(_nsError: error as NSError)
                
                switch errCode.code {
                case .biometryNotEnrolled:
                    print("Face id not available")
                    self.sendToSettings()
                default:
                    print("Unknown error")
                }
            }
        }
    }
    
    func sendToSettings() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Bio Enrollment", message: "Would you like to enroll now?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (aa) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func promptForUserCode() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Enter Code", message: "Enter your user code", preferredStyle: .alert)
            
            ac.addTextField { tf in
                tf.placeholder = "Enter code"
                tf.keyboardType = .numberPad
                tf.isSecureTextEntry = true
            }
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { a in
                print(ac.textFields?.first?.text ?? "No value")
            }))
            
            self.present(ac, animated: true)
        }
    }
}

