
import java.util.*;

public class RetailBankingTransactionReview {

    static int binarySearch(int[] arr, int key) {
        int low = 0, high = arr.length - 1, count = 0;

        while (low <= high) {
            int mid = low + (high - low) / 2;
            count++;

            if (arr[mid] == key) {
                System.out.println("Binary Search Comparisons: " + count);
                return mid;
            }

            if (arr[mid] < key)
                low = mid + 1;
            else
                high = mid - 1;
        }

        System.out.println("Binary Search Comparisons: " + count);
        return -1;
    }

    static int linearSearch(int[] arr, int key) {
        int count = 0;

        for (int i = 0; i < arr.length; i++) {
            count++;

            if (arr[i] == key) {
                System.out.println("Linear Search Comparisons: " + count);
                return i;
            }
        }

        System.out.println("Linear Search Comparisons: " + count);
        return -1;
    }

    static void task1() {
        System.out.println("\nTASK 1: BINARY SEARCH AND LINEAR SEARCH");

        int[] arr = new int[100000];

        for (int i = 0; i < arr.length; i++)
            arr[i] = i + 1000;

        System.out.println("Best Case:");
        binarySearch(arr, arr[50000]);
        linearSearch(arr, arr[0]);

        System.out.println("Average Case:");
        binarySearch(arr, arr[49999]);
        linearSearch(arr, arr[49999]);

        System.out.println("Worst Case:");
        binarySearch(arr, -1);
        linearSearch(arr, -1);
    }

    static class Transaction {
        String date;
        String description;

        Transaction(String date, String description) {
            this.date = date;
            this.description = description;
        }

        public String toString() {
            return date + " - " + description;
        }
    }

    static void insertionSort(Transaction[] arr) {
        for (int i = 1; i < arr.length; i++) {
            Transaction key = arr[i];
            int j = i - 1;

            while (j >= 0 &&
                   arr[j].date.compareTo(key.date) > 0) {
                arr[j + 1] = arr[j];
                j--;
            }

            arr[j + 1] = key;
        }
    }

    static void mergeSort(Transaction[] arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;

            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);

