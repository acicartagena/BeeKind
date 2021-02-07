//Copyright © 2021 acicartagena. All rights reserved.

import Foundation
import CoreData

class LocalStorage {
    
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
    }

    

}
