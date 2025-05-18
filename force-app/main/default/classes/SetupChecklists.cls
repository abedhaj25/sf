public class SetupChecklists {
    public static void scheduleDaily() {
        String jobId = System.schedule(
            'Daily Checklist Creation',
            '0 0 5 * * ?', // Run at 5 AM daily
            new ChecklistScheduler()
        );
    }
}