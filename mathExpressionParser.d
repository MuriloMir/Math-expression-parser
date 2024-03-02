// This code implements a math expression parser, meaning an interpreter which can solve any mathematical expression with 10 digits of precision.

import std.algorithm.searching : canFind, countUntil;
import std.array : replace, split;
import std.conv : to;
import std.math : cos, log2, sin, tan;
import std.stdio : readf, writefln, writeln;
import std.string : format;

// this function will just replace the constant 'e' with its proper value of 2.7182818285
string replaceEuler(string mathExpression)
{
    // use a loop to check all characters of the expression to see if any of them is an 'e'
    for (int i = 0; i < mathExpression.length; i++)
        // if it is not the 'sec()' function instead
        if ((i > 0 && mathExpression[i] == 'e' && mathExpression[i - 1] != 's') || (i < mathExpression.length - 1 && mathExpression[i] == 'e' && mathExpression[i + 1] != 'c'))
            // replace it in the expression with the number value
            mathExpression = mathExpression[0 .. i] ~ "2.7182818285" ~ mathExpression[i + 1 .. $];

    // return the updated mathematical expression without the constant 'e'
    return mathExpression;
}

// this function will calculate all logarithmic expressions
string calculateLogs(string mathExpression)
{
    // this variable will contain the result of the operations we perform
    real partialResult;
    // these variables will hold the number and the base
    string firstNumber, secondNumber;
    // these variables will be used to keep track of the position of the parser
    int i, begin, end;

    // use a loop to keep solving all logs until there are none left
    while (canFind(mathExpression, "log"))
    {
        // count until we find the word "log" and add 4 to push the parser to the number that comes after "log("
        begin = cast(int) countUntil(mathExpression, "log") + 4;
        // start with 'i' right to the left of 'begin', we use this to move the parser until we find the comma
        i = begin - 1;

        // keep incrementing the 'i' variable until it reaches the comma
        while (mathExpression[++i] != ',')
        {}

        // evaluate it in case there is another expression inside the function, as in "log(x + 1, 10)", we need to evaluate it first, with 10 decimal places
        firstNumber = format("%.10f", evaluate(mathExpression[begin .. i]));
        // start with 'end' in the position next to 'i', we will move the parser until we find the final parenthesis
        end = i + 1;

        // keep incrementing the 'end' variable until it reaches a parenthesis
        while (mathExpression[end] != ')' || (end < mathExpression.length - 1 && mathExpression[end + 1] == ')'))
            end++;

        // evaluate it in case there is another expression inside the function, as in "log(2, x + 1)", we need to evaluate it first, with 10 decimal places
        secondNumber = format("%.10f", evaluate(mathExpression[i + 1 .. end]));

        // if either number is negative
        if (firstNumber[0] == '-' || secondNumber[0] == '-')
            // a logarithm of a negative number will return NaN because it is impossible
            return "NaN";
        // if they are both positive
        else
            // calculate the result by placing everything in the base 2, there is a property of logarithms which allows you to do this
            partialResult = log2(to!real(secondNumber)) / log2(to!real(firstNumber));

        // if a NaN was produced above
        if (partialResult == real.nan)
            // return it
            return "NaN";

        // place the result in its place inside the expression, with 10 decimal places
        mathExpression = mathExpression[0 .. begin - 4] ~ format("%.10f", partialResult) ~ mathExpression[end + 1 .. $];
    }

    // return the new expression without any logarithms
    return mathExpression;
}

