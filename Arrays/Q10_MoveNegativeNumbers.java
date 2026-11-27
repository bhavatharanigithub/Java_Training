public class Q10_MoveNegativeNumbers {
    public static void main(String[] args) {
        int[] a = {10, -5, 20, -8, 15, -2};
        int[] result = new int[a.length];
        int k = 0;
        for (int x : a) if (x < 0) result[k++] = x;
        for (int x : a) if (x >= 0) result[k++] = x;
        for (int x : result) System.out.print(x + " ");
    }
}
