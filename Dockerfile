FROM swift:latest
WORKDIR /root

RUN apt-get update && apt-get install -y \
    llvm-11 llvm-11-dev \
    build-essential \
    libc++-11-dev \
    libc++abi-11-dev

RUN git clone https://github.com/llvm-swift/LLVMSwift
RUN git clone https://github.com/grph-lang/grph
RUN git clone https://github.com/grph-lang/grph-stdlib

WORKDIR /root/LLVMSwift
RUN swift utils/make-pkgconfig.swift

WORKDIR /root/grph
RUN swift package resolve
RUN (echo '#include <stdlib.h>'; echo '#include <string.h>') \
    >> .build/checkouts/LLVMSwift/Sources/cllvm/shim.h

RUN swift build --product CLI -c release
# Install global grph
RUN cp $(swift build --show-bin-path -c release)/CLI /usr/bin/grph

WORKDIR /root/grph-stdlib
RUN make install
