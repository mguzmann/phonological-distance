**Phonological distance calculator**

This is a basic implementation of a phonological (feature) distance calculator in Julia.

The idea is that the words *aba* and *apa* are more similar to eachother than
*aba* is to *asa* because their second segments share a feature in common.
In these cases common distance metrics miss this fact and would consider the three
to be equally distant from each other. This algorithm tries to solve this problem.

For this to work you need a feature matrix specification like the one in 
`featurs_spanish.tsv` (it can be whatever you want), and a list of words.
A example invocation is given in `run-aligns.jl` 
(beware that it will take a long time to run).

I am still working on this, but if you want to use it drop me an email.

