```python
def gcd(a, b):
    """Find the greatest common divisor (GCD)"""
    while b != 0:
        a, b = b, a % b
    return [abs(a)]

assert gcd([48, 18]) == [6]
assert gcd([56, 98]) == [14]
```
