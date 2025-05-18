
public with sharing class ChecklistController {
    @AuraEnabled
    public static List<Checklist_Item__c> getChecklistItems(String shiftType) {
        return ChecklistService.getChecklistItems(shiftType);
    }

    @AuraEnabled
    public static void saveChecklist(List<Checklist_Item__c> items, String shiftType) {
        ChecklistService.saveChecklist(items, shiftType);
    }

    @AuraEnabled
    public static String getCurrentShift() {
        return ChecklistUtility.getCurrentShift();
    }
}
