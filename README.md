# TCTLParser

[![Swift Lint](https://github.com/CPSLabGU/TCTLParser/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/CPSLabGU/TCTLParser/actions/workflows/swiftlint.yml)
[![Swift Coverage Test](https://github.com/CPSLabGU/TCTLParser/actions/workflows/cov.yml/badge.svg)](https://github.com/CPSLabGU/TCTLParser/actions/workflows/cov.yml)
[![MacOS CI](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-macOS.yml/badge.svg)](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-macOS.yml)
[![Linux CI](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-linux.yml)
[![Windows CI](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-windows.yml/badge.svg)](https://github.com/CPSLabGU/TCTLParser/actions/workflows/ci-windows.yml)

A `TCTL` parser written in [swift](https://www.swift.org).

## Supported Platforms

- Swift 5.7 or later.
- MacOS 14 or later (earlier versions should be compatible, provided they support Swift 5.7).
- Linux (Ubuntu 22.04 or later).
- Windows 10 or later.
- Windows Server Edition 2022 or later.

## Depending on the Parser in Swift Projects

To use this parser, please place it as a dependency within your package manifest.

```swift
// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The package definition.
let package = Package(
    name: <Package name>,
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other
        // packages.
        <products>
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/cpslabgu/TCTLParser.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package
        // depends on.
        .target(
            name: <target name>,
            dependencies: [
                .product(name: "TCTLParser", package: "TCTLParser")
            ]
        )
    ]
)
```

## Usage

This parser reads specification files and creates type-safe structures when the input is valid. The full
documentation on the syntax of the specification files is provided on the
[documentation website](https://cpslabgu.github.io/TCTLParser/).

The parser works by embedding language expressions within the TCTL operators. The currently supported
languages are `VHDL`, as this parser is primarily built to support formal verification on
`FPGAs` using the `VHDL` language. In the future, we will be supporting other languages that also support
formal verification using our software, e.g. `Swift` and `C/C++`.

You may parse a `TCTL` string using the `Expression` enumeration. For example, consider a `VHDL` expression
that states signal `x` is equal to `high`: `x = '1'`. We may write a specification that states this constraint
must evaluate to `true` in every reachable state within a program:

```swift
import TCTLParser

// A formula the states that x must equal '1' in VHDL.
let raw = "A G x = '1'"
guard let expression = Expression(rawValue: raw) else {
    fatalError("Invalid TCTL Formulae!")
}
```

The `expression` constant now contains a type-safe structure for the `raw` `TCTL` expression and may be passed
to a model checker for performing formal verification.
