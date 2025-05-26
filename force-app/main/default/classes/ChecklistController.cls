public with sharing class ChecklistController {
    @AuraEnabled(cacheable=true)
    public static ChecklistWrapper getChecklistItems(String shiftType) {
        return ChecklistService.getChecklistItemsWithStatus(shiftType);
    }
    
    @AuraEnabled
    public static void saveChecklist(List<Checklist_Item__c> items, String shiftType, String signature) {
        ChecklistService.saveChecklist(items, shiftType, signature);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCurrentShift() {
        return ChecklistUtility.getCurrentShift();
    }
    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    public class ChecklistWrapper {
        @AuraEnabled public List<Checklist_Item__c> items;
        @AuraEnabled public Boolean isCompleted;
        @AuraEnabled public String completedDate;
        @AuraEnabled public String completedBy;
        
        public ChecklistWrapper(List<Checklist_Item__c> items, Boolean isCompleted, Datetime completedDate, String completedBy) {
            this.items = items;
            this.isCompleted = isCompleted;
            this.completedDate = completedDate != null ? completedDate.format('MMM d, yyyy h:mm a') : null;
            this.completedBy = completedBy;
        }
    }
}