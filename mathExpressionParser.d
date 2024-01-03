// This code implements a math expression parser, meaning an interpreter which can solve any mathematical expression with 10 digits of precision.
import std.algorithm.searching : canFind, countUntil;
import std.array : replace;
import std.conv : to;
import std.math : cos, log2, sin, tan;
import std.stdio : readf, writefln, writeln;
import std.string : format;

void main()
{
    // here we finally run the algorithm, these variables will hold the expression, the result and the value of x
    string expression;
    real result, xValue;
    // here we allow you to type the expression
    writeln("Type in the expression as a function of x: ");
    readf("%s\n", expression);
    // then we allow you to type the value of x
    writeln("Type in the value of x: ");
    readf("%f\n", xValue);
    // then we replace all x variables with the x value
    expression = replace(expression, 'x', format("%.10f", xValue));
    // now we remove all spaces and doubled signs
    expression = replace(expression, " ", "");
    expression = replace(expression, "++", "+");
    expression = replace(expression, "--", "+");
    expression = replace(expression, "+-", "-");
    expression = replace(expression, "-+", "-");
    // now we replace the constant of pi
    expression = replace(expression, "pi", "3.14159");
    // then we replace the constant of Euler's number, we need to use a separate function to do it since it is more difficult than just replacing pi
    expression = replaceEuler(expression);
    // then we finally do the magic and evaluate the whole expression with the functions defined below
    result = evaluate(expression);
    // we let you know if you have mistyped something, that happens if the result is NaN
    if (result is real.nan)
        writeln("Error, the expression wasn't type correctly.");
    // if the expression was correct then we print the value on the screen
    else
        writefln("%.10f", result);
}

// this is the recursive function that truly evaluates the expression, this is the heart of this code
real evaluate(string expressionPiece)
{
    // we first calculate all trigonometric functions
    expressionPiece = calculateTrigs(expressionPiece);
    // then we calculate all logarithmic functions
    expressionPiece = calculateLogs(expressionPiece);
    // now we parse it to find the parentheses
    int i, j;
    // this variabel will contain the result of what is inside the parentheses
    real pieceResult;
    // we use a loop to keep solving all parentheses
    while (canFind(expressionPiece, '(') && canFind(expressionPiece, ')'))
    {
        // here we find the first opening parentheses
        i = cast(int) countUntil(expressionPiece, '(');
        // then we check if there are nested opening parentheses
        for (j = i + 1; j < expressionPiece.length; j++)
            // we update the parser if it finds another opening parentheses
            if (expressionPiece[j] == '(')
                i = j;
            // we stop when we find the first closing parentheses
            else if (expressionPiece[j] == ')')
                break;
        // we evaluate what is in between those parentheses
        pieceResult = evaluate(expressionPiece[i + 1 .. j]);
        // then we replace this value inside the expression
        expressionPiece = expressionPiece[0 .. i] ~ format("%.10f", pieceResult) ~ expressionPiece[j + 1 .. $];
    }
    // if there is an extra parentheses that you've mistyped then we return NaN
    if (canFind(expressionPiece, '(') || canFind(expressionPiece, ')'))
        return real.nan;
    // here we get rid of all doubled signs that may have appeared during the calculations
    expressionPiece = replace(expressionPiece, "--", "+");
    expressionPiece = replace(expressionPiece, "+-", "-");
    // we first calculate all factorials
    while (canFind(expressionPiece, '!'))
        expressionPiece = calculateFactorials(expressionPiece);
    // then we calculate all powers and roots
    expressionPiece = calculatePowersAndRoots(expressionPiece);
    // then we calculate all products and quotients
    expressionPiece = calculateProductsAndQuotients(expressionPiece);
    // then we calculate all sums and differences
    expressionPiece = calculateSumsAndDifferences(expressionPiece);
    // then we return the final value as a real number
    return to!real(expressionPiece);
}

// this function will just replace the constant 'e' with its proper value of 2.71828
string replaceEuler(string mathExpression)
{
    // we check all characters of the expression to see if any of them is an 'e'
    for (int i = 0; i < mathExpression.length; i++)
        // we have to make sure it is not the 'sec()' function instead
        if ((i > 0 && mathExpression[i] == 'e' && mathExpression[i - 1] != 's') || (i < mathExpression.length - 1 && mathExpression[i] == 'e' && mathExpression[i + 1] != 'c'))
            // we replace it in the expression
            mathExpression = mathExpression[0 .. i] ~ "2.71828" ~ mathExpression[i + 1 .. $];
    // we return the new mathematical expression without the constant 'e'
    return mathExpression;
}

// this function calculates all trigonometric expressions by calling the function 'solveAnyTrig()' defined above
string calculateTrigs(string mathExpression)
{
    // it checks each trigonometric formula
    foreach (formula; ["sin", "cos", "tan", "sec", "csc", "cot"])
    {
        // it keeps solving the formula in a loop until it has solved them all
        while (canFind(mathExpression, formula))
            mathExpression = solveAnyTrig(mathExpression, formula);
    }
    // it returns the new version of the expression with all trig functions solved
    return mathExpression;
}

