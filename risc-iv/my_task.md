```python

def count_zero(n):
    """Count the number of zeros in the binary representation of a number"""
    count = 0
    for _ in range(32):
        count += 0 if n & 1 else 1
        n >>= 1
    return count

assert count_zero(5) == 30
assert count_zero(7) == 29
assert count_zero(247923789) == 19

```
