public class Q24_SpiralMatrixTraversal {
    public static void main(String[] args) {
        int[][] a = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        int top = 0, bottom = a.length - 1, left = 0, right = a[0].length - 1;
        while (top <= bottom && left <= right) {
            for (int j = left; j <= right; j++) System.out.print(a[top][j] + " ");
            top++;
            for (int i = top; i <= bottom; i++) System.out.print(a[i][right] + " ");
            right--;
            if (top <= bottom) {
                for (int j = right; j >= left; j--) System.out.print(a[bottom][j] + " ");
                bottom--;
            }
            if (left <= right) {
                for (int i = bottom; i >= top; i--) System.out.print(a[i][left] + " ");
                left++;
            }
        }
    }
}