// this is the function that solves each individual trigonometric expression
string solveAnyTrig(string mathExpression, string formula)
{
    // this variable will contain the result of the trigonometric expression
    real partialResult;
    // this variable will contain the number of degrees in the expression
    string number;
    // these variables will mark where the expression begins and where it ends
    int i, begin;
    // find the character where the formula begins, then add 4 to make up for the name and the '[', cast it because 'countUntil()' returns a long
    begin = cast(int) countUntil(mathExpression, formula) + 4;
    // start with 'i' right to the left of 'begin', so we can iterate until we reach the final bracket of the expression
    i = begin - 1;

    // start a loop to keep increasing the 'i' variable until it finds the closing bracket
    while (mathExpression[++i] != ']')
    {}

    // evaluate it, in case there is another expression inside the function, as in "sin[x + 4 / 5]", we need to evaluate it first, with 10 decimal places
    number = format("%.10f", evaluate(mathExpression[begin .. i]));

    // here we calculate the value according to the formula
    switch (formula)
    {
        // if it is a sin()
        case "sin":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = sin(to!real(number) / 57.2957795131);
            break;
        // if it is a cos()
        case "cos":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = cos(to!real(number) / 57.2957795131);
            break;
        // if it is a tan()
        case "tan":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = tan(to!real(number) / 57.2957795131);
            break;
        // if it is a sec()
        case "sec":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = 1.0 / cos(to!real(number) / 57.2957795131);
            break;
        // if it is a csc()
        case "csc":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = 1.0 / sin(to!real(number) / 57.2957795131);
            break;
        // if it is a csc()
        case "cot":
            // calculate it and store it in 'partialResult', we convert it from degrees to radians by dividing it by 57.2957795131
            partialResult = 1.0 / tan(to!real(number) / 57.2957795131);
            break;
        // in case you have mistyped something
        default:
            // it becomes a NaN value
            partialResult = real.nan;
    }

    // if a NaN was produced above
    if (partialResult == real.nan)
        // return it
        return "NaN";

    // replace it with the result in the original expression, with 10 decimal places
    mathExpression = mathExpression[0 .. begin - 4] ~ format("%.10f", partialResult) ~ mathExpression[i + 1 .. $];

    // return the new version of the expression with the trig function solved
    return mathExpression;
}

// this function calculates all trigonometric expressions by calling the function 'solveAnyTrig()' created above
string calculateTrigs(string mathExpression)
{
    // use a loop to check each trigonometric formula
    foreach (formula; ["sin", "cos", "tan", "sec", "csc", "cot"])
        // use a loop to keep solving the formula until they are all solved
        while (canFind(mathExpression, formula))
        {
            // solve it and update the expression
            mathExpression = solveAnyTrig(mathExpression, formula);

            // if a NaN was produced above
            if (mathExpression == "NaN")
                // return it
                return "NaN";
        }

    // return the updated version of the expression with all trig functions solved
    return mathExpression;
}

// this is the function that calculates the factorial of a number
string factorial(string number)
{
    // this variable will store the result, we use 'ulong' because a factorial can get super big
    ulong result;

    // if the number is negative or a 'float' (3.0 would be accepted as an integer here)
    if (number[0] == '-' || to!real(split(number, '.')[1]) != 0.0)
        // return NaN because in this case we can't calculate the factorial
        return "NaN";
    else
        // convert the string to 'real' and then convert it to 'ulong'
        result = to!ulong(to!real(number));

    // if the number is 0
    if (result == 0)
        // return 1.0
        return "1.0";

    // use a loop to multiply it by all numbers that come before it
    foreach (i; 2 .. result)
        // multiply it by the predecessor
        result *= i;

    // return the result as a string
    return to!string(result);
}

// this is the function that solves all factorials in the expression
string calculateFactorials(string mathExpression)
{
    // these variables will be used to know where the number begins and where it ends
    int begin, end;
    // this string will contain the number whose factorial we want to know
    string number;
    // find out the end, we begin from the end because we will count backwards, 'countUntil()' returns a long, hence we cast it
    begin = end = cast(int) countUntil(mathExpression, '!');

    // use a loop to step back until we find a sign of an operation or 'begin' turns negative (it happens if we reach the start of the expression)
    while (begin >= 0 && mathExpression[begin] != '+' && mathExpression[begin] != '*' && mathExpression[begin] != '/' &&
           (mathExpression[begin] != '-' || begin > 0 && mathExpression[begin - 1] == '['))
        // decrement the 'begin' variable
        begin--;

    // increment it because the loop above makes it be decremented once more than necessary
    begin++;
    // get the number out of the expression
    number = mathExpression[begin .. end];
    // replace any possible '[' and ']' which may have appeared during the calculations
    number = replace(number, "[", ""), number = replace(number, "]", "");
    // store the partial result in this variable
    string partialResult = factorial(number);

    // if a NaN was produced above
    if (partialResult == "NaN")
        // return it
        return "NaN";

    // add it back to the expression and return it, but to prevent bugs we have to check if 'end' is equal to the length of the math expression - 1
    return mathExpression[0 .. begin] ~ partialResult ~ (end < mathExpression.length - 1 ? mathExpression[end + 1 .. $] : "");
}

