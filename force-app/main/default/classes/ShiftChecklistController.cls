public with sharing class ShiftChecklistController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getShiftOptions() {
        try {
            List<Map<String,String>> options = new List<Map<String,String>>();
            
            // Updated shift options
            options.add(new Map<String,String>{
                'label' => 'Morning Shift',
                'value' => 'Morning'
            });
            options.add(new Map<String,String>{
                'label' => 'Morning Monitor',
                'value' => 'Morning Monitor'
            });
            options.add(new Map<String,String>{
                'label' => 'Evening Shift',
                'value' => 'Evening'
            });
            options.add(new Map<String,String>{
                'label' => 'Evening Monitor',
                'value' => 'Evening Monitor'
            });
            options.add(new Map<String,String>{
                'label' => 'Night Shift',
                'value' => 'Night'
            });
            
            return options;
        } catch(Exception e) {
            throw new AuraHandledException('Error retrieving shift options: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Shift_Checklist__c startChecklist(String shiftType) {
        try {
            if(String.isBlank(shiftType)) {
                throw new AuraHandledException('Shift type cannot be blank');
            }

            Date today = Date.today();
            User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            // Find existing checklist
            List<Shift_Checklist__c> existing = [
                SELECT Id, Shift_Type__c, Checklist_Date__c, Status__c, OwnerId 
                FROM Shift_Checklist__c 
                WHERE Shift_Type__c = :shiftType 
                AND Checklist_Date__c = :today
                AND OwnerId = :currentUser.Id
                LIMIT 1
            ];
            
            if(!existing.isEmpty()) {
                return existing[0];
            }
            
            // Create new checklist
            Shift_Checklist__c checklist = new Shift_Checklist__c(
                Shift_Type__c = shiftType,
                Checklist_Date__c = today,
                Status__c = 'Not Done',
                OwnerId = currentUser.Id
            );
            
            insert checklist;
            
            // Create checklist items based on shift type
            List<Checklist_Item__c> items = new List<Checklist_Item__c>();
            
            // Common items for all shifts
            items.add(createItem('Email and Calendar Review', 
                'Check:\n- Important emails\n- Meeting schedules\n- Upcoming events', 
                'Communication', true, checklist.Id, 
                'https://outlook.live.com/mail/inbox'));
                
            items.add(createItem('System Status Check', 
                'Verify:\n- System availability\n- Performance metrics\n- Error logs', 
                'Monitoring', true, checklist.Id,
                'https://go.coralogix.com'));
                
            // Morning specific items
            if(shiftType.contains('Morning')) {
                items.add(createItem('Morning System Startup', 
                    'Complete:\n- System warmup procedures\n- Initial health checks\n- Performance baseline', 
                    'Monitoring', true, checklist.Id,
                    'https://monitoring-dashboard.company.com/morning'));
                    
                items.add(createItem('Daily Planning', 
                    'Review:\n- Day\'s schedule\n- Planned maintenance\n- Team availability', 
                    'Administrative', true, checklist.Id,
                    'https://team-calendar.company.com'));
            }
            
            // Evening specific items
            if(shiftType.contains('Evening')) {
                items.add(createItem('Evening System Check', 
                    'Verify:\n- Peak hour performance\n- Resource utilization\n- Backup readiness', 
                    'Monitoring', true, checklist.Id,
                    'https://monitoring-dashboard.company.com/evening'));
                    
                items.add(createItem('Day Summary', 
                    'Document:\n- Day\'s incidents\n- Resolution status\n- Pending items', 
                    'Administrative', true, checklist.Id,
                    'https://incident-tracker.company.com'));
            }
            
            // Night specific items
            if(shiftType == 'Night') {
                items.add(createItem('Night Operations', 
                    'Monitor:\n- System maintenance windows\n- Automated processes\n- Backup operations', 
                    'Monitoring', true, checklist.Id,
                    'https://backup-status.company.com'));
                    
                items.add(createItem('End of Day Report', 
                    'Prepare:\n- 24-hour summary\n- Incident report\n- Next day handover', 
                    'Administrative', true, checklist.Id,
                    'https://reports.company.com/daily'));
            }
            
            // Monitor specific items
            if(shiftType.contains('Monitor')) {
                items.add(createItem('Detailed Monitoring', 
                    'Focus on:\n- Performance metrics\n- Security alerts\n- Infrastructure health', 
                    'Monitoring', true, checklist.Id,
                    'https://security-dashboard.company.com'));
                    
                items.add(createItem('Monitoring Report', 
                    'Document:\n- System metrics\n- Anomalies detected\n- Actions taken', 
                    'Administrative', true, checklist.Id,
                    'https://monitoring-reports.company.com'));
            }
            
            // Common end-of-shift items
            items.add(createItem('Handover Preparation', 
                'Prepare:\n- Shift summary\n- Outstanding issues\n- Important updates', 
                'Administrative', true, checklist.Id,
                'https://handover.company.com'));
                
            items.add(createItem('Communication Update', 
                'Update:\n- Team chat channels\n- Status boards\n- Documentation', 
                'Communication', true, checklist.Id,
                'https://teams.microsoft.com'));
            
            insert items;
            
            return checklist;
        } catch(Exception e) {
            throw new AuraHandledException('Error starting checklist: ' + e.getMessage());
        }
    }
    
    private static Checklist_Item__c createItem(String name, String description, 
                                              String category, Boolean isCritical, Id checklistId, String resourceUrl) {
        return new Checklist_Item__c(
            Name = name,
            Description__c = description,
            Category__c = category,
            Is_Critical__c = isCritical,
            Status__c = 'Not Started',
            Shift_Checklist__c = checklistId,
            Resource_URL__c = resourceUrl
        );
    }
    
    @AuraEnabled
    public static List<Checklist_Item__c> getItems(Id checklistId) {
        try {
            if(checklistId == null) {
                throw new AuraHandledException('Checklist ID cannot be null');
            }
            
            return [
                SELECT Id, Name, Description__c, Category__c, Is_Critical__c, Status__c, Resource_URL__c
                FROM Checklist_Item__c
                WHERE Shift_Checklist__c = :checklistId
                ORDER BY Category__c, Name
            ];
        } catch(Exception e) {
            throw new AuraHandledException('Error retrieving checklist items: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateItem(Id itemId, String status) {
        try {
            if(itemId == null || String.isBlank(status)) {
                throw new AuraHandledException('Item ID and status are required');
            }
            
            // Validate status value
            if(status != 'Not Started' && status != 'Completed') {
                throw new AuraHandledException('Invalid status value');
            }
            
            Checklist_Item__c item = new Checklist_Item__c(
                Id = itemId,
                Status__c = status
            );
            
            update item;
        } catch(Exception e) {
            throw new AuraHandledException('Error updating checklist item: ' + e.getMessage());
        }
    }
} 