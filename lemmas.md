```k
requires "evm.md"
requires "foundry.md"

module KONTROL-LEMMAS
    imports BOOL
    imports FOUNDRY
    imports INFINITE-GAS
    imports INT-SYMBOLIC

    rule bool2Word ( X ) => 1 requires X         [simplification]
    rule bool2Word ( X ) => 0 requires notBool X [simplification]
```

## Arithmetic

Lemmas on arithmetic reasoning. Specifically, on: cancellativity, inequalities in which the two sides are of different signs; and the rounding-up mechanism of the Solidity compiler (expressed through `notMaxUInt5 &Int ( X +Int 31 )`, which rounds up `X` to the nearest multiple of 32).

```k
    // Cancellativity #1
    rule A +Int ( (B -Int A) +Int C ) => B +Int C [simplification]

    // Cancellativity #2
    rule (A -Int B) -Int (C -Int B) => A -Int C [simplification]

    // Cancellativity #3
    rule A -Int (A +Int B) => 0 -Int B [simplification]

    // Various inequalities
    rule X  <Int A &Int B => true requires X <Int 0 andBool 0 <=Int A andBool 0 <=Int B [concrete(X), simplification]
    rule X  <Int A +Int B => true requires X <Int 0 andBool 0 <=Int A andBool 0 <=Int B [concrete(X), simplification]
    rule X <=Int A +Int B => true requires X <Int 0 andBool 0 <=Int A andBool 0 <=Int B [concrete(X), simplification]

    // Upper bound on (pow256 - 32) &Int lengthBytes(X)
    rule notMaxUInt5 &Int Y <=Int Y => true
      requires 0 <=Int Y
      [simplification]

    // Bounds on notMaxUInt5 &Int ( X +Int 31 )
    rule X <=Int   notMaxUInt5 &Int ( X +Int 31 )          => true requires 0 <=Int X                   [simplification]
    rule X <=Int   notMaxUInt5 &Int ( Y +Int 31 )          => true requires X <=Int 0 andBool 0 <=Int Y [simplification, concrete(X)]
    rule X <=Int ( notMaxUInt5 &Int ( X +Int 31 ) ) +Int Y => true requires 0 <=Int X andBool 0 <=Int Y [simplification, concrete(Y)]

    rule notMaxUInt5 &Int X +Int 31 <Int Y => true requires 0 <=Int X andBool X +Int 32 <=Int Y [simplification, concrete(Y)]

    rule notMaxUInt5 &Int X +Int 31 <Int X +Int 32 => true requires 0 <=Int X [simplification]
```

## `#asWord`

Lemmas about [`#asWord`](https://github.com/runtimeverification/evm-semantics/blob/master/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md#bytes-helper-functions). `#asWord(B)` interprets the byte array `B` as a single word (with MSB first).

```k
    // Move to function parameters
    rule { #asWord ( BA1 ) #Equals #asWord ( BA2 ) } => #Top
      requires BA1 ==K BA2
      [simplification]

    // #asWord ignores leading zeros
    rule #asWord ( BA1 +Bytes BA2 ) => #asWord ( BA2 )
      requires #asInteger(BA1) ==Int 0
      [simplification, concrete(BA1)]

    // `#asWord` of a byte array cannot equal a number that cannot fit within the byte array
    rule #asWord ( BA ) ==Int Y => false
        requires lengthBytes(BA) <=Int 32
         andBool (2 ^Int (8 *Int lengthBytes(BA))) <=Int Y
        [concrete(Y), simplification]
```

## `#asInteger`

Lemmas about [`#asInteger`](https://github.com/runtimeverification/evm-semantics/blob/master/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md#bytes-helper-functions). `#asInteger(X)` interprets the byte array `X` as a single arbitrary-precision integer (with MSB first).

```k
    // Conversion from bytes always yields a non-negative integer
    rule 0 <=Int #asInteger ( _ ) => true [simplification]
```

## `#padRightToWidth`

Lemmas about [`#padRightToWidth`](https://github.com/runtimeverification/evm-semantics/blob/master/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md#bytes-helper-functions). `#padRightToWidth(W, BA)` right-pads the byte array `BA` with zeros so that the resulting byte array has length `W`.

```k
    // Definitional expansion
    rule #padRightToWidth (W, BA) => BA +Bytes #buf(W -Int lengthBytes(BA), 0)
      [concrete(W), simplification]
```

## `#range(BA, START, WIDTH)`

Lemmas about [`#range(BA, START, WIDTH)`](https://github.com/runtimeverification/evm-semantics/blob/master/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md#bytes-helper-functions). `#range(BA, START, WIDTH)` returns the range of `BA` from index `START` of width `WIDTH`.

```k
    // Parameter equality
    rule { #range (BA, S, W1) #Equals #range (BA, S, W2) } => #Top
      requires W1 ==Int W2
      [simplification]
```

## Byte array indexing and update

Lemmas about [`BA [ I ]` and `BA1 [ S := BA2 ]`](https://github.com/runtimeverification/evm-semantics/blob/master/kevm-pyk/src/kevm_pyk/kproj/evm-semantics/evm-types.md#element-access). `BA [ I ]` returns the integer representation of the `I`-th byte of byte array `BA`. `BA1 [ S := BA2 ]` updates the byte array `BA1` with byte array `BA2` from index `S`.

```k
    // Byte indexing in terms of #asWord
    rule BA [ X ] => #asWord ( #range (BA, X, 1) )
      requires X <=Int lengthBytes(BA)
      [simplification(40)]

    // Empty update has no effect
    rule BA [ START := b"" ] => BA
      requires 0 <=Int START andBool START <=Int lengthBytes(BA)
      [simplification]

    // Update passes to right operand of concat if start position is beyond the left operand
    rule ( BA1 +Bytes BA2 ) [ S := BA ] => BA1 +Bytes ( BA2 [ S -Int lengthBytes(BA1) := BA ] )
      requires lengthBytes(BA1) <=Int S
      [simplification]

    // Consecutive quasi-contiguous byte-array update
    rule BA [ S1 := BA1 ] [ S2 := BA2 ] => BA [ S1 := #range(BA1, 0, S2 -Int S1) +Bytes BA2 ]
      requires 0 <=Int S1 andBool S1 <=Int S2 andBool S2 <=Int S1 +Int lengthBytes(BA1)
      [simplification]

    // Parameter equality: byte-array update
    rule { BA1:Bytes [ S1 := BA2 ] #Equals BA3:Bytes [ S2 := BA4 ] } => #Top
      requires BA1 ==K BA3 andBool S1 ==Int S2 andBool BA2 ==K BA4
      [simplification]

endmodule
```