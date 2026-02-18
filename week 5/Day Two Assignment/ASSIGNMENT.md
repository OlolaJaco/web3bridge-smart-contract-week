### Assignment 1 

## Where are structs, mappings, and arrays stored 
    - When declared in the contract level they are state varibles therefore are stored in the storage which is permanent on the blockchain 
    - When declared inside a function and the 'memory' keyword is added to it, it stays in the memory also if the 'storage' keyword is used it points to existing storage data. 


## How they behave when executed
    1. Structs
        - when declared storage: each field is saved into storage slots, and changes are permanent.
        - when declared memory: it’s just a copy; changes disappear after the function ends.
​
    2. Arrays
        -when declared storage arrays: reading/writing elements uses storage slots and costs gas; dynamic arrays can grow/shrink with push/pop.
        -when declared memory arrays: created with new, exist only inside the function and cannot be resized.
​

    3. Mappings
        - Only exist in storage; every key points to some storage slot behind the scenes.
        - They have no length and cannot be iterated directly; you just read/write by key.

## Why mappings don’t need memory or storage
    1. Mappings are storage‑only types
        - Solidity only allows mappings in storage, not in memory or calldata.
​        - So you never write mapping(...) memory or mapping(...) storage as a standalone type.

    2. Location is implied by where you declare it
        - At contract level, a mapping is automatically a storage state variable.
        - Inside a struct that lives in storage, its mapping field is also automatically in storage.