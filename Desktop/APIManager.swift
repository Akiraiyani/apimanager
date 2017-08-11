

import Foundation
import AFNetworking

typealias HTTPSucessBlock = (_ operation : URLSessionDataTask, _ responseObject : AnyObject) -> Void
typealias HTTPFailureBlock = (_ operation : URLSessionDataTask, _ error : NSError) -> Void


class APIManager: AFHTTPSessionManager {
    
    
    var successResult : HTTPSucessBlock?;
    var failtureResult : HTTPFailureBlock?;
    
   
    class var sharedRequest: APIManager {
        struct Static {
            static let instance = APIManager(baseURL: URL(string: KEYSPROJECT.WS_BaseURL))
        }
        return Static.instance
    }

    init(baseURL url: URL?)
    {
        super.init(baseURL: url, sessionConfiguration: nil);
        self.responseSerializer = AFJSONResponseSerializer(readingOptions: .mutableContainers);
        self.requestSerializer.timeoutInterval = 30.0;
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit
    {
     
    }
    //MARK:  AUTHENTICATION HEADER
    func setManagerHeader()
    {
        // SET AUTHENTICATION HEADER //
        self.requestSerializer.setValue("Basic YWRtaW46YWRtaW5AMTIz", forHTTPHeaderField: "Authorization")
        self.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments) as AFJSONResponseSerializer
        self.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain", "text/html", "application/json"]) as? Set<String>
        
    }
    func addHeaders()
    {
        
        let strAccessToken =  String(format: "bearer %@",(UserDefaults.standard.object(forKey: "") as? String)!)
        let strSecureStamp = UserDefaults.standard.object(forKey: "") as? String

        let headerDetails : [String:String] = ["Authorization" : strAccessToken, "SecureStamp" : strSecureStamp!]
        for headerField in headerDetails.keys
        {
            self.requestSerializer.setValue(headerDetails[headerField], forHTTPHeaderField: headerField);

        }
    }
    
    //MARK:- CheckAuthentication For expired session
     func checkAuthentication(data:Any?){
        
        if data != nil{
            if let AuthenticationKey = (data as! NSDictionary).value(forKey: WS_Keys.Authentication.rawValue){
                
                if (AuthenticationKey as! Bool == false)
                {
                    DLHelper.allUserDefaultsRemove()
                    APPDELEGATE.isUserLogin()
                    APPDELEGATE.window?.makeToast((data as! NSDictionary).value(forKey: "message") as! String)
                }
            }
        }
    }/** post request with Out Multi type data  */
    //MARK:- POST REQUEST
    

    func sendPostRequest(_ dict : NSDictionary ,_ apiName : String, andSuccessBlock succes : @escaping HTTPSucessBlock, andfailureBlock failure : @escaping HTTPFailureBlock){
        
        self.setManagerHeader()
        
        self.post(apiName, parameters: dict , progress: { (progres : Progress) -> Void in
            
            }, success: { (session : URLSessionDataTask, data:Any?) -> Void in
                
                
                let urlResponse = session.response as? HTTPURLResponse
                
                if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                    let status = urlResponse.statusCode
                    
                    if (status == 200){
                        
                        if data != nil{
                            
                            self.checkAuthentication(data: data)
                            succes(session, data as AnyObject)
                        }
                        else{
                            
                            let error = NSError(domain: "My domain", code: 200, userInfo: ["Please wait our server is under development":NSLocalizedDescriptionKey])
                            failure(session,  error)

                        }
                    }
                }
                
            }) { (session : URLSessionDataTask?, error : Error) -> Void in
                
                let urlResponse = session?.response as? HTTPURLResponse
                
                if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                    let status = urlResponse.statusCode
                    
                    if (status == 400){
                    }else if (status == 500)
                    {
                    }else if (status == 200){
                        
                    }else{
                    }
                    failure(session!, error as NSError)
                }
                else{
                    failure(session!, error as NSError)
                }

                //print(error)
        }
    }
    
    /** post request with Multy Type Data */
    //MARK:- POST REQUEST WITH IMAGE
    func sendPostRequestWithImage(_ dict : NSDictionary,_ apiName : String,WithProfileImage Proimg:UIImage?, andSuccessBlock succes : @escaping HTTPSucessBlock, andfailureBlock failure : @escaping HTTPFailureBlock){
        self.setManagerHeader();
        self.post(apiName, parameters: dict, constructingBodyWith: { (afData :AFMultipartFormData) -> Void in
            
            if let img = Proimg{
                let imageData : Data = UIImagePNGRepresentation(img)!;
                afData .appendPart(withFileData: imageData, name: "photo", fileName: "profile.jpeg", mimeType: "image/*")
            }
            
        }, progress: { (progres : Progress) -> Void in
            
        }, success: { (session : URLSessionDataTask, data:Any?) -> Void in
           
//            succes(session, (data as! NSDictionary?)!)
            
            let urlResponse = session.response as? HTTPURLResponse
            if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                let status = urlResponse.statusCode
                
                if (status == 200){
                    
                    if data != nil{
                        
                        self.checkAuthentication(data: data)
                        succes(session, data as AnyObject)
                    }
                    else{
                        
                        let error = NSError(domain: "My domain", code: 200, userInfo: ["Please wait our server is under development":NSLocalizedDescriptionKey])
                        failure(session,  error)
                        
                    }
                }
            }
            
        }) { (session : URLSessionDataTask?, error : Error) -> Void in
            
            print(error.localizedDescription)
            let urlResponse = session?.response as? HTTPURLResponse
            
            if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                let status = urlResponse.statusCode
                
                if (status == 400){
                }else if (status == 500)
                {
                }else if (status == 200){
                    
                }else{
                }
                failure(session!, error as NSError)
            }
            else{
                failure(session!, error as NSError)
            }
