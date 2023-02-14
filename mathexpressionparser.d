import std.algorithm.searching : canFind, countUntil;
import std.array : replace;
import std.conv : to;
import std.math : cos, log2, sin, tan;
import std.stdio : readf, writefln, writeln;

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
    // now we remove all spaces and doubled signs
    expression = replace(expression, " ", "");
    expression = replace(expression, "++", "+");
    expression = replace(expression, "--", "+");
    expression = replace(expression, "+-", "-");
    expression = replace(expression, "-+", "-");
    // now we replace the constant of Euler's number
    expression = replaceEuler(expression);
    // then we replace the constant of pi
    expression = replace(expression, "pi", "3.14159");
    // then we finally do the magic and evaluate the whole expression with the functions defined below
    result = evaluate(expression, xValue);
    // we let you know if you have mistyped something, that happens if the result is NaN
    if (result is real.nan)
        writeln("Error, the expression wasn't type correctly.");
    // if the expression was correct then we print the value on the screen
    else
        writefln("%.10f", result);
}

// this is the function that solves each individual trigonometric expression
string solveAnyTrig(string mathExpression, real x, string formula)
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
    // here we plug the value of x into the expression and store it in the variable 'number'
    number = replace(mathExpression[begin .. i], "x", to!string(x));
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
    mathExpression = mathExpression[0 .. begin - 4] ~ to!string(partialResult) ~ mathExpression[i + 1 .. $];
    // it returns the new version of the expression with the trig function solved
    return mathExpression;
}

// this function calculates all trigonometric expressions by calling the function 'solveAnyTrig()' defined above
string calculateTrigs(string mathExpression, real x)
{
    // it checks each trigonometric formula
    foreach (formula; ["sin", "cos", "tan", "sec", "csc", "cot"])
    {
        // it keeps solving the formula in a loop until it has solved them all
        while (canFind(mathExpression, formula))
            mathExpression = solveAnyTrig(mathExpression, x, formula);
    }
    // it returns the new version of the expression with all trig functions solved
    return mathExpression;
}

// this function will calculate all logarithmic expressions
string calculateLogs(string mathExpression, real x)
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
        // now we plug x into our first expression (in case this is where x is located)
        firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
        // now we move the parser until we find the final parentheses
        end = i;
        while (mathExpression[++end] != ')')
        {}
        // now we plux x into our second expression (in case this is where x is located), we will use the change of base property to find the result
        secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
        // we have to make sure the number isn't negative
        if (firstNumber[0] == '-' || secondNumber[0] == '-')
            // a log of a negative number will return NaN because it is impossible
            partialResult = real.nan;
        else
            // here we calculate the result by placing everything in the base 2
            partialResult = log2(to!real(secondNumber)) / log2(to!real(firstNumber));
        // now we place the result in its place inside the expression
        mathExpression = mathExpression[0 .. begin - 4] ~ to!string(partialResult) ~ mathExpression[end + 1 .. $];
    }
    // now we return the new expression without any logs
    return mathExpression;
}

// this function will calculate all powers and roots
string calculatePowersAndRoots(string mathExpression, real x)
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
                // then we plug x in the first number of the expression (in case this is where x is located)
                firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
                // now we will start parsing until we find the next operation which is not a power or a root
                j = i + 1;
                // we search until we find an operator or the end of the expression
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                end = j;
                // now we plug x in the second number of the expression (in case this is where x is located)
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                // we check if we have to do a power or a root, then we calculate the result and store it inside 'partialResult'
                if (mathExpression[i] == '^')
                    partialResult = to!real(firstNumber) ^^ to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) ^^ (1.0 / to!real(secondNumber));
                // we check if the result will be inserted in the middle or in the end of the expression
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult);
            }
    // now we return the new expression with the powers and roots solved
    return mathExpression;
}

// this function will calculate all products and quotients
string calculateProdutsAndQuotients(string mathExpression, real x)
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
                // here we replace x in the first number, if there is an x there
                firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
                // here we will move the parser to determine the end of the second number
                j = i + 1;
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                end = j;
                // here we replace x in the second number, if there is an x in it
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                // we check if we are dealing with a product or a quotient
                if (mathExpression[i] == '*')
                    partialResult = to!real(firstNumber) * to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) / to!real(secondNumber);
                // we check if we have to insert the result in the middle or in the end of the expression
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult);
            }
    // we return the math expression with all products and quotients solved
    return mathExpression;
}

// this function will calculate all sums and differences
string calculateSumsAndDifferences(string mathExpression, real x)
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
                // we replace x in the first number, if it has an x
                firstNumber = replace(mathExpression[0 .. i], "x", to!string(x));
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
                // here we replace x in the second number, if it has one
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                // we check if we are dealing with a sum or a difference
                if (mathExpression[i] == '+')
                    partialResult = to!real(firstNumber) + to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) - to!real(secondNumber);
                // we check if we are inserting the result in the middle or the end of the expression
                if (end < mathExpression.length)
                    mathExpression = to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = to!string(partialResult);
                break;
            }
    // we return the new expression fully solved, it will be just one number
    return mathExpression;
}

// this is the recursive function that truly evaluates the expression, this is the heart of this code
real evaluate(string expressionPiece, real x)
{
    // here we check if the expression is the identity function
    if (expressionPiece == "x")
        return x;
    // or the negative version of the identity function
    else if (expressionPiece == "-x")
        return -x;
    // we first calculate all trigonometric functions
    expressionPiece = calculateTrigs(expressionPiece, x);
    // then we calculate all logarithmic functions
    expressionPiece = calculateLogs(expressionPiece, x);
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
        pieceResult = evaluate(expressionPiece[i + 1 .. j], x);
        // then we replace this value inside the expression
        expressionPiece = expressionPiece[0 .. i] ~ to!string(pieceResult) ~ expressionPiece[j + 1 .. $];
    }
    // if there is an extra parentheses that you've mistyped then we return NaN
    if (canFind(expressionPiece, '(') || canFind(expressionPiece, ')'))
        return real.nan;
    // here we get rid of all doubled signs that may have appeared during the calculations
    expressionPiece = replace(expressionPiece, "--", "+");
    expressionPiece = replace(expressionPiece, "+-", "-");
    // now we calculate all powers and roots
    expressionPiece = calculatePowersAndRoots(expressionPiece, x);
    // then we calculate all products and quotients
    expressionPiece = calculateProdutsAndQuotients(expressionPiece, x);
    // then we calculate all sums and differences
    expressionPiece = calculateSumsAndDifferences(expressionPiece, x);
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
