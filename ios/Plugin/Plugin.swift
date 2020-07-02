import Foundation
import Capacitor
import AuthenticationServices


@available(iOS 13.0, *)
class GetAppleSignInHandler: NSObject, ASAuthorizationControllerDelegate {
  typealias JSObject = [String:Any]
  var call: CAPPluginCall
  var identityTokenString :String?
    var window : UIWindow;
    init(call: CAPPluginCall,window:UIWindow) {
    self.call = call
    self.window = window
    super.init()
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
         // error.localizedDescription
           print("Error - \(error.localizedDescription)")
        call.error(error.localizedDescription, error, [
             "message": error.localizedDescription
           ])
      }
      func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
          if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
              print("User Id - \(appleIDCredential.user)")
              print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
              print("User Email - \(appleIDCredential.email ?? "N/A")")
              print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
              if let identityTokenData = appleIDCredential.identityToken,
                  let theIdentityTokenString = String(data: identityTokenData, encoding: .utf8) {
                  print("Identity Token \(theIdentityTokenString)")
                  self.identityTokenString = theIdentityTokenString
              }
            var ret = JSObject()
            ret["user"] = appleIDCredential.user
            ret["fullName"] = appleIDCredential.fullName?.description ?? "N/A"
            ret["email"] = appleIDCredential.email ?? "N/A"
            ret["realUserStatus"] = appleIDCredential.realUserStatus.rawValue
            ret["identityTokenString"] = self.identityTokenString as Any
            call.success(ret)
          } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
              // Sign in using an existing iCloud Keychain credential.
              let username = passwordCredential.user
              let password = passwordCredential.password
            var ret = JSObject()
                      ret["username"] = username
                      ret["password"] = password
             call.success(ret)
          }
      }
}


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@available(iOS 13.0, *)
@objc(UniAppleSignIn)
public class UniAppleSignIn: CAPPlugin {

    var signInHandler: GetAppleSignInHandler?

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.success([
            "value": value
        ])
    }
    
    @objc func doAppleLogin(_ call: CAPPluginCall) {
        call.save()
            DispatchQueue.main.async {
                self.signInHandler = GetAppleSignInHandler(call: call, window: (self.bridge?.getWebView()?.window)!)
            }
    }
}


@available(iOS 13.0, *)
extension GetAppleSignInHandler: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
  }
}
