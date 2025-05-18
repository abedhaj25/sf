
public without sharing class ChecklistService {
    public static List<Checklist_Item__c> getChecklistItems(String shiftType) {
        List<Checklist_Template__c> templates = [
            SELECT Id, Name, Description__c, Shift_Type__c 
            FROM Checklist_Template__c 
            WHERE Shift_Type__c = :shiftType
            ORDER BY Order__c
        ];

        List<Checklist_Item__c> items = new List<Checklist_Item__c>();
        for (Checklist_Template__c template : templates) {
            items.add(new Checklist_Item__c(
                Name = template.Name,
                Description__c = template.Description__c,
                Shift_Type__c = shiftType,
                Status__c = 'Not Started',
                Template_Id__c = template.Id
            ));
        }
        return items;
    }

    public static void saveChecklist(List<Checklist_Item__c> items, String shiftType) {
        upsert items;
    }
}
