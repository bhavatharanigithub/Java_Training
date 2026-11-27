public class Q09_MaximumDifference {
    public static void main(String[] args) {
        int[] a = {7, 1, 5, 3, 6, 4};
        int min = a[0], maxDifference = Integer.MIN_VALUE;
        for (int i = 1; i < a.length; i++) {
            int difference = a[i] - min;
            if (difference > maxDifference) maxDifference = difference;
            if (a[i] < min) min = a[i];
        }
        System.out.println("Maximum Difference = " + maxDifference);
    }
}
