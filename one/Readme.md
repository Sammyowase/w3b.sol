# Storage Location of Structs, Mappings, and Arrays in Solidity

## 1. Where are structs, mappings, and arrays stored?

In Solidity, the storage location of a variable depends on **how and where it is declared**.

---

### a) Structs

A `struct` is a user-defined data type.  
Where it is stored depends on how it is used:

- **Struct as a state variable**
  ```solidity
  Task public task;
  ```
  → Stored in **storage** (permanently on the blockchain).

- **Struct created in a function with `memory`**
  ```solidity
  Task memory tempTask = Task(...);
  ```
  → Stored in **memory** (temporary, deleted after function execution).

- **Struct referenced with `storage`**
  ```solidity
  Task storage taskRef = tasks[0];
  ```
  → Refers directly to data in **storage** (no copy is made).

**Summary for structs:**
- State struct → `storage`
- Memory struct → `memory`
- Storage reference → `storage`

---

### b) Arrays

Arrays can also be stored in different locations:

- **State array**
  ```solidity
  Task[] public tasks;
  ```
  → Stored in **storage** permanently.

- **Function-local array**
  ```solidity
  uint[] memory arr = new uint[](5);
  ```
  → Stored in **memory** temporarily.

**Summary for arrays:**
- State arrays → `storage`
- Local arrays → `memory` (unless explicitly declared as storage references)

---

### c) Mappings

Mappings are special:

```solidity
mapping(address => uint256) balances;
```

Mappings:
- Can **only** exist in `storage`
- Cannot be created in `memory`
- Cannot be returned from functions
- Do not store keys, only values

This is **invalid**:
```solidity
mapping(address => uint256) memory balances; // ❌
```

**Summary for mappings:**
- Always in `storage`
- No memory version exists

---

## 2. How they behave when executed or called

### a) Storage behavior

- Persistent
- Written to the blockchain
- Costs more gas
- Changes remain after function finishes

**Example:**
```solidity
tasks[0].isComplete = true;
```
This permanently updates contract state.

---

### b) Memory behavior

- Temporary
- Exists only during function execution
- Cheaper than storage
- Changes are lost after the function ends

**Example:**
```solidity
Task memory t = tasks[0];
t.isComplete = true;
```
This does **not** update blockchain storage because `t` is only a memory copy.

---

### c) Mapping behavior

Mappings behave like key-value lookups:
- Given a key → returns a value
- If the key was never assigned → returns the default value
- Cannot be iterated over

**Example:**
```solidity
balances[msg.sender]
```
If `msg.sender` has no assigned value, it returns `0`.

---

## 3. Why you don't specify `memory` or `storage` for mappings

Because Solidity enforces that mappings must live in `storage`.

**Reasons:**
- Mappings represent persistent on-chain data
- They can be very large
- They cannot be copied
- They are accessed by key, not by index

So Solidity removes ambiguity by forcing this rule:
```solidity
mapping(address => uint256) balances; // always storage
```

You do not need to specify `storage balances;` or `memory balances;` because:
- `memory` is not allowed
- `storage` is already implied

---

## 4. Summary

| Type     | Possible Locations      | Notes                                      |
|----------|-------------------------|--------------------------------------------|
| Structs  | `memory` or `storage`   | Depends on how they are declared           |
| Arrays   | `memory` or `storage`   | Depends on how they are declared           |
| Mappings | `storage` only          | No keyword needed — Solidity enforces this |

- **Memory** = temporary (discarded after execution)
- **Storage** = permanent (persists on the blockchain)
- Mappings do not need a location keyword because Solidity restricts them to `storage` only

---


Structs and arrays may exist in either `memory` or `storage` depending on their declaration, while mappings are always stored in `storage`. Memory variables are temporary and discarded after execution, whereas storage variables persist on the blockchain. Mappings do not require a data location keyword because Solidity restricts them to `storage` only.