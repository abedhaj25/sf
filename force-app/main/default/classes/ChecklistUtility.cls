public class ChecklistUtility {
    public static String getCurrentShift() {
        DateTime now = DateTime.now();
        Integer hour = now.hour();
        
        if (hour >= 6 && hour < 10) return 'Morning';
        if (hour >= 10 && hour < 14) return 'Midday';
        if (hour >= 14 && hour < 18) return 'Afternoon';
        if (hour >= 18 && hour < 22) return 'Evening';
        return 'Night';
    }
}