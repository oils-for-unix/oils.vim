#!/usr/bin/env python3

x = 42
print('yes' if x else 'no')

# No syntax highlighting here
print(f'x = {x + 1}')
print(f'x = {"yes" if x else "no"}')

# Python 3.11 doesn't allow nested quotes
# Python 3.12 changed it
# print(f'x = {'yes' if x else 'no'}')

