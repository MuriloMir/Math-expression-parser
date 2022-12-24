import std.algorithm.searching : canFind, countUntil;
import std.array : replace;
import std.conv : to;
import std.math : cos, log2, sin, tan;
import std.stdio : readf, writefln, writeln;

string solveAnyTrig(string mathExpression, real x, string formula)
{
    real partialResult;
    string number;
    int i, begin;
    begin = cast(int) countUntil(mathExpression, formula) + 4;
    i = begin - 1;
    while (mathExpression[++i] != ')')
    {}
    number = replace(mathExpression[begin .. i], "x", to!string(x));
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
        default:
            partialResult = real.nan;
    }
    mathExpression = mathExpression[0 .. begin - 4] ~ to!string(partialResult) ~ mathExpression[i + 1 .. $];
    return mathExpression;
}

string calculateTrigs(string mathExpression, real x)
{
    real partialResult;
    while (canFind(mathExpression, "sin"))
        mathExpression = solveAnyTrig(mathExpression, x, "sin");
    while (canFind(mathExpression, "cos"))
        mathExpression = solveAnyTrig(mathExpression, x, "cos");
    while (canFind(mathExpression, "tan"))
        mathExpression = solveAnyTrig(mathExpression, x, "tan");
    while (canFind(mathExpression, "sec"))
        mathExpression = solveAnyTrig(mathExpression, x, "sec");
    while (canFind(mathExpression, "csc"))
        mathExpression = solveAnyTrig(mathExpression, x, "csc");
    while (canFind(mathExpression, "cot"))
        mathExpression = solveAnyTrig(mathExpression, x, "cot");
    return mathExpression;
}

string calculateLogs(string mathExpression, real x)
{
    real partialResult;
    string firstNumber, secondNumber;
    int i, begin, end;
    while (canFind(mathExpression, "log"))
    {
        begin = cast(int) countUntil(mathExpression, "log") + 4;
        i = begin - 1;
        while (mathExpression[++i] != ',')
        {}
        firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
        end = i;
        while (mathExpression[++end] != ')')
        {}
        secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
        if (firstNumber[0] == '-' || secondNumber[0] == '-')
            partialResult = real.nan;
        else
            partialResult = log2(to!real(secondNumber)) / log2(to!real(firstNumber));
        mathExpression = mathExpression[0 .. begin - 4] ~ to!string(partialResult) ~ mathExpression[end + 1 .. $];
    }
    return mathExpression;
}

string calculatePowersAndRoots(string mathExpression, real x)
{
    real partialResult;
    string firstNumber, secondNumber;
    int i, j, begin, end;
    while (canFind(mathExpression, '^') || canFind(mathExpression, 'r'))
        for (i = 0; i < mathExpression.length; i++)
            if (mathExpression[i] == '^' || mathExpression[i] == 'r')
            {
                j = i;
                while (j-- > 0)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                begin = j + 1;
                firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
                j = i + 1;
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-' || mathExpression[j] == '*' || mathExpression[j] == '/')
                        break;
                end = j;
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                if (mathExpression[i] == '^')
                    partialResult = to!real(firstNumber) ^^ to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) ^^ (1.0 / to!real(secondNumber));
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult);
            }
    return mathExpression;
}

string calculateProdutsAndQuotients(string mathExpression, real x)
{
    real partialResult;
    string firstNumber, secondNumber;
    int i, j, begin, end;
    while (canFind(mathExpression, '*') || canFind(mathExpression, '/'))
        for (i = 0; i < mathExpression.length; i++)
            if (mathExpression[i] == '*' || mathExpression[i] == '/')
            {
                j = i;
                while (j-- > 0)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                begin = j + 1;
                firstNumber = replace(mathExpression[begin .. i], "x", to!string(x));
                j = i + 1;
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                end = j;
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                if (mathExpression[i] == '*')
                    partialResult = to!real(firstNumber) * to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) / to!real(secondNumber);
                if (end < mathExpression.length)
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = mathExpression[0 .. begin] ~ to!string(partialResult);
            }
    return mathExpression;
}

