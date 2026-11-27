public class Q20_LongestPalindromicSubstring {
    public static void main(String[] args) {
        String s = "babad", best = "";
        for (int i = 0; i < s.length(); i++) {
            for (int j = i; j < s.length(); j++) {
                int left = i, right = j;
                boolean palindrome = true;
                while (left < right) {
                    if (s.charAt(left) != s.charAt(right)) palindrome = false;
                    left++;
                    right--;
                }
                if (palindrome && j - i + 1 > best.length())
                    best = s.substring(i, j + 1);
            }
        }
        System.out.println(best);
    }
}