// this function will calculate all powers and roots
string calculatePowersAndRoots(string mathExpression)
{
    // this variable will store the result of the calculations
    real partialResult;
    // these strings will contain the radix and the exponent
    string firstNumber, secondNumber;
    // these variables will be used to let the parser move and find the positions of the numbers
    int i, j, begin, end;

    // use a loop to keep solving all powers and roots until there are none left
    while (canFind(mathExpression, '^') || canFind(mathExpression, 'r'))
        // start a loop to search for a sign of a power '^' or a root 'r'
        for (i = 0; i < mathExpression.length; i++)
            // if it finds either of the signs
            if (mathExpression[i] == '^' || mathExpression[i] == 'r')
            {
                // make 'j' equal to 'i', then start stepping back
                j = i;

                // use a loop to move the parser until it finds the previous operation which is neither a power nor a root
                while (j-- > 0)
                    // if it finds the sign of an operation, we have to check cases like "[-3] ^ 2" and also cases like "-3 ^ 2"
                    if ((mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/') &&
                        ((j > 0 && mathExpression[j - 1] != '[') || j == 0 && mathExpression[0] == '-'))
                        // stop the loop, it has already gotten where it should be
                        break;

                // start from the place right after 'j'
                begin = j + 1;
                // select the first number, it will be from 'begin' to 'i'
                firstNumber = mathExpression[begin .. i];
                // replace any possible '[' and ']' which may have appeared during the calculations
                firstNumber = replace(firstNumber, "[", ""), firstNumber = replace(firstNumber, "]", "");
                // set 'j' to be right after 'i', now we will start parsing until we find the next operation which is neither a power nor a root
                j = i + 1;

                // use a loop to search until we find an operator or the end of the expression
                while (j++ < mathExpression.length - 1)
                    // if it finds the sign of an expression
                    if ((mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/') &&
                        mathExpression[j - 1] != '[')
                        // end the loop, we've gotten where we needed to be
                        break;

                // set 'end' to be equal to 'j'
                end = j;
                // select the second number, it goes from 'i + 1' until 'end'
                secondNumber = mathExpression[i + 1 .. end];
                // replace any possible '[' and ']' which may have appeared during the calculations
                secondNumber = replace(secondNumber, "[", ""), secondNumber = replace(secondNumber, "]", "");

                // if we have to do a power
                if (mathExpression[i] == '^')
                    // calculate the result and store it inside 'partialResult'
                    partialResult = to!real(firstNumber) ^^ to!real(secondNumber);
                // if we have to do a root and the index is a positive integer
                else if (to!real(secondNumber) > 0.0 && to!real(secondNumber) % 1.0 == 0.0)
                    // if the radicand is negative
                    if (firstNumber[0] == '-')
                        // if the index is odd
                        if (to!real(secondNumber) % 2.0 == 1.0)
                            // remove the '-' sign, calculate the result, add the '-' sign back and store it inside 'partialResult'
                            partialResult = -(to!real(firstNumber[1 .. $]) ^^ (1.0 / to!real(secondNumber)));
                        // if the index is even then we can't calculate it, there is no square root of a negative number
                        else
                            // return NaN
                            return "NaN";
                    else
                        // calculate the result and store it inside 'partialResult'
                        partialResult = to!real(firstNumber) ^^ (1.0 / to!real(secondNumber));
                // if the index is not a positive integer, in this case we won't accept it
                else
                    // return NaN
                    return "NaN";

                // if a NaN was produced above
                if (partialResult == real.nan)
                    // return it
                    return "NaN";

                // if the result will be inserted in the middle of the expression
                if (end < mathExpression.length)
                    // concatenate the expression to form the final result, with 10 decimal places
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult) ~ mathExpression[end .. $];
                // if the result will be inserted in the end of the expression
                else
                    // concatenate the expression to form the final result, with 10 decimal places
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult);
            }

    // return the new expression with the powers and roots solved
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

    // use a loop to keep solving until there are no more products or quotients left
    while (canFind(mathExpression, '*') || canFind(mathExpression, '/'))
        // use a loop to move the parser until it finds an operator
        for (i = 0; i < mathExpression.length; i++)
            // if it is a product or a quotient
            if (mathExpression[i] == '*' || mathExpression[i] == '/')
            {
                // start with these variables equal to each other, here we will move the parser to determine the beginning of the first number
                j = i;

                // use a loop to keep stepping back
                while (j-- > 0)
                    // if we find a sign of '+' or '-', we have to check cases like "[-3] * 2"
                    if ((mathExpression[j] == '+' || mathExpression[j] == '-') && (j > 0 && mathExpression[j - 1] != '['))
                        // stop the loop, we've gotten where we wanted to be
                        break;

                // add 1 to make up for the previous loop, it decremented once more than necessary
                begin = j + 1;
                // select the first number from the expression
                firstNumber = mathExpression[begin .. i];
                // replace any possible '[' and ']' which may have appeared during the calculations
                firstNumber = replace(firstNumber, "[", ""), firstNumber = replace(firstNumber, "]", "");
                // start with 'j' right after 'i', here we will move the parser to determine the end of the second number
                j = i + 1;

                // use a loop to keep moving 'j' forward
                while (j++ < mathExpression.length - 1)
                    // if it finds the sign of an operation, we have to check cases like "2 * [-3]"
                    if ((mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/') &&
                        mathExpression[j - 1] != '[')
                        // it ends the loop, we've gotten where we wanted to be
                        break;

                // set 'end' equals 'j'
                end = j;
                // select the second number, it starts at 'i + 1' and goes until 'end'
                secondNumber = mathExpression[i + 1 .. end];
                // replace any possible '[' and ']' which may have appeared during the calculations
                secondNumber = replace(secondNumber, "[", ""), secondNumber = replace(secondNumber, "]", "");

                // if we are dealing with a product
                if (mathExpression[i] == '*')
                {
                    // calculate it
                    partialResult = to!real(firstNumber) * to!real(secondNumber);

                    // if a NaN was produced above
                    if (partialResult == real.nan)
                        // return it
                        return "NaN";
                }
                // if we are dealing with a quotient
                else
                    // in case you are dividing by 0, which is impossible
                    if (to!real(secondNumber) == 0.0)
                        // return it
                        return "NaN";
                    // if it is a possible division
                    else
                        // calculate it
                        partialResult = to!real(firstNumber) / to!real(secondNumber);

                // if a NaN was produced above
                if (partialResult == real.nan)
                    // return it
                    return "NaN";

                // if we have to insert the result in the middle of the expression
                if (end < mathExpression.length)
                    // concatenate to form the final expression, with 10 decimal places
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult) ~ mathExpression[end .. $];
                // if we have to insert the result in the end of the expression
                else
                    // concatenate to form the final expression, with 10 decimal places
                    mathExpression = mathExpression[0 .. begin] ~ format("%.10f", partialResult);
            }

    // return the math expression with all products and quotients solved
    return mathExpression;
}

