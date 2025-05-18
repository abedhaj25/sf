public class ChecklistUtility {
    public static String getCurrentShift() {
        DateTime now = DateTime.now();
        Integer hour = now.hour();
        if (hour >= 6 && hour < 12) return 'Morning';
        if (hour >= 12 && hour < 16) return 'Afternoon';
        if (hour >= 16 && hour < 20) return 'Evening';
        if (hour >= 20 || hour < 6) return 'Night';
        return 'General';
    }
}