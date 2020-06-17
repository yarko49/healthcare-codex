import Foundation

extension DataContext {
    func testRequest(completion: @escaping (([String:Any]?) -> Void)) {
        Requests.testRequest { (someContent) in
            completion(someContent)
        }
    }
    
    func testGetHomeNotifications(completion: @escaping ([HomeNotification]?)->Void) {
        let jsonString = """
        {
          "data": [
            {
              "text": "Your doctor would like you to complete the KCCQ",
              "type": "questionaire"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "Your doctor would like you to complete the KCCQ",
              "type": "questionaire"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            },
            {
              "text": "It's been 2 weeks since your weight has been updated",
              "type": "behavioralNudge"
            }
          ]
        }
        """
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let jsonData = jsonString.data(using: .utf8) {
                let result = try? JSONDecoder().decode(HomeNotificationList.self, from: jsonData)
                
                if let list = result?.data {
                    completion(list)
                }
            }
            completion(nil)
        }
    }
}
