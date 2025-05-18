
import { LightningElement, track } from 'lwc';
import getChecklistItems from '@salesforce/apex/ChecklistController.getChecklistItems';
import saveChecklist from '@salesforce/apex/ChecklistController.saveChecklist';
import getCurrentShift from '@salesforce/apex/ChecklistController.getCurrentShift';

export default class ChecklistComponent extends LightningElement {
    @track checklistItems = [];
    @track selectedShift;
    @track generalComments = '';
    @track isLoading = false;

    shiftOptions = [
        { label: 'Morning Shift', value: 'Morning' },
        { label: 'Afternoon Shift', value: 'Afternoon' },
        { label: 'Evening Shift', value: 'Evening' },
        { label: 'Night Shift', value: 'Night' },
        { label: 'Weekend Shift', value: 'Weekend' }
    ];

    statusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
        { label: 'N/A', value: 'N/A' }
    ];

    connectedCallback() {
        this.isLoading = true;
        getCurrentShift().then(result => {
            this.selectedShift = result;
            return getChecklistItems({ shiftType: this.selectedShift });
        }).then(result => {
            this.checklistItems = result;
            this.isLoading = false;
        }).catch(error => {
            console.error('Error loading checklist:', error);
            this.isLoading = false;
        });
    }

    // other methods omitted for brevity
}
