import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getChecklistItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import saveChecklist from '@salesforce/apex/ChecklistController.saveChecklist';
import getCurrentShift from '@salesforce/apex/ChecklistController.getCurrentShift';

export default class ChecklistComponent extends LightningElement {
    @track checklistItems = [];
    @track selectedShift;
    @track signature = '';
    
    get shiftOptions() {
        return [
            { label: 'Morning', value: 'Morning' },
            { label: 'Midday', value: 'Midday' },
            { label: 'Afternoon', value: 'Afternoon' },
            { label: 'Evening', value: 'Evening' },
            { label: 'Night', value: 'Night' }
        ];
    }
    
    get isSubmitDisabled() {
        return !this.signature || !this.allItemsChecked();
    }
    
    connectedCallback() {
        getCurrentShift()
            .then(result => {
                this.selectedShift = result;
                this.loadChecklistItems();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }
    
    loadChecklistItems() {
        if (this.selectedShift) {
            getChecklistItems({ shiftType: this.selectedShift })
                .then(result => {
                    this.checklistItems = result.map(item => {
                        return {
                            ...item,
                            isCompleted: item.Status__c === 'Completed'
                        };
                    });
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
        }
    }
    
    handleShiftChange(event) {
        this.selectedShift = event.detail.value;
        this.loadChecklistItems();
    }
    
    handleCheckboxChange(event) {
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;
        
        this.checklistItems = this.checklistItems.map(item => {
            if (item.Id === itemId) {
                return {
                    ...item,
                    Status__c: isChecked ? 'Completed' : 'Pending',
                    isCompleted: isChecked
                };
            }
            return item;
        });
    }
    
    handleSignatureChange(event) {
        this.signature = event.target.value;
    }
    
    allItemsChecked() {
        return this.checklistItems.every(item => item.isCompleted);
    }
    
    handleSubmit() {
        if (!this.signature || !this.allItemsChecked()) return;
        
        saveChecklist({ 
            items: this.checklistItems, 
            shiftType: this.selectedShift,
            signature: this.signature
        })
            .then(() => {
                this.showToast('Success', 'Checklist submitted successfully', 'success');
                this.signature = '';
                this.loadChecklistItems();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}