//            if (urlResponse?.statusCode == 401){
//            }else{
//                failure(session!, error as NSError)
//            }
        }
    }
    //MARK:- GET REQUEST
    func sendGetRequest(_ url:String,dict:NSDictionary?,andSuccessBlock succes : @escaping HTTPSucessBlock, andfailureBlock failure : @escaping HTTPFailureBlock) {
        
        self.setManagerHeader()

        self.get(url, parameters: dict, progress: { (progres : Progress) -> Void in
            
            }, success: { (session : URLSessionDataTask, data:Any?) -> Void in
                
                if data != nil{
                    self.checkAuthentication(data: data)

                    succes(session, data! as AnyObject)
                }
                
            }) { (session : URLSessionDataTask?, error : Error) -> Void in
                
                let urlResponse = session?.response as? HTTPURLResponse
                
                if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                    let status = urlResponse.statusCode
                    
                    if (status == 400){
                    }else if (status == 500)
                    {
                    }else if (status == 200){
                        
                    }else{
                    }
                    failure(session!, error as NSError)
                }
                else{
                    failure(session!, error as NSError)
                }
        }
    }
    
    //MARK:- PUT REQUEST 
    func sendPutRequest(_ url:String,dict:NSDictionary,andSuccessBlock succes : @escaping HTTPSucessBlock, andfailureBlock failure : @escaping HTTPFailureBlock) {
        
        self.setManagerHeader()
        self.put(url, parameters: dict, success: { (session, data) in
           
            let urlResponse = session.response as? HTTPURLResponse
            if let urlResponse = urlResponse { // or you can use 'if let _ = urlResponse'
                let status = urlResponse.statusCode
                
                if (status == 200){
                    
                    if data != nil{
                        
                        self.checkAuthentication(data: data)
                        succes(session, data as AnyObject)
                    }
                    else{
                        
                        let error = NSError(domain: "My domain", code: 200, userInfo: ["Please wait our server is under development":NSLocalizedDescriptionKey])
                        failure(session,  error)
                        
                    }
                }
            }
                
        }) { (session : URLSessionDataTask?, error : Error) -> Void in
            failure(session!, error as NSError)
            print(error)
        }

    }
    
    //MARK:- SEND POST REQUEST FOR VAULT
    func sendPostRequestForVault2(urlPath:String, parameters : NSData, authToken:String , andSuccessBlock succes : @escaping (_ result: NSDictionary)->Void, andfailureBlock failure : @escaping (_ error : NSError) -> Void)
    {
        
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = ["Authorization": authToken,"Content-Type":"application/json"]
            let session = URLSession(configuration: sessionConfiguration)
            let url = NSURL(string: urlPath)!
            var request = URLRequest(url: url as URL)
            request.httpBody = parameters as Data
            request.httpMethod = "POST"
        
        let postData = session.dataTask(with: request ) { (data:Data?, responseHeader:URLResponse?, error:Error?) in
            if error == nil && data != nil {
                let str = String(data: data!, encoding: String.Encoding.utf8)
                print(str ?? "")
                
                let httprespose = responseHeader as? HTTPURLResponse
                if((httprespose?.statusCode)! >= 200 && (httprespose?.statusCode)! <= 202 ){
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                        print(json ?? "")
                        succes(json!)
                    } catch {
                        let error  = NSError(domain : Locallized(title: "validation_error"), code: 1234, userInfo: [NSLocalizedDescriptionKey :Locallized(title:"validation_error")])
                        failure(error)
                    }
                } else{
                    let error  = NSError(domain : Locallized(title: "validation_error"), code: 1234, userInfo: [NSLocalizedDescriptionKey :Locallized(title:"validation_error")])
                    failure(error)
                }
            } else {
                failure(error! as NSError)
            }
        }
        postData.resume()
    }
    
    func sendPATCHRequest(urlPath:String,authToken:String, parameters:NSData,andSuccessBlock succes : @escaping (_ result: NSDictionary)->Void, andfailureBlock failure : @escaping (_ error : NSError) -> Void) {
        print(authToken)
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = ["Authorization": authToken,"Content-Type":"application/json"]
        let session = URLSession(configuration: sessionConfiguration)
        let url = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpBody = parameters as Data
        request.httpMethod = "PATCH"
        
        let postData = session.dataTask(with: request as URLRequest) { (data:Data?, responseHeader:URLResponse?, error:Error?) in
            
            let httprespose = responseHeader as? HTTPURLResponse
            
            if((httprespose?.statusCode)! >= 200 && (httprespose?.statusCode)! <= 202 ){
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                    print("%@",json!)
                    succes(json!)
                } catch {
                    let error  = NSError(domain : Locallized(title: "validation_error"), code: 1234, userInfo: [NSLocalizedDescriptionKey :Locallized(title: "validation_error")])
                    failure(error)
                }
            } else{
                let error  = NSError(domain : Locallized(title: "validation_error"), code: 1234, userInfo: [NSLocalizedDescriptionKey :Locallized(title: "validation_error")])
                failure(error)
            }
        }
        postData.resume()
    }
    
    func testBlock(block : (_ operation : URLSessionDataTask, _ responseObject : AnyObject) -> Void){
        
    }


}
