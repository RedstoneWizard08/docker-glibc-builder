#!/usr/bin/env bash

set -eo pipefail; [[ "$TRACE" ]] && set -x

DIR="$(realpath "$(dirname "$0")")"

main() {
	declare version="${1:-$GLIBC_VERSION}" prefix="${2:-$PREFIX_DIR}"

	: "${version:?}" "${prefix:?}"
	
	echo "Downloading..."

	wget -qO- "https://ftpmirror.gnu.org/libc/glibc-$version.tar.gz" \
		| tar zxf -

	mkdir -p /glibc-build && cd /glibc-build

	echo "Configuring..."

	"$DIR/glibc-$version/configure" \
		--prefix="$prefix" \
		--libdir="$prefix/lib" \
		--libexecdir="$prefix/lib" \
		--enable-stack-protector=strong
	
	echo "Building..."
	
	make
	
	echo "Installing..."
	
	make install
	
	echo "Compressing..."
	
	tar --dereference --hard-dereference -zcf "/glibc-bin-$version.tar.gz" "$prefix"
}

main "$@"
