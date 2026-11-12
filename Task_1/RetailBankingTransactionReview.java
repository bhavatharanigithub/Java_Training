
import java.util.HashMap;

public class RetailBankingTransactionReview {

    static int binary(int[] a, int key) {
        int l = 0, h = a.length - 1, c = 0;

        while (l <= h) {
            int m = (l + h) / 2;
            c++;
            if (a[m] == key) break;
            if (a[m] < key) l = m + 1;
            else h = m - 1;
        }
        System.out.println("Binary Comparisons: " + c);
        return (l <= h) ? (l + h) / 2 : -1;
    }

    static int linear(int[] a, int key) {
        int c = 0;
        for (int i = 0; i < a.length; i++) {
            c++;
            if (a[i] == key) {
                System.out.println("Linear Comparisons: " + c);
                return i;
            }
        }
        System.out.println("Linear Comparisons: " + c);
        return -1;
    }

    static void task1() {
        System.out.println("\nTASK 1: SEARCHING");

        int[] a = new int[100000];
        for (int i = 0; i < a.length; i++) a[i] = i + 1000;

        System.out.println("Best Case:");
        binary(a, a[49999]);
        linear(a, a[0]);

        System.out.println("Average Case:");
        binary(a, a[75000]);
        linear(a, a[49999]);

        System.out.println("Worst Case:");
        binary(a, -1);
        linear(a, -1);
    }

    static class Transaction {
        String date, name;

        Transaction(String d, String n) {
            date = d;
            name = n;
        }

        public String toString() {
            return date + " " + name;
        }
    }

    static void insertionSort(Transaction[] a) {
        for (int i = 1; i < a.length; i++) {
            Transaction key = a[i];
            int j = i - 1;

            while (j >= 0 && a[j].date.compareTo(key.date) > 0)
                a[j + 1] = a[j--];

            a[j + 1] = key;
        }
    }

    static void mergeSort(Transaction[] a, int l, int h) {
        if (l >= h) return;

        int m = (l + h) / 2;
        mergeSort(a, l, m);
        mergeSort(a, m + 1, h);

        Transaction[] temp = new Transaction[h - l + 1];
        int i = l, j = m + 1, k = 0;

        while (i <= m && j <= h)
            temp[k++] = a[i].date.compareTo(a[j].date) <= 0
                    ? a[i++] : a[j++];

        while (i <= m) temp[k++] = a[i++];
        while (j <= h) temp[k++] = a[j++];

        for (i = 0; i < temp.length; i++)
            a[l + i] = temp[i];
    }

    static void task2() {
        System.out.println("\nTASK 2: SORTING");

        Transaction[] a = {
            new Transaction("10:30", "ATM"),
            new Transaction("09:15", "Online Payment"),
            new Transaction("10:30", "Grocery"),
            new Transaction("08:00", "Salary")
        };

        Transaction[] b = a.clone();

        insertionSort(a);
        System.out.println("Insertion Sort:");
        for (Transaction t : a) System.out.println(t);

        mergeSort(b, 0, b.length - 1);
        System.out.println("Merge Sort:");
        for (Transaction t : b) System.out.println(t);
    }

    static void task3() {
        System.out.println("\nTASK 3: DUPLICATE TRANSACTIONS");

        String[] account = {"A101", "A102", "A101", "A101"};
        int[] amount = {500, 800, 500, 500};
        String[] merchant = {"Amazon", "Flipkart", "Amazon", "Amazon"};
        int[] time = {1000, 1050, 1040, 1200};

        HashMap<String, Integer> map = new HashMap<>();

        for (int i = 0; i < account.length; i++) {
            String key = account[i] + amount[i] + merchant[i];

            if (map.containsKey(key) && time[i] - map.get(key) <= 60)
                System.out.println("Duplicate: " + key);

            if (!map.containsKey(key) || time[i] > map.get(key))
                map.put(key, time[i]);
        }
    }

    static class Queue {
        int[] a = new int[100];
        int front = 0, rear = -1;

        void add(int x) {
            if (rear < 99) a[++rear] = x;
        }

        void remove() {
            if (front <= rear)
                System.out.println("Processed: " + a[front++]);
            else System.out.println("Queue Empty");
        }

        void display() {
            for (int i = front; i <= rear; i++)
                System.out.print(a[i] + " ");
            System.out.println();
        }
    }

    static class Stack {
        int[] a = new int[100];
        int top = -1;

        void push(int x) {
            if (top < 99) a[++top] = x;
        }

        void pop() {
            if (top >= 0)
                System.out.println("Reversed: " + a[top--]);
            else System.out.println("Stack Empty");
        }

        void display() {
            for (int i = top; i >= 0; i--)
                System.out.print(a[i] + " ");
            System.out.println();
        }
    }

    static void task4() {
        System.out.println("\nTASK 4: QUEUE AND STACK");

        Queue q = new Queue();
        q.add(101);
        q.add(102);
        q.add(103);
        q.display();
        q.remove();
        q.display();

        Stack s = new Stack();
        s.push(201);
        s.push(202);
        s.push(203);
        s.display();
        s.pop();
        s.display();
    }

    static int[] minMax(int[] a, int l, int h) {
        if (l == h) return new int[]{a[l], a[l]};

        int m = (l + h) / 2;
        int[] x = minMax(a, l, m);
        int[] y = minMax(a, m + 1, h);

        return new int[]{
            Math.min(x[0], y[0]),
            Math.max(x[1], y[1])
        };
    }

    static void task5() {
        System.out.println("\nTASK 5: MINIMUM AND MAXIMUM");

        int[] a = {500, 1200, 300, 4500, 800, 100, 2500, 700};

        int[] r = minMax(a, 0, a.length - 1);

        System.out.println("Divide and Conquer:");
        System.out.println("Minimum: " + r[0]);
        System.out.println("Maximum: " + r[1]);

        int min = a[0], max = a[0];

        for (int n : a) {
            if (n < min) min = n;
            if (n > max) max = n;
        }

        System.out.println("Brute Force:");
        System.out.println("Minimum: " + min);
        System.out.println("Maximum: " + max);
    }

    public static void main(String[] args) {
        task1();
        task2();
        task3();
        task4();
        task5();
    }
}
