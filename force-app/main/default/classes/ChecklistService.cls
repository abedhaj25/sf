public without sharing class ChecklistService {
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
        
        List<Checklist_Template__c> templates = [
            SELECT Id, Name, Description__c
            FROM Checklist_Template__c
            WHERE Shift_Type__c = :shiftType OR Shift_Type__c = 'All'
            ORDER BY Order__c
        ];
        
        List<Checklist_Item__c> items = new List<Checklist_Item__c>();
        for (Checklist_Template__c template : templates) {
            items.add(new Checklist_Item__c(
                Name = template.Name,
                Description__c = template.Description__c,
                Status__c = 'Pending'
            ));
        }
        return items;
    }

    public static void saveChecklist(List<Checklist_Item__c> items, String shiftType, String signature) {
        Shift_Checklist__c checklist = new Shift_Checklist__c(
            Shift_Type__c = shiftType,
            Shift_Date__c = Date.today(),
            Completed_Date__c = Datetime.now(),
            Completed_By__c = UserInfo.getUserId(),
            Signature__c = signature,
            Status__c = 'Completed'
        );
        insert checklist;
        
        for (Checklist_Item__c item : items) {
            item.Shift_Checklist__c = checklist.Id;
        }
        
        upsert items;
    }
}