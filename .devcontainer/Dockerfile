FROM swift:6.4-resolute

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/swiftlint.zip "https://github.com/realm/SwiftLint/archive/refs/tags/0.65.1.zip" \
    && unzip /tmp/swiftlint.zip -d /tmp \
    && cd /tmp/SwiftLint-0.65.1 \
    && swift build -c release \
    && install -m 0755 "$(swift build -c release --show-bin-path)/swiftlint" /usr/local/bin/swift-lint \
    && rm -rf /tmp/SwiftLint-0.65.1 /tmp/swiftlint.zip

RUN wget -O /tmp/swift-format.zip https://github.com/swiftlang/swift-format/archive/refs/tags/604.0.0.zip \
    && unzip /tmp/swift-format.zip -d /tmp \
    && cd /tmp/swift-format-604.0.0 \
    && swift build -c release \
    && install -m 0755 "$(swift build -c release --show-bin-path)/swift-format" /usr/local/bin/swift-format \
    && rm -rf /tmp/swift-format-604.0.0 /tmp/swift-format.zip
