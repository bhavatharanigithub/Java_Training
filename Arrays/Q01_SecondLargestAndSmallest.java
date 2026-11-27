public class Q01_SecondLargestAndSmallest {
    public static void main(String[] args) {
        int[] a = {10, 5, 20, 8, 15, 2};
        int max = Integer.MIN_VALUE, secondMax = Integer.MIN_VALUE;
        int min = Integer.MAX_VALUE, secondMin = Integer.MAX_VALUE;
        for (int x : a) {
            if (x > max) { secondMax = max; max = x; }
            else if (x != max && x > secondMax) secondMax = x;
            if (x < min) { secondMin = min; min = x; }
            else if (x != min && x < secondMin) secondMin = x;
        }
        if (secondMax == Integer.MIN_VALUE || secondMin == Integer.MAX_VALUE)
            System.out.println("Not enough distinct elements");
        else {
            System.out.println("Second Largest = " + secondMax);
            System.out.println("Second Smallest = " + secondMin);
        }
    }
}
