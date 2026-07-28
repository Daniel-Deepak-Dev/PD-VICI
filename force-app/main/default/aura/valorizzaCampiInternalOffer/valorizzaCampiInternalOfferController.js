({
	doInit : function(component, event, helper) {
        var action = component.get("c.updateOpportunity");
        action.setParams({"opportunityId": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('Problem updating account, response state: ' + state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "title": "Attention!",
                    "message": "The fields are already enhanced"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
})