// this is the function that solves each individual trigonometric expression
string solveAnyTrig(string mathExpression, string formula)
{
    // 'partialResult' will contain the result of the trigonometric expression
    real partialResult;
    // this will contain the number of degrees in the expression
    string number;
    // these variables will mark where the expression begins and where it ends
    int i, begin;
    // we count until the character where the formula begins and then we add 4 to make up for the name and the parentheses
    begin = cast(int) countUntil(mathExpression, formula) + 4;
    // here we iterate until we reach the final parentheses of the expression
    i = begin - 1;
    while (mathExpression[++i] != ')')
    {}
    // in case there is another expression inside the function, as in sin(x + 4 / 5), we need to evaluate it first
    number = format("%.10f", evaluate(mathExpression[begin .. i]));
    // here we calculate the value according to the formula
    switch (formula)
    {
        case "sin":
            partialResult = sin(to!real(number) / 57.2958);
            break;
        case "cos":
            partialResult = cos(to!real(number) / 57.2958);
            break;
        case "tan":
            partialResult = tan(to!real(number) / 57.2958);
            break;
        case "sec":
            partialResult = 1.0 / cos(to!real(number) / 57.2958);
            break;
        case "csc":
            partialResult = 1.0 / sin(to!real(number) / 57.2958);
            break;
        case "cot":
            partialResult = 1.0 / tan(to!real(number) / 57.2958);
            break;
        // in case you have mistyped something
        default:
            partialResult = real.nan;
    }
    // now we replace it with the result in the original expression
    mathExpression = mathExpression[0 .. begin - 4] ~ format("%.10f", partialResult) ~ mathExpression[i + 1 .. $];
    // it returns the new version of the expression with the trig function solved
    return mathExpression;
}

// this function will calculate all logarithmic expressions
string calculateLogs(string mathExpression)
{
    // 'partialResult' will contain the result of the operations we perform
    real partialResult;
    // these strings will hold the number and the base
    string firstNumber, secondNumber;
    // these ints will be used to keep track of where the parser is
    int i, begin, end;
    // we will use a loop to keep solving all logs until there are none left
    while (canFind(mathExpression, "log"))
    {
        // we count until we find the word "log" and add 4 to push the parser to the number that comes after "log("
        begin = cast(int) countUntil(mathExpression, "log") + 4;
        // we use this to move the parser until we find the coma
        i = begin - 1;
        while (mathExpression[++i] != ',')
        {}
        // in case there is another expression inside the function, as in log(x + 1, 10), we need to evaluate it first
        firstNumber = format("%.10f", evaluate(mathExpression[begin .. i]));
        // now we move the parser until we find the final parentheses
        end = i;
        while (mathExpression[++end] != ')')
        {}
        // in case there is another expression inside the function, as in log(2, x + 1), we need to evaluate it first
        secondNumber = format("%.10f", evaluate(mathExpression[i + 1 .. end]));
        // we have to make sure the number isn't negative
        if (firstNumber[0] == '-' || secondNumber[0] == '-')
            // a log of a negative number will return NaN because it is impossible
            partialResult = real.nan;
        else
            // here we calculate the result by placing everything in the base 2
            partialResult = log2(to!real(secondNumber)) / log2(to!real(firstNumber));
        // now we place the result in its place inside the expression
        mathExpression = mathExpression[0 .. begin - 4] ~ format("%.10f", partialResult) ~ mathExpression[end + 1 .. $];
    }
    // now we return the new expression without any logs
    return mathExpression;
}

// this is the function that solves each individual factorial
string calculateFactorials(string mathExpression)
{
    // these variables will be used to know where the number begins and where it ends
    int begin, end;
    // we find out the end, we begin from the end because we will count backwards
    begin = end = cast(int) countUntil(mathExpression, '!');
    // we stop if we find any sign of any operation or if 'begin' turns negative (it happens after we reach the beginning of the expression)
    while (begin >= 0 && mathExpression[begin] != '+' && mathExpression[begin] != '-' && mathExpression[begin] != '*' && mathExpression[begin] != '/')
        begin--;
    // we have to increment it because the loop above makes it be decremented once more than necessary
    begin++;
    // here we store the partial result
    string partialResult = factorial(mathExpression[begin .. end]);
    // we add it back to the expression and return it, but to prevent bugs we have to check if 'end' is equal to the length of the math expression - 1
    return mathExpression[0 .. begin] ~ partialResult ~ (end < mathExpression.length - 1 ? mathExpression[end + 1 .. $] : "");
}