string calculateSumsAndDifferences(string mathExpression, real x)
{
    real partialResult;
    string firstNumber, secondNumber;
    int i, j, begin, end;
    while (canFind(mathExpression, '+') || canFind(mathExpression[1 .. $], '-'))
        for (i = 1; i < mathExpression.length; i++)
            if (mathExpression[i] == '+' || mathExpression[i] == '-')
            {
                firstNumber = replace(mathExpression[0 .. i], "x", to!string(x));
                firstNumber = replace(firstNumber, "+-", "-");
                firstNumber = replace(firstNumber, "--", "");
                j = i;
                while (j++ < mathExpression.length - 1)
                    if (mathExpression[j] == '+' || mathExpression[j] == '-')
                        break;
                end = j;
                secondNumber = replace(mathExpression[i + 1 .. end], "x", to!string(x));
                if (mathExpression[i] == '+')
                    partialResult = to!real(firstNumber) + to!real(secondNumber);
                else
                    partialResult = to!real(firstNumber) - to!real(secondNumber);
                if (end < mathExpression.length)
                    mathExpression = to!string(partialResult) ~ mathExpression[end .. $];
                else
                    mathExpression = to!string(partialResult);
                break;
            }
    return mathExpression;
}

real evaluate(string expressionPiece, real x)
{
    if (expressionPiece == "x")
        return x;
    else if (expressionPiece == "-x")
        return -x;
    expressionPiece = calculateTrigs(expressionPiece, x);
    expressionPiece = calculateLogs(expressionPiece, x);
    int i, j;
    real pieceResult;
    while (canFind(expressionPiece, '(') && canFind(expressionPiece, ')'))
    {
        i = cast(int) countUntil(expressionPiece, '(');
        for (j = i + 1; j < expressionPiece.length; j++)
            if (expressionPiece[j] == '(')
                i = j;
            else if (expressionPiece[j] == ')')
                break;
        pieceResult = evaluate(expressionPiece[i + 1 .. j], x);
        expressionPiece = expressionPiece[0 .. i] ~ to!string(pieceResult) ~ expressionPiece[j + 1 .. $];
    }
    if (canFind(expressionPiece, '(') || canFind(expressionPiece, ')'))
        return real.nan;
    expressionPiece = replace(expressionPiece, "--", "+");
    expressionPiece = replace(expressionPiece, "+-", "-");
    expressionPiece = calculatePowersAndRoots(expressionPiece, x);
    expressionPiece = calculateProdutsAndQuotients(expressionPiece, x);
    expressionPiece = calculateSumsAndDifferences(expressionPiece, x);
    return to!real(expressionPiece);
}

string replaceEuler(string mathExpression)
{
    for (int i = 0; i < mathExpression.length; i++)
        if ((i > 0 && mathExpression[i] == 'e' && mathExpression[i - 1] != 's') || (i < mathExpression.length - 1 && mathExpression[i] == 'e' && mathExpression[i + 1] != 'c'))
            mathExpression = mathExpression[0 .. i] ~ "2.71828" ~ mathExpression[i + 1 .. $];
    return mathExpression;
}

void main()
{
    string expression;
    real result, xValue;
    bool running = true;
    writeln("Type in the expression as a function of x: ");
    readf("%s\n", expression);
    writeln("Type in the value of x: ");
    readf("%f\n", xValue);
    expression = replace(expression, " ", "");
    expression = replace(expression, "++", "+");
    expression = replace(expression, "--", "+");
    expression = replace(expression, "+-", "-");
    expression = replace(expression, "-+", "-");
    expression = replaceEuler(expression);
    expression = replace(expression, "pi", "3.14159");
    result = evaluate(expression, xValue);
    if (result is real.nan)
        writeln("Error, the expression wasn't type correctly.");
    else
        writefln("%.10f", result);
}
