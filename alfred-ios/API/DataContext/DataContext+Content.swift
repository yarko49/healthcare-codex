import Foundation

extension DataContext {
    
    func testGetHomeNotifications(completion: @escaping ([NotificationCard]?)->Void) {
        
        if let filepath = Bundle.main.path(forResource: "HomeNotificationJSON", ofType: "txt") {
            do {
                let jsonString = try String(contentsOfFile: filepath)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let jsonData = jsonString.data(using: .utf8) {
                        let result = try? JSONDecoder().decode(CardList.self, from: jsonData)
                        
                        if let list = result?.data {
                            completion(list)
                        }
                    }
                    completion(nil)
                }
            } catch {
                print("Content of HomeNotificationJson.rtf could not be loaded")
            }
        } else {
            print("HomeNotificationJson.rtf not found")
        }
    }
    
    func getQuestionnaire(completion: @escaping ([Item]?)->Void) {
        Requests.getQuestionnaire { (questionnaire) in
            if let questionnaire = questionnaire?.item {
                completion(questionnaire)
            } else {
                completion(nil)
            }
        }
    }
    
}