// this function will calculate all sums and differences
string calculateSumsAndDifferences(string mathExpression)
{
    // this variable will hold the result of the calculations
    real partialResult;
    // these variables will contain the operands
    string firstNumber, secondNumber;

    // if it is something like "-[-2.3] or "-[-1.3] + 2.0"
    if (mathExpression.length > 4 && mathExpression[0 .. 3] == "-[-")
        // if it is something exactly like "-[-2.3]"
        if (countUntil(mathExpression, ']') == mathExpression.length - 1)
            // return the expression without the "[]" and the doubled '-' signs
            return mathExpression[3 .. $ - 1];
        // if it is something more elaborated, like "-[-1.3] + 2.0"
        else
            // remove the first "[]", remove the doubled '-' and then append the rest of the expression
            mathExpression = mathExpression[3 .. countUntil(mathExpression, ']')] ~ mathExpression[countUntil(mathExpression, ']') + 1 .. $];

    // use a loop to keep checking the expression for sums and differences, we have to check cases like "-5 + x", which start with the '-' sign,
    // notice we create the variables 'i, j, begin, end' to parse the expression and 'i' has to go back to 0 for the next iteration to work
    for (int i, j, begin, end; canFind(mathExpression, '+') || canFind(mathExpression[1 .. $], '-'); i = 0)
    {
        //  if it is something like "[-2] + 3"
        if (mathExpression[0] == '[')
            // we move the parser 1 step forward to make up for the '['
            i++;

        // use a loop to move the parser until we find a sum or a difference, we must pay attention to cases such as "-2 + 3", hence the '++i'
        for (++i; i < mathExpression.length; i++)
            // if it is a case like "[-2.3]", where there are no more operations to be done but it still finds the '-' sign
            if (i == mathExpression.length - 1 && mathExpression[i] == ']')
                // return the expression
                return mathExpression;
            // if we find a sign
            else if (mathExpression[i] == '+' || mathExpression[i] == '-')
            {
                // select the first number
                firstNumber = mathExpression[0 .. i];
                // replace any possible '[' and ']' which may have appeared during the calculations
                firstNumber = replace(firstNumber, "[", ""), firstNumber = replace(firstNumber, "]", "");
                // replace all "+-" and all "--" which may have appeared during the calculations
                firstNumber = replace(firstNumber, "+-", "-"), firstNumber = replace(firstNumber, "--", "");
                // start with 'j' equal to 'i', this will be necessary to find the second number
                j = i;

                // use a loop to move the parser until we find the second number
                while (j++ < mathExpression.length - 1)
                    // if we reach another operation and there is no '[' in front of it (e.g. "4 + [-3]")
                    if ((mathExpression[j] == '+' || mathExpression[j] == '-') && mathExpression[j - 1] != '[')
                        // stop the loop, we've gotten where we want to be
                        break;

                // set 'end' to be equal to 'j'
                end = j;
                // select the second number from the expression
                secondNumber = mathExpression[i + 1 .. end];
                // replace any possible '[' and ']' which may have appeared during the calculations
                secondNumber = replace(secondNumber, "[", ""), secondNumber = replace(secondNumber, "]", "");

                // if we are dealing with a sum
                if (mathExpression[i] == '+')
                    // calculate the result
                    partialResult = to!real(firstNumber) + to!real(secondNumber);
                // if we are dealing with a difference
                else
                    // calculate the result
                    partialResult = to!real(firstNumber) - to!real(secondNumber);

                // if a NaN was produced above
                if (partialResult == real.nan || partialResult == real.infinity || partialResult == -real.infinity)
                    // return it
                    return "NaN";

                // if we are inserting the result in the middle of the expression
                if (end < mathExpression.length)
                    // concatenate to form the final expression, with 10 decimal places
                    mathExpression = format("%.10f", partialResult) ~ mathExpression[end .. $];
                // if we are inserting the result in the end of the expression
                else
                    // form the final expression, with 10 decimal places
                    mathExpression = format("%.10f", partialResult);

                // end the loop, we've gotten where we wanted to be
                break;
            }
    }

    // return the new expression fully solved, it will be just one number
    return mathExpression;
}