            merge(arr, left, mid, right);
        }
    }

    static void merge(Transaction[] arr, int left, int mid, int right) {
        Transaction[] temp = new Transaction[right - left + 1];

        int i = left, j = mid + 1, k = 0;

        while (i <= mid && j <= right) {
            if (arr[i].date.compareTo(arr[j].date) <= 0)
                temp[k++] = arr[i++];
            else
                temp[k++] = arr[j++];
        }

        while (i <= mid)
            temp[k++] = arr[i++];

        while (j <= right)
            temp[k++] = arr[j++];

        for (int x = 0; x < temp.length; x++)
            arr[left + x] = temp[x];
    }

    static void task2() {
        System.out.println("\nTASK 2: INSERTION SORT AND MERGE SORT");

        Transaction[] transactions = {
            new Transaction("2026-11-05 10:30", "ATM Withdrawal"),
            new Transaction("2026-11-05 09:15", "Online Payment"),
            new Transaction("2026-11-05 10:30", "Grocery Payment"),
            new Transaction("2026-11-05 08:00", "Salary Credit")
        };

        Transaction[] a = transactions.clone();
        Transaction[] b = transactions.clone();

        insertionSort(a);

        System.out.println("Insertion Sort:");
        for (Transaction t : a)
            System.out.println(t);

        mergeSort(b, 0, b.length - 1);

        System.out.println("Merge Sort:");
        for (Transaction t : b)
            System.out.println(t);
    }

    static class BankTransaction {
        String account;
        double amount;
        String merchant;
        long timestamp;

        BankTransaction(String account, double amount,
                        String merchant, long timestamp) {
            this.account = account;
            this.amount = amount;
            this.merchant = merchant;
            this.timestamp = timestamp;
        }
    }

    static void findDuplicates(BankTransaction[] arr) {
        HashMap<String, Long> map = new HashMap<>();

        for (BankTransaction t : arr) {
            String key = t.account + "_" + t.amount + "_" + t.merchant;

            if (map.containsKey(key)) {
                long previousTime = map.get(key);

                if (t.timestamp >= previousTime &&
                    t.timestamp - previousTime <= 60) {
                    System.out.println("Duplicate Transaction Found: "
                            + t.account + " " + t.amount + " " + t.merchant);
                }
            }

            if (!map.containsKey(key) ||
                t.timestamp > map.get(key)) {
                map.put(key, t.timestamp);
            }
        }
    }

    static void task3() {
        System.out.println("\nTASK 3: DUPLICATE TRANSACTION DETECTION");

        BankTransaction[] transactions = {
            new BankTransaction("ACC101", 500, "Amazon", 1000),
            new BankTransaction("ACC102", 800, "Flipkart", 1050),
            new BankTransaction("ACC101", 500, "Amazon", 1040),
            new BankTransaction("ACC101", 500, "Amazon", 1200)
        };

        findDuplicates(transactions);
    }

    static class Queue {
        int[] arr = new int[100];
        int front = 0;
        int rear = -1;

        void enqueue(int value) {
            if (rear == arr.length - 1) {
                System.out.println("Queue is Full");
                return;
            }

            arr[++rear] = value;
            System.out.println("Added to Queue: " + value);
        }

        void dequeue() {
            if (front > rear) {
                System.out.println("Queue is Empty");
                return;
            }

            System.out.println("Processed Transaction: " + arr[front++]);
        }

        void display() {
            System.out.print("Queue: ");

            for (int i = front; i <= rear; i++)
                System.out.print(arr[i] + " ");

            System.out.println();
        }
    }

    static class Stack {
        int[] arr = new int[100];
        int top = -1;

        void push(int value) {
            if (top == arr.length - 1) {
                System.out.println("Stack is Full");
                return;
            }

            arr[++top] = value;
            System.out.println("Adjustment Added: " + value);
        }

        void pop() {
            if (top == -1) {
                System.out.println("Stack is Empty");
                return;
            }

            System.out.println("Reversing Adjustment: " + arr[top--]);
        }

        void display() {
            System.out.print("Stack: ");

            for (int i = top; i >= 0; i--)
                System.out.print(arr[i] + " ");

            System.out.println();
        }
    }

    static void task4() {
        System.out.println("\nTASK 4: QUEUE AND STACK");

        Queue q = new Queue();

        q.enqueue(101);
        q.enqueue(102);
        q.enqueue(103);

        q.display();
        q.dequeue();
        q.display();

        Stack s = new Stack();

        s.push(201);
        s.push(202);
        s.push(203);

        s.display();
        s.pop();
        s.display();
    }

    static class Result {
        int min, max;

        Result(int min, int max) {
            this.min = min;
            this.max = max;
        }
    }

    static Result findMinMax(int[] arr, int low, int high) {
        if (low == high)
            return new Result(arr[low], arr[low]);

        if (high == low + 1) {
            if (arr[low] < arr[high])
                return new Result(arr[low], arr[high]);
            else
                return new Result(arr[high], arr[low]);
        }

        int mid = low + (high - low) / 2;

        Result left = findMinMax(arr, low, mid);
        Result right = findMinMax(arr, mid + 1, high);

        return new Result(
            Math.min(left.min, right.min),
            Math.max(left.max, right.max)
        );
    }

    static void bruteForce(int[] arr) {
        int min = arr[0];
        int max = arr[0];

        for (int i = 1; i < arr.length; i++) {
            if (arr[i] < min)
                min = arr[i];

            if (arr[i] > max)
                max = arr[i];
        }

        System.out.println("Brute Force Minimum: " + min);
        System.out.println("Brute Force Maximum: " + max);
    }

    static void task5() {
        System.out.println("\nTASK 5: DIVIDE AND CONQUER");

        int[] transactions = {
            500, 1200, 300, 4500, 800, 100, 2500, 700
        };

        Result result = findMinMax(
            transactions, 0, transactions.length - 1
        );

        System.out.println("Divide and Conquer:");
        System.out.println("Minimum Amount: " + result.min);
        System.out.println("Maximum Amount: " + result.max);

        System.out.println("Brute Force:");
        bruteForce(transactions);
    }

    public static void main(String[] args) {
        task1();
        task2();
        task3();
        task4();
        task5();
    }
}
