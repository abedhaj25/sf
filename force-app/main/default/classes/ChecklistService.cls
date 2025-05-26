public without sharing class ChecklistService {
    public static ChecklistController.ChecklistWrapper getChecklistItemsWithStatus(String shiftType) {
        Date today = Date.today();
        
        // Check if there's already a completed checklist for today's shift
        List<Shift_Checklist__c> todaysChecklists = [
            SELECT Id, Completed_Date__c, Completed_By__c, Status__c, 
                   (SELECT Id, Name, Status__c, Description__c FROM Checklist_Items__r)
            FROM Shift_Checklist__c
            WHERE Shift_Date__c = :today AND Shift_Type__c = :shiftType
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        // If we found a completed checklist for today
        if (!todaysChecklists.isEmpty()) {
            Shift_Checklist__c checklist = todaysChecklists[0];
            
            // Get the name of the user who completed it
            String completedByName = '';
            if (checklist.Completed_By__c != null) {
                List<User> users = [SELECT Name FROM User WHERE Id = :checklist.Completed_By__c LIMIT 1];
                if (!users.isEmpty()) {
                    completedByName = users[0].Name;
                }
            }
            
            return new ChecklistController.ChecklistWrapper(
                checklist.Checklist_Items__r,
                checklist.Status__c == 'Completed',
                checklist.Completed_Date__c,
                completedByName
            );
        }
        
        // If no checklist exists, create a new one with template items
        List<Checklist_Item__c> items = getDefaultChecklistItems(shiftType);
        return new ChecklistController.ChecklistWrapper(items, false, null, null);
    }
    
    private static List<Checklist_Item__c> getDefaultChecklistItems(String shiftType) {
        // In a real implementation, you would query for checklist templates
        // For this example, we'll create some default items
        List<Checklist_Item__c> items = new List<Checklist_Item__c>();
        
        // Common items for all shifts
        items.add(createChecklistItem('Check emails and tickets', 'Review all incoming emails and tickets in the queue'));
        items.add(createChecklistItem('Update case status', 'Update status of all assigned cases'));
        items.add(createChecklistItem('Team handover', 'Document any ongoing issues for the next shift'));
        
        // Shift-specific items
        if (shiftType == 'Morning') {
            items.add(createChecklistItem('Morning report', 'Generate and send morning status report'));
            items.add(createChecklistItem('Check system alerts', 'Review overnight system alerts'));
        } else if (shiftType == 'Midday') {
            items.add(createChecklistItem('Midday check-in', 'Conduct midday team check-in'));
            items.add(createChecklistItem('Update dashboards', 'Refresh all support dashboards'));
        } else if (shiftType == 'Afternoon') {
            items.add(createChecklistItem('Case escalation review', 'Review any cases requiring escalation'));
            items.add(createChecklistItem('Knowledge base update', 'Update knowledge base with new solutions'));
        } else if (shiftType == 'Evening') {
            items.add(createChecklistItem('Evening report', 'Generate and send evening status report'));
            items.add(createChecklistItem('Prepare handover', 'Prepare handover notes for night shift'));
        } else if (shiftType == 'Night') {
            items.add(createChecklistItem('Monitor critical systems', 'Keep watch on critical system alerts'));
            items.add(createChecklistItem('Emergency response', 'Check emergency response protocols'));
        }
        
        return items;
    }
    
    private static Checklist_Item__c createChecklistItem(String name, String description) {
        return new Checklist_Item__c(
            Name = name,
            Description__c = description,
            Status__c = 'Pending'
        );
    }
    
    public static List<Checklist_Item__c> getChecklistItems(String shiftType) {
        Date today = Date.today();
        List<Shift_Checklist__c> todaysChecklists = [
            SELECT Id, (SELECT Id, Name, Status__c, Description__c FROM Checklist_Items__r)
            FROM Shift_Checklist__c
            WHERE Shift_Date__c = :today AND Shift_Type__c = :shiftType
            LIMIT 1
        ];
        
        if (!todaysChecklists.isEmpty() && !todaysChecklists[0].Checklist_Items__r.isEmpty()) {
            return todaysChecklists[0].Checklist_Items__r;
        }
        
        return getDefaultChecklistItems(shiftType);
    }

    public static void saveChecklist(List<Checklist_Item__c> items, String shiftType, String signature) {
        // Create the shift checklist record
        Shift_Checklist__c checklist = new Shift_Checklist__c(
            Shift_Type__c = shiftType,
            Shift_Date__c = Date.today(),
            Completed_Date__c = Datetime.now(),
            Completed_By__c = UserInfo.getUserId(),
            Signature__c = signature,
            Status__c = 'Completed'
        );
        insert checklist;
        
        // Create or update the checklist items
        List<Checklist_Item__c> itemsToUpsert = new List<Checklist_Item__c>();
        for (Checklist_Item__c item : items) {
            // If the item has an Id, it already exists in the database
            if (item.Id != null) {
                item.Status__c = 'Completed';
                itemsToUpsert.add(item);
            } else {
                // Otherwise, create a new item linked to this checklist
                Checklist_Item__c newItem = new Checklist_Item__c(
                    Name = item.Name,
                    Description__c = item.Description__c,
                    Status__c = 'Completed',
                    Shift_Checklist__c = checklist.Id
                );
                itemsToUpsert.add(newItem);
            }
        }
        
        if (!itemsToUpsert.isEmpty()) {
            upsert itemsToUpsert;
        }
    }
}