// this is the function that calculates the factorial of a number
string factorial(string number)
{
    ulong result;
    // we check if the number is a float, if the decimal part is 0 then it is the same as an integer
    if (canFind(number, '-') || canFind(number, '.') && to!real(number) != cast(ulong) to!real(number))
        // if the decimal part is not 0 then we can't calculate the factorial
        return "nan";
    else
        // we convert it to ulong
        result = to!ulong(to!real(number));
    // the factorial of 0 is 1
    if (result == 0)
        return "1";
    // we multiply it by all numbers that come before it
    foreach (i; 2 .. result)
        result *= i;
    return format("%.10f", result);
}

// this function will calculate all powers and roots
string calculatePowersAndRoots(string mathExpression)
{
    // here we will store the result of the calculations
    real partialResult;
    // these strings will contain the radix and the exponent
    string firstNumber, secondNumber;
    // these ints will be used to let the parser move and find the positions of the numbers
    int i, j, begin, end;
    // this loop will keep solving all powers and roots until there are none left
    while (canFind(mathExpression, '^') || canFind(mathExpression, 'r'))
        // this look will search for a sign of a power (^) or a root (r)
        for (i = 0; i < mathExpression.length; i++)
            // if it finds either of them
            if (mathExpression[i] == '^' || mathExpression[i] == 'r')
            {
                // here we will move the parser until it finds the previous operation which is not a power or a root
                j = i;
                while (j-- > 0)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                // here we will move the parser until it finds the limit of the first number
                begin = j + 1;
                firstNumber = mathExpression[begin .. i];
                // now we will start parsing until we find the next operation which is not a power or a root
                j = i + 1;
                // we search until we find an operator or the end of the expression
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                end = j;
                secondNumber = mathExpression[i + 1 .. end];
                // we check if we have to do a power or a root, then we calculate the result and store it inside 'partialResult'
                if (mathExpression[i] == '^')
                    partialResult = to!real(firstNumber) ^^ to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) ^^ (1.0 / to!real(secondNumber));
                // we check if the result will be inserted in the middle or in the end of the expression
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult);
            }
    // now we return the new expression with the powers and roots solved
    return mathExpression;
}

// this function will calculate all products and quotients
string calculateProductsAndQuotients(string mathExpression)
{
    // this variable will store the result of the calculations
    real partialResult;
    // these will be the operands
    string firstNumber, secondNumber;
    // these variables will be used to parse the expression
    int i, j, begin, end;
    // it will keep solving until there are no more products or quotients left
    while (canFind(mathExpression, '*') || canFind(mathExpression, '/'))
        // here we will move the parser until it finds an operator
        for (i = 0; i < mathExpression.length; i++)
            if (mathExpression[i] == '*' || mathExpression[i] == '/')
            {
                // here we will move the parser to determine the beginning of the first number
                j = i;
                while (j-- > 0)
                    // we stop when we find a sign of + or -, or when we reach the very beginning of the expression
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                // here we add 1 to make up for the previous loop
                begin = j + 1;
                firstNumber = mathExpression[begin .. i];
                // here we will move the parser to determine the end of the second number
                j = i + 1;
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                end = j;
                secondNumber = mathExpression[i + 1 .. end];
                // we check if we are dealing with a product or a quotient
                if (mathExpression[i] == '*')
                    partialResult = to!real(firstNumber) * to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) / to!real(secondNumber);
                // we check if we have to insert the result in the middle or in the end of the expression
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult);
            }
    // we return the math expression with all products and quotients solved
    return mathExpression;
}

// this function will calculate all sums and differences
string calculateSumsAndDifferences(string mathExpression)
{
    // this variable will hold the result of the calculations
    real partialResult;
    // these variables will contain the operands
    string firstNumber, secondNumber;
    // these variables will be used to parse the expression
    int i, j, begin, end;
    // we use a loop to keep checking the expression for sums and differences
    while (canFind(mathExpression, '+') || canFind(mathExpression[1 .. $], '-'))
        // here we will move the parser until we find a sum or a difference
        for (i = 1; i < mathExpression.length; i++)
            // if we find one
            if (mathExpression[i] == '+' || mathExpression[i] == '-')
            {
                firstNumber = mathExpression[0 .. i];
                // we have to check if there are doubled signs that appeared during the calculations
                firstNumber = replace(firstNumber, "+-", "-");
                firstNumber = replace(firstNumber, "--", "");
                // here we move the parser until we find the second number
                j = i;
                while (j++ < mathExpression.length - 1)
                    // we stop when we reach another operation, or the very end of the expression
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                end = j;
                secondNumber = mathExpression[i + 1 .. end];
                // we check if we are dealing with a sum or a difference
                if (mathExpression[i] == '+')
                    partialResult = to!real(firstNumber) + to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) - to!real(secondNumber);
                // we check if we are inserting the result in the middle or the end of the expression
                if (end < mathExpression.length)
                    mathExpression = format("%.10f", partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = format("%.10f", partialResult);
                break;
            }
    // we return the new expression fully solved, it will be just one number
    return mathExpression;
}