// this is the recursive function that truly evaluates the expression, this is the heart of this code, it uses all the functions created above
real evaluate(string expressionPiece)
{
    // we use these variables to parse it and find the parenthesis
    int i, j;
    // this variable will contain the result of what is inside the parenthesis
    real pieceResult;

    // we first calculate the logarithms, they work like a function in the form "log(2, 8)", we must calculate them first to prevent bugs,
    // calculate all logarithmic functions with the 'calculateLogs()' function created above
    expressionPiece = calculateLogs(expressionPiece);

    // if a NaN was produced above
    if (expressionPiece == "NaN")
        // return it
        return real.nan;

    // use a loop to keep solving all parenthesis, this has the side effect of removing all parenthesis and turning them into brackets
    while (canFind(expressionPiece, '(') && canFind(expressionPiece, ')'))
    {
        // find the first opening parenthesis, we cast it into 'int' because the 'countUntil()' function returns a 'long'
        i = cast(int) countUntil(expressionPiece, '(');

        // use a loop to check if there are nested opening parenthesis
        for (j = i + 1; j < expressionPiece.length; j++)
            // if it finds another opening parenthesis
            if (expressionPiece[j] == '(')
                // update the parser index
                i = j;
            // if we find the first closing parenthesis
            else if (expressionPiece[j] == ')')
                // stop the loop, we already have what we wanted
                break;

        // evaluate recursively what is in between these parenthesis
        pieceResult = evaluate(expressionPiece[i + 1 .. j]);

        // if a NaN was produced above
        if (pieceResult == real.nan)
            // return it
            return real.nan;

        // replace this value inside the expression, with 10 decimal places
        expressionPiece = expressionPiece[0 .. i] ~ format("[%.10f]", pieceResult) ~ expressionPiece[j + 1 .. $];
        // remove any possible "[[" and "]]" that may have appeared during the calculation
        expressionPiece = replace(expressionPiece, "[[", "["), expressionPiece = replace(expressionPiece, "]]", "]");
    }

    // if there is an extra parenthesis that you've mistyped
    if (canFind(expressionPiece, '(') || canFind(expressionPiece, ')'))
        // return NaN
        return real.nan;

    // from now on there are no more "()", only "[]", we calculate all trigonometric functions with the 'calculateTrigs()' function created above
    expressionPiece = calculateTrigs(expressionPiece);

    // if a NaN was produced above
    if (expressionPiece == "NaN")
        // return it
        return real.nan;

    // remove all doubled '-' signs and then remove all adjacent '+' and '-' signs that may have appeared during the calculations
    expressionPiece = replace(expressionPiece, "--", "+"), expressionPiece = replace(expressionPiece, "+-", "-");

    // use a loop to keep calculating all factorials
    while (canFind(expressionPiece, '!'))
    {
        // calculate the factorials with the 'calculateFactorials()' function created above
        expressionPiece = calculateFactorials(expressionPiece);

        // if a NaN was produced above
        if (expressionPiece == "NaN")
            // return it
            return real.nan;
    }

    // calculate all powers and roots with the 'calculatePowersAndRoots()' function created above
    expressionPiece = calculatePowersAndRoots(expressionPiece);

    // if a NaN was produced above
    if (expressionPiece == "NaN")
        // return it
        return real.nan;

    // calculate all products and quotients with the 'calculateProductsAndQuotients()' function created above
    expressionPiece = calculateProductsAndQuotients(expressionPiece);

    // if a NaN was produced above
    if (expressionPiece == "NaN")
        // return it
        return real.nan;

    // remove all doubled '-' signs and then remove all adjacent '+' and '-' signs that may have appeared during the calculations
    expressionPiece = replace(expressionPiece, "--", "+"), expressionPiece = replace(expressionPiece, "+-", "-");

    // calculate all sums and differences with the 'calculateSumsAndDifferences()' function created above
    expressionPiece = calculateSumsAndDifferences(expressionPiece);

    // if a NaN was produced above
    if (expressionPiece == "NaN")
        // return it
        return real.nan;

    // replace any possible '[' and ']' which may have appeared during the calculations
    expressionPiece = replace(expressionPiece, "[", ""), expressionPiece = replace(expressionPiece, "]", "");

    // if the expression is something like "-0.0"
    if (expressionPiece[0] == '-' && to!real(expressionPiece) == 0.0)
        // return just 0.0 instead of -0.0 because it would be weird
        return 0.0;
    // if the expression is anything else
    else
        // return the final value as a real number
        return to!real(expressionPiece);
}

