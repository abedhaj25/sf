import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getChecklistItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import saveChecklist from '@salesforce/apex/ChecklistController.saveChecklist';
import getCurrentShift from '@salesforce/apex/ChecklistController.getCurrentShift';
import getUserInfo from '@salesforce/apex/ChecklistController.getUserInfo';

export default class ChecklistComponent extends LightningElement {
    @track checklistItems = [];
    @track selectedShift;
    @track signature = '';
    @track userName = '';
    @track isLoading = true;
    @track hasCompletedChecklist = false;
    @track completedDate;
    @track completedBy;
    
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
        return !this.signature || !this.allItemsChecked() || this.hasCompletedChecklist;
    }
    
    get formattedDate() {
        return new Date().toLocaleDateString();
    }
    
    connectedCallback() {
        Promise.all([
            getCurrentShift(),
            getUserInfo()
        ])
        .then(results => {
            this.selectedShift = results[0];
            this.userName = results[1].Name;
            this.loadChecklistItems();
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
            this.isLoading = false;
        });
    }
    
    loadChecklistItems() {
        this.isLoading = true;
        if (this.selectedShift) {
            getChecklistItems({ shiftType: this.selectedShift })
                .then(result => {
                    if (result.items) {
                        this.checklistItems = result.items.map(item => {
                            return {
                                ...item,
                                isCompleted: item.Status__c === 'Completed'
                            };
                        });
                    }
                    
                    this.hasCompletedChecklist = result.isCompleted;
                    this.completedDate = result.completedDate;
                    this.completedBy = result.completedBy;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                    this.isLoading = false;
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
        return this.checklistItems.length > 0 && this.checklistItems.every(item => item.isCompleted);
    }
    
    handleSubmit() {
        if (!this.signature || !this.allItemsChecked()) return;
        
        this.isLoading = true;
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
                this.isLoading = false;
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