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

public class ConnectionManager: NSObject {
    private var _connection: NSXPCConnection!
    
    private func establishConnection() -> Void {
        _connection = NSXPCConnection(serviceName: "com.yummymelon.CapteeXPCService")
        
        _connection.remoteObjectInterface = NSXPCInterface(with: CapteeXPCServiceProtocol.self)
        
        _connection.interruptionHandler = {
            print("<< connection to XPC service has been interrupted")
        }
        
        _connection.invalidationHandler = {
            print("<< connection to XPC service has been invalidated")
            self._connection = nil
        }
        
        _connection.resume()
        
        print(">> successfully connected to XPC service!")
    }
    
    public func xpcService() -> CapteeXPCServiceProtocol {
        if _connection == nil {
            print("no existing connection; connecting…")
            establishConnection()
        }
        
        return _connection.remoteObjectProxyWithErrorHandler { error in
            print("\(error)")
        } as! CapteeXPCServiceProtocol
    }
    
    func invalidateConnection() {
        guard _connection != nil else {
            print("no connection to invalidate")
            return
        }
        
        _connection.invalidate()
    }
}