void main()
{
    // this string will hold the expression
    string expression;
    // these variables will hold the result and the value of x
    real result, xValue;

    // ask the user the type the expression
    writeln("Type in the expression as a function of x: ");
    // read the input
    readf("%s\n", expression);

    // ask the user to type the value of x
    writeln("Type in the value of x: ");
    // read the input
    readf("%f\n", xValue);

    // if the x value is negative
    if (xValue < 0.0)
        // replace all x variables with the x value, with 10 decimal places, but put it between parenthesis, because of the '-' sign
        expression = replace(expression, "x", format("(%.10f)", xValue));
    // if the x value is non-negative
    else
        // replace all x variables with the x value, with 10 decimal places
        expression = replace(expression, "x", format("%.10f", xValue));

    // remove all spaces and then remove all doubled '+' and '-' signs
    expression = replace(expression, " ", ""), expression = replace(expression, "++", "+"), expression = replace(expression, "--", "+");
    // remove all adjacent '+' and '-' signs
    expression = replace(expression, "+-", "-"), expression = replace(expression, "-+", "-");
    // replace the constant of pi and then the constant of Euler, we use a separate function for Euler since it is more difficult than replacing pi
    expression = replace(expression, "pi", "3.1415926536"), expression = replaceEuler(expression);

    // finally do the magic and evaluate the whole expression with the functions created above
    result = evaluate(expression);

    // if the result is NaN
    if (result is real.nan)
        // print a message to let you know you've mistyped something
        writeln("Error, the expression wasn't typed correctly.");
    // if the expression was correct
    else
        // print the value, with 10 decimal places
        writefln("Result: %.10f", result);
}
