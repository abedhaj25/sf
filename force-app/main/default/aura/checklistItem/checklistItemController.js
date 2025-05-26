({
    handleStatusChange: function(component, event, helper) {
        let statusChangeEvent = component.getEvent("statusChange");
        statusChangeEvent.setParams({
            "item": component.get("v.item")
        });
        statusChangeEvent.fire();
    },

    handleResourceClick: function(component, event, helper) {
        let item = component.get("v.item");
        if (item.Resource_URL__c) {
            // Open URL in a new tab
            window.open(item.Resource_URL__c, '_blank');
        }
    }
}) 