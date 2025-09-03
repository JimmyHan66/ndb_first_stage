/**
 * @file pdqsort.h
 * @brief Pattern-defeating Quicksort (pdqsort) - A high-performance hybrid
 * sorting algorithm
 *
 * PDQSort is an adaptive sorting algorithm that combines the best features of
 * quicksort, heapsort, and insertion sort. It automatically detects patterns
 * that would make quicksort perform poorly and switches to alternative
 * strategies.
 *
 * Key features:
 * - Adaptive: Performs well on all types of input data (random, sorted,
 * reverse-sorted, etc.)
 * - Pattern-defeating: Detects and handles adversarial input patterns
 * - Hybrid: Uses the most appropriate sorting algorithm for each situation
 * - Guaranteed O(n log n) worst-case performance
 * - Typically faster than standard quicksort implementations
 *
 * @author Your Name
 * @date 2025
 * @version 1.0
 */

#ifndef PDQSORT_H
#define PDQSORT_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Function pointer type for comparison functions
 *
 * The comparison function should return:
 * - A negative value if the first argument is less than the second
 * - Zero if they are equal
 * - A positive value if the first argument is greater than the second
 *
 * @param a Pointer to first element
 * @param b Pointer to second element
 * @return Comparison result as described above
 */
typedef int (*compare_func_t)(const void *a, const void *b);

/**
 * @brief Sort an array using the PDQSort algorithm
 *
 * This function sorts an array of elements using the pattern-defeating
 * quicksort algorithm. The function is generic and can sort any type of data as
 * long as a proper comparison function is provided.
 *
 * @param base Pointer to the first element of the array to sort
 * @param nmemb Number of elements in the array
 * @param size Size in bytes of each element
 * @param cmp Comparison function that determines the sorting order
 *
 * @note The comparison function must be consistent and transitive
 * @note For arrays with 0 or 1 elements, the function returns immediately
 * @note The sorting is performed in-place
 *
 * Time complexity:
 * - Best case: O(n) for already sorted arrays
 * - Average case: O(n log n)
 * - Worst case: O(n log n) guaranteed
 *
 * Space complexity: O(log n) for recursion stack
 *
 * Example usage:
 * @code
 * int compare_int(const void *a, const void *b) {
 *     int ia = *(const int*)a;
 *     int ib = *(const int*)b;
 *     return (ia > ib) - (ia < ib);
 * }
 *
 * int arr[] = {64, 34, 25, 12, 22, 11, 90};
 * size_t n = sizeof(arr) / sizeof(arr[0]);
 * pdqsort(arr, n, sizeof(int), compare_int);
 * @endcode
 */
void pdqsort(void *base, size_t nmemb, size_t size, compare_func_t cmp);

// ============================================================================
// Common comparison functions for convenience
// ============================================================================

/**
 * @brief Comparison function for integers (ascending order)
 * @param a Pointer to first integer
 * @param b Pointer to second integer
 * @return Comparison result
 */
int compare_int(const void *a, const void *b);

/**
 * @brief Comparison function for integers (descending order)
 * @param a Pointer to first integer
 * @param b Pointer to second integer
 * @return Comparison result
 */
int compare_int_desc(const void *a, const void *b);

/**
 * @brief Comparison function for double precision floating point numbers
 * (ascending)
 * @param a Pointer to first double
 * @param b Pointer to second double
 * @return Comparison result
 */
int compare_double(const void *a, const void *b);

/**
 * @brief Comparison function for double precision floating point numbers
 * (descending)
 * @param a Pointer to first double
 * @param b Pointer to second double
 * @return Comparison result
 */
int compare_double_desc(const void *a, const void *b);

/**
 * @brief Comparison function for single precision floating point numbers
 * (ascending)
 * @param a Pointer to first float
 * @param b Pointer to second float
 * @return Comparison result
 */
int compare_float(const void *a, const void *b);

/**
 * @brief Comparison function for strings (alphabetical order)
 *
 * Compares strings using lexicographic order (dictionary order).
 * The function expects pointers to char* (i.e., char**).
 *
 * @param a Pointer to first string pointer (char**)
 * @param b Pointer to second string pointer (char**)
 * @return Comparison result
 */
