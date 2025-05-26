public with sharing class ChecklistItemController {
    @AuraEnabled(cacheable=true)
    public static List<Checklist_Item__c> getItems(String shiftChecklistId) {
        return [SELECT Id, Name, Status__c, Completion_Time__c 
                FROM Checklist_Item__c 
                WHERE Shift_Checklist__c = :shiftChecklistId
                ORDER BY CreatedDate];
    }
}