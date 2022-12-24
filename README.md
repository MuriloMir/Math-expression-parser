# math-expression-parser
What we have here is an algorithm that is able to fully interpret and solve any mathematical expression. It works by parsing the mathematical expression which is received as a string, it does it recursively.

It first solves all trigonometric functions, then it solves all logarithmic functions, then it solves all powers and roots, then it solves all products and quotients and finally it solves all sums and differences.

You just need to make sure the expression was typed correctly, these are the rules:

1- trigs and logs must be written in lower case, as in log(2, 10), in which 2 is the base, or as in sin(4.5), in which 4.5 is in degrees, not radians.

2- use a . to write decimal numbers, meaning you should write 1.2 and not 1,2.

3- powers must be written using the ^ operator, as in 2^3, which means 2 to the power of 3.

4- roots must be written using the r operator, as in 8r3, which means the cubic root of 8.

5- you can use parentheses as you wish, just make sure you don't forget to open or close a pair of parentheses, as in ((2 + x), which is missing the closing parentheses.

Compile it with dmd mathexpressionparser.d -m64 -i -J. -O.
Then just run it and play with it, if you do anything that results in NaN (not-a-number) then it will display a message saying you've mistyped something.