int compare_string(const void *a, const void *b);

/**
 * @brief Comparison function for strings by length, then alphabetically
 *
 * First compares strings by length (shorter strings come first).
 * If lengths are equal, compares alphabetically.
 *
 * @param a Pointer to first string pointer (char**)
 * @param b Pointer to second string pointer (char**)
 * @return Comparison result
 */
int compare_string_length(const void *a, const void *b);

/**
 * @brief Case-insensitive string comparison function
 *
 * Compares strings ignoring case differences.
 * The function expects pointers to char* (i.e., char**).
 *
 * @param a Pointer to first string pointer (char**)
 * @param b Pointer to second string pointer (char**)
 * @return Comparison result
 */
int compare_string_icase(const void *a, const void *b);

// ============================================================================
// Algorithm configuration constants
// ============================================================================

/**
 * @brief Threshold for switching to insertion sort for small arrays
 *
 * Arrays smaller than or equal to this size will be sorted using
 * insertion sort, which is more efficient for small datasets.
 */
#define PDQSORT_INSERTION_SORT_THRESHOLD 24

/**
 * @brief Threshold for using ninther pivot selection
 *
 * For arrays larger than this threshold, the algorithm uses a more
 * sophisticated pivot selection strategy (ninther) to improve performance.
 */
#define PDQSORT_NINTHER_THRESHOLD 128

/**
 * @brief Limit for partial insertion sort attempts
 *
 * This controls how many elements can be moved during partial insertion
 * sort before giving up and using a different strategy.
 */
#define PDQSORT_PARTIAL_INSERTION_SORT_LIMIT 8

/**
 * @brief Block size for partitioning operations
 *
 * Internal parameter used for optimizing cache performance during
 * partitioning operations.
 */
#define PDQSORT_BLOCK_SIZE 64

// ============================================================================
// Utility functions for testing and benchmarking
// ============================================================================

/**
 * @brief Check if an integer array is sorted in ascending order
 * @param arr Pointer to the integer array
 * @param n Number of elements in the array
 * @return true if the array is sorted, false otherwise
 */
// bool pdqsort_is_sorted_int(const int *arr, size_t n);

/**
 * @brief Generate a random integer array for testing
 * @param arr Pointer to the array to fill
 * @param n Number of elements to generate
 * @param max_val Maximum value for random numbers (0 to max_val-1)
 */
void pdqsort_generate_random_array(int *arr, size_t n, int max_val);

/**
 * @brief Generate a sorted integer array for testing
 * @param arr Pointer to the array to fill
 * @param n Number of elements to generate
 */
void pdqsort_generate_sorted_array(int *arr, size_t n);

/**
 * @brief Generate a reverse-sorted integer array for testing
 * @param arr Pointer to the array to fill
 * @param n Number of elements to generate
 */
void pdqsort_generate_reverse_array(int *arr, size_t n);

/**
 * @brief Generate a nearly-sorted integer array for testing
 * @param arr Pointer to the array to fill
 * @param n Number of elements to generate
 * @param swap_percentage Percentage of elements to randomly swap (0-100)
 */
void pdqsort_generate_nearly_sorted_array(int *arr, size_t n,
                                          int swap_percentage);

/**
 * @brief Measure sorting time in seconds
 * @param sort_func Function pointer to the sorting function
 * @param arr Pointer to the array to sort
 * @param n Number of elements
 * @param size Size of each element
 * @param cmp Comparison function
 * @return Time taken in seconds
 */
double
pdqsort_measure_time(void (*sort_func)(void *, size_t, size_t, compare_func_t),
                     void *arr, size_t n, size_t size, compare_func_t cmp);

// ============================================================================
// Version information
// ============================================================================

/**
 * @brief Get the version string of the pdqsort implementation
 * @return Version string
 */
const char *pdqsort_version(void);

/**
 * @brief Get algorithm information
 * @return String describing the algorithm
 */
const char *pdqsort_info(void);

#ifdef __cplusplus
}
#endif

#endif /* PDQSORT_H */