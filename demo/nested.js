#!/usr/bin/env nodejs

let x = 42
console.log(x ? 'yes' : 'no');

// Syntax highlighting
console.log(`x = ${x + 1}`);

console.log(`x = ${x ? 'yes': 'no'}`);

console.log(`x = ${x ? `nested backticks ${x}`: `no`}`);
