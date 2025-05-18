public class ChecklistScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        createDailyChecklists();
    }
    
    public static void createDailyChecklists() {
        List<Shift_Checklist__c> checklists = new List<Shift_Checklist__c>();
        Date today = Date.today();
        List<String> shiftTypes = new List<String>{'Morning', 'Midday', 'Afternoon', 'Evening', 'Night'};
        
        for (String shiftType : shiftTypes) {
            List<Shift_Checklist__c> existing = [
                SELECT Id FROM Shift_Checklist__c
                WHERE Shift_Date__c = :today AND Shift_Type__c = :shiftType
                LIMIT 1
            ];
            
            if (existing.isEmpty()) {
                checklists.add(new Shift_Checklist__c(
                    Shift_Type__c = shiftType,
                    Shift_Date__c = today,
                    Status__c = 'Pending'
                ));
            }
        }
        
        if (!checklists.isEmpty()) {
            insert checklists;
        }
    }
}