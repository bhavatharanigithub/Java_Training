public class Q14_LongestSubstringWithoutRepeating {
    public static void main(String[] args) {
        String s = "abcabcbb", best = "";
        for (int i = 0; i < s.length(); i++) {
            String current = "";
            for (int j = i; j < s.length(); j++) {
                char ch = s.charAt(j);
                boolean duplicate = false;
                for (int k = 0; k < current.length(); k++)
                    if (current.charAt(k) == ch) duplicate = true;
                if (duplicate) break;
                current += ch;
                if (current.length() > best.length()) best = current;
            }
        }
        System.out.println(best);
        System.out.println("Length = " + best.length());
    }
}
