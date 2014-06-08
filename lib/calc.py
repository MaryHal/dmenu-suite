#!/usr/bin/env python

import sys

import ast
import operator as op

# Default operators
operators = {ast.Add: op.add, ast.Sub: op.sub, ast.Mult: op.mul,
             ast.Div: op.truediv, ast.Pow: op.pow, ast.BitXor: op.xor}


# Modify power operator
def power(a, b):
    if any(abs(n) > 100 for n in [a, b]):
        raise ValueError((a,b))
    return op.pow(a, b)

operators[ast.Pow] = power

def eval_expr(expr):
    """
    >>> eval_expr('2^6')
    4
    >>> eval_expr('2**6')
    64
    >>> eval_expr('1 + 2*3**(4^5) / (6 + -7)')
    -5.0
    """
    return eval_(ast.parse(expr).body[0].value) # Module(body=[Expr(value=...)])

def eval_(node):
    if isinstance(node, ast.Num): # <number>
        return node.n
    elif isinstance(node, ast.operator): # <operator>
        return operators[type(node)]
    elif isinstance(node, ast.BinOp): # <left> <operator> <right>
        return eval_(node.op)(eval_(node.left), eval_(node.right))
    else:
        raise TypeError(node)

if __name__ == "__main__":
    expression = sys.argv[1]

    try:
        print (eval_expr(expression))
    except TypeError:
        print ("Error: Unexpected Operators")
    except ValueError:
        print ("Error: Invalid Values")
