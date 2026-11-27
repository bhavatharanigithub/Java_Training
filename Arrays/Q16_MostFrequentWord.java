public class Q16_MostFrequentWord {
    public static void main(String[] args) {
        String s = "Java is easy and Java is powerful";
        String[] words = s.split(" ");
        int[] count = new int[words.length];
        int max = 0;
        for (int i = 0; i < words.length; i++) {
            for (int j = 0; j < words.length; j++)
                if (words[i].equals(words[j])) count[i]++;
            if (count[i] > max) max = count[i];
        }
        for (int i = 0; i < words.length; i++) {
            boolean printed = false;
            for (int j = 0; j < i; j++) if (words[i].equals(words[j])) printed = true;
            if (!printed && count[i] == max)
                System.out.println(words[i] + " = " + max);
        }
    }
}
