
/**
 * Returns 1 for TRUE boolean values, 0 for FALSE to be used in
 * arithmetical calculations.
 *
 * @param b
 */
function booleanToInt ( b ) {
    return b ? 1 : 0;
};

/**
 * Returns a random number between 0..n-1
 * @param n
 */
function random ( n ) {
    return Math.floor(Math.random() * n);
};

/**
 * Returns a random number between n1..n2 inclusive
 * @param n1
 * @param n2
 */
function randomRange ( n1, n2 ) {
    return Math.floor(Math.random() * (n2 - n1 + 1)) + n1;
};

/**
 * Returns a random number between -(n-1)..(n-1) except 0.
 * For exammple a n=3 will give you -3,-2,-1,1,2,3 as possible answers
 * @param n
 */
function randomSignedNoZero ( n ) {
    var i = random(n * 2) - n + 1;  // -(n-1), -(n-2), ..., 0, ..., n-1, n
    return (i < 1) ? i - 1 : i;
};

/**
 * Returns a floating point random between [0..n)
 * @param n
 */
function randomFloat ( n ) {
    return Math.random() * n;
};

/**
 * Returns a floating point random between [n1..n2)
 * @param n1 from
 * @param n2 to
 */
function randomFloatRange ( n1, n2 ) {
    return Math.random() * (n2 - n1) + n1;
};

/**
 * Returns the current time in milliseconds since 1970
 */
function timeInMillis () {
    return (new Date()).getTime();
};

/**
 * Returns TRUE if x is between start and finish (non inclusive)
 *
 * @param x
 * @param start
 * @param finish
 */
function inRange ( x, start, finish ) {
    return (x >= start) && (x < finish);
};